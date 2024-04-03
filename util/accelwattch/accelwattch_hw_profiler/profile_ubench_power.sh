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

if [ "$GPGPUSIM_SETUP_ENVIRONMENT_WAS_RUN" != "1" ]; then
    echo "ERROR - Please run setup_environment before running this script"
    exit
fi

rate=100
samples=900
sleep_time=30

if [ "${1}" == "" ]; then
    echo "Please enter the GPU device ID;  For example: ./profile_ubench_power.sh 1"
    exit 1
fi
DEVID=${1}
UUID_list=(`nvidia-smi -L | awk '{print $NF}' | tr -d '[)]'`)
GPU_UUID=${UUID_list[${DEVID}]}

<<<<<<< HEAD:util/accelwattch/accelwattch_hw_profiler/profile_ubench_power.sh
SCRIPT_DIR=$ACCELSIM_ROOT/../util/accelwattch/accelwattch_hw_profiler
BINDIR="$ACCELSIM_ROOT/../util/accelwattch/accelwattch_benchmarks/microbenchmarks"
PROFILER="$SCRIPT_DIR/measureGpuPower"
UBENCH_FILE="$SCRIPT_DIR/ubench.cfg"

if [ -d $ACCELSIM_ROOT/../util/accelwattch/accelwattch_benchmarks/microbenchmarks ]; then
	cd $ACCELSIM_ROOT/../util/accelwattch/accelwattch_benchmarks
    ./extract_binaries.sh
=======
SCRIPT_DIR=$ACCELSIM_ROOT/../accelwattch_hw_profiler
BINDIR="$ACCELSIM_ROOT/../util/accelwattch/accelwattch_benchmarks/ubench_datatype" #microbenchmarks"
PROFILER="$SCRIPT_DIR/dumpGpuPower" #measureGpuPower"
UBENCH_FILE="$SCRIPT_DIR/${2}"

if [ ! -d $ACCELSIM_ROOT/../accelwattch_benchmarks/microbenchmarks ]; then
    echo "Could not find directory $ACCELSIM_ROOT/../accelwattch_benchmarks/microbenchmarks"
    exit 1
>>>>>>> 7e02543 (Update Summit repo things April 3rd):accelwattch_hw_profiler/profile_ubench_power.sh
fi
cd $SCRIPT_DIR

if [ -f $SCRIPT_DIR/$PROFILER ]; then
    make
fi

#If directories are not there, make them
if [ ! -d $SCRIPT_DIR/ubench_power_reports ]; then
    mkdir -p $SCRIPT_DIR/ubench_power_reports
fi

if [ ! -d $SCRIPT_DIR/ubench_profile_output ]; then
    mkdir -p $SCRIPT_DIR/ubench_profile_output
fi

#For five iterations
for run in {1..5}
do
    #For each config in the config file
    while IFS= read -r bm
    do  
        if [ `echo $bm | awk '{print NF}'` == "4" ]; then
            bm_name=`echo $bm | awk '{print $1"_"$2"_"$3"_"$4}'`
        else
            bm_name=`echo $bm | awk '{print $1"_"$2}'`
        fi
        echo "Starting profiling of $bm_name"
        mkdir -p $SCRIPT_DIR/ubench_power_reports/$bm_name/$GPU_UUID
        CUDA_VISIBLE_DEVICES=$DEVID $BINDIR/$bm & 
#        echo "Warming up..."
#        sleep $sleep_time
        "$PROFILER" -r "$rate" -n "$samples" -d "$DEVID" -o "$SCRIPT_DIR/ubench_power_reports/$bm_name/$GPU_UUID/run_$run.rpt" >> "$SCRIPT_DIR/ubench_profile_output/${bm_name}_${GPU_UUID}.txt"

        kill_name=`echo $bm | awk '{print $1}'`
        pid=`nvidia-smi | grep $kill_name | awk '{ print $5 }'`
        echo "Profiling concluded. Killing $bm_name with pid: $pid"
        #If the benchmark is still running, kill it
        if [ -n "$pid" ]; then
            kill -9 $pid
        fi
        
        echo "Sleeping..."
        sleep $sleep_time
    done < $UBENCH_FILE
done
