#!/bin/bash

# Generate a list of filepaths containing "slurm.sim"
file_list="$ACCELSIM_ROOT/../util/tracer_nvbit/tracer_benchmarks.cfg"
exec_file="$ACCELSIM_ROOT/../util/tracer_nvbit/template_validation_tracer_summit.lsf"

# Loop over the file list and submit each file to sbatch
while IFS= read -r bm
do
    echo "Launching sbatch for $exec_file on $bm"
    sed "s|REPLACE_BENCHMARK|$bm|g" $exec_file > tracer_${bm}.lsf #temp_exec_file
    #bsub temp_exec_file
done < $file_list;
#rm temp_exec_file
