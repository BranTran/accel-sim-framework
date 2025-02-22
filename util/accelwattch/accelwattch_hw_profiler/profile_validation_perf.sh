#!/bin/bash

# Copyright (c) 2018-2021, Vijay Kandiah, Junrui Pan, Mahmoud Khairy, Scott Peverelle, Timothy Rogers, Tor M. Aamodt, Nikos Hardavellas
# Northwestern University, Purdue University, The University of British Columbia
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer;
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution;
# 3. Neither the names of Northwestern University, Purdue University,
#    The University of British Columbia nor the names of their contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

root_dir=`pwd`
if [ "$GPGPUSIM_SETUP_ENVIRONMENT_WAS_RUN" != "1" ]; then
    echo "ERROR - Please run setup_environment before running this script. For Example source $ACCELSIM_ROOT/gpu-simulator/setup_environment.sh"
    exit
fi

if [ "${1}" == "" ]; then
    echo "Please enter GPU Device ID. ./profile_validation_perf.sh <GPU_devid>"
    exit 1
fi
DEVID=${1}

runs_dir="$ACCELSIM_ROOT/../hw_run/device-${1}/${CUDA_VERSION}"
if [ -d ${runs_dir} ] ; then
	rm -r ${runs_dir}
fi
export CUDA_VISIBLE_DEVICES=$DEVID
$ACCELSIM_ROOT/../util/hw_stats/run_hw.py -D $DEVID -B rodinia-3.1_validation_hw,parboil_validation,cuda_samples_11.0_validation,cutlass_5_trace_validation,cudaTensorCoreGemm_validation --collect other_stats --nsight_profiler --disable_nvprof
$ACCELSIM_ROOT/../util/accelwattch/accelwattch_hw_profiler/gen_hw_perf_csv.py -d ${runs_dir}

<<<<<<< HEAD:util/accelwattch/accelwattch_hw_profiler/profile_validation_perf.sh
mv ${root_dir}/hw_perf.csv $ACCELSIM_ROOT/../util/accelwattch/accelwattch_hw_profiler/hw_perf.csv
echo "y" | cp $ACCELSIM_ROOT/../util/accelwattch/accelwattch_hw_profiler/hw_perf.csv $ACCELSIM_ROOT/gpgpu-sim/configs/tested-cfgs/SM7_QV100/hw_perf.csv
=======
mv ${root_dir}/hw_perf.csv $ACCELSIM_ROOT/../accelwattch_hw_profiler/hw_perf.csv
echo "y" | cp $ACCELSIM_ROOT/../accelwattch_hw_profiler/hw_perf.csv $ACCELSIM_ROOT/gpgpu-sim/configs/tested-cfgs/Tesla_V100-SMX2-16GB/hw_perf.csv
>>>>>>> 7e02543 (Update Summit repo things April 3rd):accelwattch_hw_profiler/profile_validation_perf.sh
echo "Done"

