#! /bin/bash
#SBATCH --nodes=4
#SBATCH -t 24:00:00
#SBATCH -p batch
#SBATCH -A gen150
#SBATCH -J AccelSim_PowerCycle_Aggregation
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=bqtran2@wisc.edu
#SBATCH --export=ALL

# Get the target directory from the command-line argument
target_directory=${1}

# Check if target_directory is a directory
if [ ! -d "$target_directory" ]; then
    echo "Error: '$target_directory' is not a directory. Exiting."
    exit 1
fi

# Execute the loop
for file in $(ls ${target_directory}); do
    srun -n 1 -N 1 -c 1 --exclusive python process_accelsim_power_output.py $target_directory $file &
done

# Wait for all background processes to finish
wait
