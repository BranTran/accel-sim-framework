#! /bin/sh

THIS_DIR="$( cd "$( dirname "$BASH_SOURCE" )" && pwd )"
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo $THIS_DIR
echo $SCRIPT_DIR

cd ${SCRIPT_DIR}/bin/
pwd
for f in ./*; do
    echo "running $f microbenchmark"
    $f
    echo "/////////////////////////////////"
done

