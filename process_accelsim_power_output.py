import os
import csv
import sys
from multiprocessing import Pool

def process_file(input_file, output_file_header='',kernel_launch_latency=0):
    # print(input_file)
    if '.out' not in input_file:
        print(f"Input file is not an output file: {input_file}")
        return
    found_mcpat = False
    found_proc = False
    has_const_static = False
    processor_info_list = []
    processor_info = []
    kernel_num = 1
    sampled_cycles = 0

    # Define the power metrics
    power_metrics = [
        'Area',
        'Peak Power',
        'Total Leakage',
        'Peak Dynamic',
        'Subthreshold Leakage',
        'Gate Leakage',
        'Runtime Dynamic',
    ]
    row_header = [
        'const_power_W', 
        'static_power_W', 
        'technology_nm',
        'core_clock_freq_mhz',
        'area',
        'peak_power_W', 
        'total_leakage_W', 
        'peak_dynamic_W', 
        'subthreshold_leakage_W', 
        'gate_leakage_W', 
        'runtime_dynamic_W',
    ]
    
    output_file = f"{output_file_header}.processed_csv"
        
    # Open the input file (with multiple kernels in it)
    with open(input_file, 'r') as infile:
        for line in infile:
            ############################
            # TODO If I update the print_dump to also print static power, I should have it here
            ############################
            if line.startswith("Constant Power: "):
                has_const_static = True
                const_power = line.strip().split("Power: ")[-1]
                processor_info.append(const_power)
            if line.startswith("Static Power: "):
                static_power = line.strip().split("Power: ")[-1]
                processor_info.append(static_power)

            # Check if the line contains "mcpat" and set found_mcpat to True if found
            if 'mcpat' in line.lower():
                found_mcpat = True
                continue
            if found_mcpat and line.strip().startswith('Technology'):
                technology = line.strip().split()[-2]
                # print('tech',technology)
                processor_info.append(technology)
            
            if found_mcpat and 'core clock' in line.lower():
                frequency = line.strip().split()[-1]
                # print('freq',frequency)
                processor_info.append(frequency)
            
            # If found_mcpat is True, extract power information under "Processor" section
            if found_mcpat and 'processor:' in line.lower():
                found_proc = True
                continue
            if found_mcpat and found_proc and '=' in line:
                # Extract metric and value from the line
                metric, value = line.strip().split('=')
                metric = metric.strip()  # Remove leading and trailing spaces
                value = value.strip()    # Remove leading and trailing spaces
                if value.endswith(' mm^2') or value.endswith(' W'):
                    value = value.replace(' mm^2','').replace(' W','')
                if metric in power_metrics:
                    processor_info.append(value)
            #I've finished getting data from the processor component; I consider data collection for this phase finished
            elif found_mcpat and found_proc:
                sampled_cycles += 1
                found_mcpat = False
                found_proc = False
                #Ignore cycles that just wait because of kernel launch latency
                if sampled_cycles > kernel_launch_latency:
                    processor_info_list.append(processor_info)
                processor_info = []

            #These will come at the end of the kernel log
            elif 'gpu_sim_cycle' in line:
                sim_cycle = line.strip().split()[-1]
            elif 'gpu_sim_insn' in line:
                sim_instr = line.strip().split()[-1]
                # Now that we are at the end of a kernel
                # Open the output CSV file for writing output for a particular kernel
                kernel_output_file = output_file.replace('processed', f'processed_k{kernel_num}_{sim_cycle}cycle_{sim_instr}instr')
                with open(kernel_output_file, 'w', newline='') as csvfile:
                    writer = csv.writer(csvfile)
                    if not has_const_static:
                        row_header.pop('const_power_W')
                        row_header.pop('static_power_W')
                    writer.writerow(row_header)  # Write CSV header
                    for row in processor_info_list:
                        writer.writerow(row)
                #Move on to the next kernel
                kernel_num += 1


def process_input_dir(input_dir):
    """
    Loops through the input directory to find simulation.out files and processes them.

    Args:
        input_dir (str): Path to the input directory containing opcode/config folders.
    """
    kernel_launch_latency = 0
    for opcode_folder in os.listdir(input_dir):
        opcode_path = os.path.join(input_dir, opcode_folder)
        if not os.path.isdir(opcode_path):
            continue  # Skip if it's not a directory
        for config_folder in os.listdir(opcode_path):
            config_path = os.path.join(opcode_path, config_folder)            
            if not os.path.isdir(config_path):
                continue  # Skip if it's not a directory
            else:
                kernel_launch_latency = 5000
                if "Tesla" in config_folder:
                    kernel_launch_latency = 8606
            simulation_file = os.path.join(config_path, "accelwattch_simulation.output")
            if os.path.isfile(simulation_file):
                # Pass the file, opcode, and config to the processing function
                output_file_header = f"{opcode_folder}_{config_folder}"
                process_file(simulation_file, output_file_header, kernel_launch_latency)

                
def main():
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python process_accelsim_power_output.py <input_directory> [input_file]")
        sys.exit(1)
    input_dir = sys.argv[1]

    if len(sys.argv) == 3:
        file = sys.argv[2]
        process_file(os.path.join(input_dir,file))
    else:
        process_files(input_dir)

        

if __name__ == "__main__":
    main()
