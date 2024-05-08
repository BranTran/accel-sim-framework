#! /bin/bash

# Get the target directory from the command-line argument
target_directory=${1}

out_dir="process_accelwattch_output"

if [ ! -d "$out_dir" ]; then
    mkdir $out_dir
fi

# Check if target_directory is a directory
if [ ! -d "$target_directory" ]; then
    echo "Error: '$target_directory' is not a directory. Exiting."
    exit 1
fi

# Execute the loop
for file in $(ls ${target_directory}); do
    echo "Working on $file"
    python process_accelsim_power_output.py $target_directory $file
done

mv ${target_directory}/*csv $out_dir
