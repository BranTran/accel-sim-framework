#!/bin/bash

BINDIR="$ACCELSIM_ROOT/../util/accelwattch/accelwattch_benchmarks/validation"
$BINDIR/backprop_k1 65536 &
sleep 20
nvidia-smi
pid=`nvidia-smi | grep backprop_k1 | awk '{ print $5 }'`
kill -9 $pid
