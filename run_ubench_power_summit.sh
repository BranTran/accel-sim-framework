#!/bin/bash

# Directory containing the files
#directory="$ACCELSIM_ROOT/../accelwattch_runs"
directory=${1}
config_file=${2}
echo "Going into $directory and sbatch'ing all .cfg scripts"
# Generate a list of filepaths containing "slurm.sim"
# file_list=$(find "$directory" -name "ubench_split*.cfg" -printf "%f\n")
file_list=$(find "$directory" -name "$config_file" -printf "%f\n")

exec_file="template_ubench_power.lsf"

# Loop over the file list and submit each file to sbatch
for file in $file_list; do
        echo "Launching sbatch for $exec_file on $file"
        sed "s|REPLACE_TEXT|$file|g" $exec_file > temp_exec_file
        bsub temp_exec_file
done
