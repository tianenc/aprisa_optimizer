import optuna
import subprocess
import re
import os

def objective(trial):
    """
    The objective function for Optuna to optimize.
    It runs an Aprisa CTS flow with trial-specific parameters and returns a value to minimize.
    """
    # 1. Define the search space for the parameters you want to tune
    # These are the parameters from your clock_constraints.tcl file.
    max_fanout = trial.suggest_int('max_fanout', 5, 50)
    max_clock_skew = trial.suggest_float('max_clock_skew', 0.01, 0.5)
    max_clock_tran = trial.suggest_float('max_clock_tran', 0.1, 1.0)
    max_sink_tran = trial.suggest_float('max_sink_tran', 0.05, 0.5)

    # 2. Generate a new clock_constraints.tcl file for this trial
    # This ensures each trial has a unique set of constraints.
    constraints_content = f"""
set max_fanout {max_fanout}
set max_clock_skew {max_clock_skew}
set max_clock_tran {max_clock_tran}
set max_sink_tran {max_sink_tran}

set temp " -max_fanout $MAX_FANOUT"

foreach scn [current_mcmm] {{
    set_working_scen $scn
    set_max_transition $max_clock_tran [get_clocks [all_clocks]]  -clock_path
}}

set_working_scenario {{}}
if {{$temp != ""}} {{
    set cmd "set_skew_group_constraint -group {{[get_skew_groups * ]}}  -max_skew $max_clock_skew  -max_tran $max_clock_tran  -max_sink_tran $max_sink_tran "
    concat $cmd $temp
    eval $cmd
}} else {{
    eval "set_skew_group_constraint -group {{[get_skew_groups * ]}}  -max_skew $max_clock_skew  -max_tran $max_clock_tran  -max_sink_tran $max_sink_tran"
}}
"""
    # Write the dynamically generated file to the expected location
    os.makedirs('scripts/custom', exist_ok=True)
    with open('scripts/custom/clock_constraints.tcl', 'w') as f:
        f.write(constraints_content)

    # 3. Execute Aprisa in batch mode
    # The `cts.tcl` script will automatically pick up the new constraints file.
    log_file_path = f'logs/cts_trial_{trial.number}.log'
    aprisa_command = ['AP', '-shell_only', 'scripts/cts.tcl', '-log', log_file_path]
    
    try:
        # Run the Aprisa command as a subprocess
        result = subprocess.run(aprisa_command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    except subprocess.CalledProcessError as e:
        print(f"Aprisa execution failed for trial {trial.number}:")
        print(e.stderr)
        return float('inf') # Return a high value for failed trials

    # 4. Parse the log file to extract the objective value
    # We are optimizing for MIN latency, which is found in the report_skew_group_timing summary.
    pattern = r"Max Latency\s*\|\s*Min Latency\s*\|\s*Skew\n\|-+\s*\|-+\s*\|-+\n\|\s*([\d.]+\s*ns)\s*\|\s*([\d.]+\s*ns)\s*\|\s*([\d.]+\s*ns)"
    
    min_latency = None
    
    try:
        with open(log_file_path, 'r') as f:
            log_content = f.read()
            match = re.search(pattern, log_content, re.DOTALL)
            if match:
                # The second capture group is the Min Latency value
                min_latency = float(match.group(2).replace(' ns', ''))
    except FileNotFoundError:
        print(f"Log file not found for trial {trial.number}")
        return float('inf') # Return a high value if log file is missing

    # 5. Return the objective value
    # Optuna will try to minimize this value (Min Latency)
    if min_latency is not None:
        return min_latency
    else:
        return float('inf') # Return a high value if parsing failed

def main():
    """
    Main function to set up and run the Optuna study.
    """
    # Create an Optuna study. Set direction to 'minimize' for min latency.
    study = optuna.create_study(direction='minimize')

    # Run the optimization for a specified number of trials
    print("Starting Optuna optimization...")
    study.optimize(objective, n_trials=25)
    print("Optimization finished.")

    # Print the best trial and its parameters
    best_trial = study.best_trial
    print(f"\nBest trial number: {best_trial.number}")
    print(f"Best objective value (Min Latency): {best_trial.value} ns")
    print("Best parameters:")
    for key, value in best_trial.params.items():
        print(f"  {key}: {value}")

if __name__ == "__main__":
    main()