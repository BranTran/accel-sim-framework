#!/bin/bash

# Define the directories
directory1="$ACCELSIM_ROOT/../hw_run/traces/device-0/11.0"
directory2="$ACCELSIM_ROOT/../../accelwattch_traces/accelwattch_volta_traces/11.0"

# Define the output file
output_file="kernel_names.txt"

# Function to process a directory
process_directory() {
  local dir="$1"

  # Loop through the application folders
  for app_folder in "$dir"/*/*/; do
    if [ -d "$app_folder/traces" ]; then
      # Process the traces folder
      local traces_folder="$app_folder/traces"
      
      # Get the application name
      local app_name=$(basename "$(dirname "$app_folder")")
      echo $traces_folder    
      # Loop through the kernel-n.traceg files
      for trace_file in "$traces_folder"/kernel-*.traceg; do
        if [ -f "$trace_file" ]; then
          # Extract the kernel name from the first line
          kernel_name=$(head -n1 "$trace_file" | awk -F= '{print $2}' | awk '{$1=$1};1')

          # Construct the corresponding file path in the other directory
          local other_dir="${dir/$directory2/$directory1}"
          local other_trace_file="${trace_file/$dir/$other_dir}"
          
          # Check if the corresponding trace file exists in the other directory
          if [ -f "$other_trace_file" ]; then
            # Extract the kernel name from the corresponding trace file
            other_kernel_name=$(head -n1 "$other_trace_file" | awk -F= '{print $2}' | awk '{$1=$1};1')
            if [ "$kernel_name" != "$other_kernel_name" ]; then
                # Print the application, trace file, and both kernel names to the output file
                echo "$app_name,$trace_file,$kernel_name,$other_kernel_name" >> "$output_file"
            fi
          #else
          #  echo -e "$other_trace_file could not be found\n$trace_file\n\n"
          fi
        fi
      done
    fi
  done
}

# Process both directories
process_directory "$directory2"
