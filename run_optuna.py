import optuna
import subprocess
import re
import os
import shutil

def objective(trial):
    """
    The objective function for Optuna to optimize.
    It runs an Aprisa CTS flow with trial-specific parameters and returns a value to minimize.
    """
    # 1. Update search space based on new defaults.
    MAX_FANOUT = 32  # This remains hardcoded as requested.

    # Search ranges centered around your provided defaults
    max_clock_skew = trial.suggest_float('max_clock_skew', 0.05, 0.1)
    max_clock_tran = trial.suggest_float('max_clock_tran', 0.05, 0.1)
    max_sink_tran = trial.suggest_float('max_sink_tran', 0.05, 0.1)

    # 2. Generate a new clock_constraints.tcl file for this trial.
    constraints_content = f"""
set max_fanout {MAX_FANOUT}
set max_clock_skew {max_clock_skew}
set max_clock_tran {max_clock_tran}
set max_sink_tran {max_sink_tran}

set temp " -max_fanout $MAX_FANOUT"

foreach scn [current_mcmm] {{
    set_working_scen $scn
    set_max_transition $max_clock_tran [get_clocks [all_clocks]] -clock_path
}}

set_working_scenario {{}}
# The -max_cap parameter has been removed from this command
set cmd "set_skew_group_constraint -group {{[get_skew_groups * ]}} -max_skew $max_clock_skew -max_tran $max_clock_tran -max_sink_tran $max_sink_tran"

if {{$temp != ""}} {{
    concat $cmd $temp
    eval $cmd
}} else {{
    eval $cmd
}}
"""
    os.makedirs('scripts/custom', exist_ok=True)
    with open('scripts/custom/clock_constraints.tcl', 'w') as f:
        f.write(constraints_content)

    # 3. Execute Aprisa in batch mode
    log_file_path = f'logs/cts_trial_{trial.number}.log'
    source_report_path = 'default/rpts/cts.skew.rpt'
    os.makedirs('logs', exist_ok=True)
    os.makedirs('default/rpts', exist_ok=True)

    aprisa_command = [
        'AP', '-shell_only', '-log', log_file_path,
        'scripts/cts.tcl', str(trial.number)
    ]
    
    try:
        subprocess.run(aprisa_command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    except subprocess.CalledProcessError as e:
        print(f"Aprisa execution failed for trial {trial.number}:")
        print(e.stderr)
        return float('inf')

    # Copy the generated report to the logs directory with a unique name to archive it.
    destination_report_path = f'logs/cts_trial_{trial.number}.skew.rpt'
    try:
        shutil.copy(source_report_path, destination_report_path)
        print(f"Saved report for trial {trial.number} to {destination_report_path}")
    except FileNotFoundError:
        print(f"Could not find source report {source_report_path} to copy for archiving.")
    except Exception as e:
        print(f"An error occurred while copying the report file: {e}")

    # 4. Parse the UNIQUE, copied skew report file to avoid race conditions.
    max_latency = None
    skew_value = None
    try:
        with open(destination_report_path, 'r') as f:
            report_content = f.read()
            pattern = r"Max Latency \(rise\):\s+([\d.]+)"
            match = re.search(pattern, report_content)
            if match:
                max_latency = float(match.group(1))
            else:
                print(f"Could not find 'Max Latency (rise)' in {destination_report_path}")
                return float('inf')
            
            # Parse Skew from the same report to check the constraint
            skew_pattern = re.compile(r"^\s+Skew\s+:\s+([\d.]+)", re.MULTILINE)
            skew_match = skew_pattern.search(report_content)
            if skew_match:
                skew_value = float(skew_match.group(1))
            
    except FileNotFoundError:
        print(f"Report file not found for parsing: {destination_report_path}")
        return float('inf')
    
    objective_value = max_latency
    
    # 5. Apply penalty if the skew constraint is violated
    if skew_value is not None and skew_value > 0.07:
        # The penalty increases the further the skew is from the 0.07 target.
        # Adding a large base (1.0) makes any violation significantly worse for the optimizer.
        penalty = 1.0 + (skew_value - 0.07) * 20 
        objective_value += penalty
        print(f"INFO: Trial {trial.number}: Skew {skew_value:.4f} > 0.07. Applying penalty. New objective: {objective_value:.4f}")
    
    return objective_value

def main():
    """
    Main function to set up and run the Optuna study.
    """
    study = optuna.create_study(direction='minimize')

    print("Starting Optuna optimization...")
    study.optimize(objective, n_trials=30)
    print("Optimization finished.")

    best_trial = study.best_trial
    print(f"\nBest trial number: {best_trial.number}")
    print(f"Best objective value (incl. penalty): {best_trial.value}")
    print("Best parameters:")
    for key, value in best_trial.params.items():
        print(f"  {key}: {value}")

if __name__ == "__main__":
    main()