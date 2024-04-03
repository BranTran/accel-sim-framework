#!/bin/bash

#Setting up environment variables
export CUDA_INSTALL_PATH=$(dirname "$(dirname `which nvcc`)")
export PATH=$CUDA_INSTALL_PATH/bin:$PATH

#Setup environment variables with source
source ./gpu-simulator/setup_environment.sh
echo $ACCELSIM_ROOT

config_file=${1}
source_dir=${2}
dest_dir=${3}
while IFS= read -r benchmark; do
    echo "Launching Accelwattch simulator for $benchmark"
    
    # Replace spaces with underscores in the benchmark name 
    replace_name=$(echo "$benchmark" | tr ' ' '_')
    $ACCELSIM_ROOT/../util/job_launching/run_simulations.py \
    -B ${replace_name} -a -C QV100-Accelwattch_SASS_SIM \
    -T $ACCELSIM_ROOT/../hw_run/${source_dir}/ -N ${dest_dir} \
    -l local -r $ACCELSIM_ROOT/../accelwattch_runs/${dest_dir} \
    -n
done < "$config_file"
