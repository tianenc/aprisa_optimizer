import optuna
import subprocess
import re
import os
import shutil
import tempfile
import time

def objective(trial):
    """
    The objective function for Optuna to optimize.
    Runs a two-step Aprisa CTS flow and returns a value to minimize.
    """
    temp_dir_path = None
    try:
        # Create a temporary directory for this trial to prevent race conditions.
        temp_dir_path = tempfile.mkdtemp()
        
        # Copy all necessary project files into the temporary directory.
        # You must ensure all required files (e.g., cts.tcl, cts_opt.tcl, scripts/ directory)
        # are present in the same directory as this script.
        shutil.copytree('scripts', os.path.join(temp_dir_path, 'scripts'))
        shutil.copy('cts.tcl', temp_dir_path)
        shutil.copy('cts_opt.tcl', temp_dir_path)
        
        # 1. Generate a unique clock_constraints file.
        MAX_FANOUT = 32
        max_clock_skew = trial.suggest_float('max_clock_skew', 0.05, 0.1)
        max_clock_tran = trial.suggest_float('max_clock_tran', 0.05, 0.1)
        max_sink_tran = trial.suggest_float('max_sink_tran', 0.05, 0.1)

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
set cmd "set_skew_group_constraint -group {{[get_skew_groups * ]}} -max_skew $max_clock_skew -max_tran $max_clock_tran -max_sink_tran $max_sink_tran"
if {{$temp != ""}} {{
    concat $cmd $temp
    eval $cmd
}} else {{
    eval $cmd
}}
"""
        constraints_file_path = os.path.join(temp_dir_path, 'scripts', 'custom', f'clock_constraints_{trial.number}.tcl')
        with open(constraints_file_path, 'w') as f:
            f.write(constraints_content)
        
        # 2. Execute the first flow step: cts.tcl
        aprisa_cts_cmd = [
            'AP', '-shell_only', '-log', f'cts_trial_{trial.number}_cts.log',
            'cts.tcl', str(trial.number)
        ]
        
        try:
            subprocess.run(aprisa_cts_cmd, check=True, cwd=temp_dir_path, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        except subprocess.CalledProcessError as e:
            print(f"CTS execution failed for trial {trial.number}:")
            return float('inf')

        # 3. Execute the second flow step: cts_opt.tcl
        aprisa_cts_opt_cmd = [
            'AP', '-shell_only', '-log', f'cts_trial_{trial.number}_cts_opt.log',
            'cts_opt.tcl', str(trial.number)
        ]
        
        try:
            subprocess.run(aprisa_cts_opt_cmd, check=True, cwd=temp_dir_path, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        except subprocess.CalledProcessError as e:
            print(f"CTS_OPT execution failed for trial {trial.number}:")
            return float('inf')
            
        # 4. Parse the final report from cts_opt.tcl
        # Assumes the report is saved to 'default/rpts/cts_opt.skew.rpt' within the run directory
        final_report_path = os.path.join(temp_dir_path, 'default', 'rpts', 'cts_opt.skew.rpt')
        
        max_latency = None
        skew_value = None
        try:
            with open(final_report_path, 'r') as f:
                report_content = f.read()
                pattern = r"Max Latency \(rise\):\s+([\d.]+)"
                match = re.search(pattern, report_content)
                if match:
                    max_latency = float(match.group(1))
                else:
                    return float('inf')
                
                skew_pattern = re.compile(r"^\s+Skew\s*:\s*([\d.]+)", re.MULTILINE)
                skew_match = skew_pattern.search(report_content)
                if skew_match:
                    skew_value = float(skew_match.group(1))
                
        except FileNotFoundError:
            return float('inf')
        
        objective_value = max_latency
        if skew_value is not None and skew_value > 0.07:
            penalty = 1.0 + (skew_value - 0.07) * 20
            objective_value += penalty
        
        return objective_value

    finally:
        # Clean up the temporary directory after the trial.
        if temp_dir_path and os.path.exists(temp_dir_path):
            shutil.rmtree(temp_dir_path)

def main():
    """
    Main function to set up and run the Optuna study without Slurm.
    """
    # Create the in-memory study
    study = optuna.create_study(direction='minimize')

    print("Starting Optuna optimization...")
    # Run a hard-coded number of trials sequentially (n_jobs=1 is the default)
    study.optimize(objective, n_trials=30)
    print("Optimization finished.")

    # Print the best trial's results
    best_trial = study.best_trial
    print(f"\nBest trial number: {best_trial.number}")
    print(f"Best objective value (incl. penalty): {best_trial.value:.4f}")
    print("Best parameters:")
    for key, value in best_trial.params.items():
        print(f"  {key}: {value:.4f}")

if __name__ == "__main__":
    main()