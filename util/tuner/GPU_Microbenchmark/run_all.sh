#! /bin/sh

THIS_DIR="$( cd "$( dirname "$BASH_SOURCE" )" && pwd )"
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

<<<<<<< HEAD
cd ${SCRIPT_DIR}/bin/
=======
echo $THIS_DIR
echo $SCRIPT_DIR

cd ${SCRIPT_DIR}/bin/
pwd
>>>>>>> 7e02543 (Update Summit repo things April 3rd)
for f in ./*; do
    echo "running $f microbenchmark"
    $f
    echo "/////////////////////////////////"
done

