export BASH_ROOT="$( cd "$( dirname "$BASH_SOURCE" )" && pwd )"

<<<<<<< HEAD
rm -rf $BASH_ROOT/nvbit_release
wget https://github.com/NVlabs/NVBit/releases/download/1.5.3/nvbit-Linux-x86_64-1.5.3.tar.bz2
tar -xf nvbit-Linux-x86_64-1.5.3.tar.bz2 -C $BASH_ROOT
rm nvbit-Linux-x86_64-1.5.3.tar.bz2
=======
if [ ! -d $DATA_ROOT ]; then
    wget https://github.com/NVlabs/NVBit/releases/download/1.5.3/nvbit-Linux-ppc64le-1.5.3.tar.bz2
    tar -xf nvbit-Linux-ppc64le-1.5.3.tar.bz2 -C $BASH_ROOT
    rm nvbit-Linux-ppc64le-1.5.3.tar.bz2
fi
>>>>>>> 7e02543 (Update Summit repo things April 3rd)


