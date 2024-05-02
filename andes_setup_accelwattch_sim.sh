#!/bin/bash

#Setting up environment variables
export CUDA_INSTALL_PATH=$(dirname "$(dirname `which nvcc`)")
export PATH=$CUDA_INSTALL_PATH/bin:$PATH

#Setup environment variables with source
source ./accel-sim-framework/gpu-simulator/setup_environment.sh
echo $ACCELSIM_ROOT

config_file=${1}
while IFS= read -r benchmark; do
    echo "Launching Accelwattch simulator for $benchmark"
    
    # Replace spaces with underscores in the benchmark name
    replace_name=$(echo "$benchmark" | tr ' ' '_')
    $ACCELSIM_ROOT/../util/job_launching/run_simulations.py \
    -B ${replace_name} -a -C Tesla_V100-Accelwattch_SASS_SIM \
    -T $ACCELSIM_ROOT/../hw_run/ubench_1iter/ -N ubench_1iter \
    -l local -r $ACCELSIM_ROOT/../accelwattch_runs/ubench_1iter \
    -n
done < "$config_file"
