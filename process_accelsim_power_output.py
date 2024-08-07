import os
import csv
import sys
from multiprocessing import Pool

def process_file(input_file):
    if not input_file.endswith('.out') or 'accelsim' not in input_file:
        print(f"Input file is not an accelsim output file: {input_file}")
        return
    found_mcpat = False
    found_proc = False
    processor_info_list = []
    processor_info = []
    kernel_num = 1

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
    
    output_file = input_file.replace('.out', '_processed.csv')  # Generate output file name

        
    # Open the input file (with multiple kernels in it)
    with open(input_file, 'r') as infile:
        for line in infile:
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
            #I've finished getting data for one sample add it and go to next
            elif found_mcpat and found_proc:
                found_mcpat = False
                found_proc = False
                processor_info_list.append(processor_info)
                processor_info = []
            #These will come at the end of the kernel log
            elif 'gpu_sim_cycle' in line:
                sim_cycle = line.strip().split()[-1]
            elif 'gpu_sim_insn' in line:
                sim_instr = line.strip().split()[-1]
                # Now that we are at the end of a kernel
                # Open the output CSV file for writing output for a particular kernel
                output_file = output_file.replace('processed', f'processed_k{kernel_num}_{sim_cycle}cycle_{sim_instr}instr')
                with open(output_file, 'w', newline='') as csvfile:
                    writer = csv.writer(csvfile)
                    writer.writerow(row_header)  # Write CSV header
                    for row in processor_info_list:
                        writer.writerow(row)
                #Move on to the next kernel
                kernel_num += 1


def process_files(input_dir):
    files = [os.path.join(input_dir, filename) for filename in os.listdir(input_dir)]
    with Pool() as pool:
        pool.map(process_file, files)
                
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
