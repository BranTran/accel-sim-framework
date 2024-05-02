#!/bin/bash

# Directory containing the files
#directory="$ACCELSIM_ROOT/../accelwattch_runs"
directory=${1}
echo "Going into $directory and sbatch'ing all slurm.sim scripts"
# Generate a list of filepaths containing "slurm.sim"
file_list=$(find "$directory" -name "slurm.sim")

# Loop over the file list and submit each file to sbatch
for file in $file_list; do
	echo "Launching sbatch for $file"
	sbatch "$file"
done
