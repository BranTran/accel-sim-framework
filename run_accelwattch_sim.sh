#!/bin/bash

# Check if a directory argument was provided
if [ -z "$1" ]; then
    echo "Error: No directory provided."
    echo "Usage: $0 <directory>"
    exit 1
fi

directory=$1

# Check if the provided directory exists
if [ ! -d "$directory" ]; then
    echo "Error: The directory '$directory' does not exist."
    exit 1
fi

echo "Searching for run_sim.sh scripts in $directory..."

# Get the current working directory
cwd=$(pwd)

# Generate a list of file paths containing "run_sim.sh"
file_list=$(find "$directory" -name "run_sim.sh")

# Check if any run_sim.sh files were found
if [ -z "$file_list" ]; then
    echo "No run_sim.sh scripts found in the directory '$directory'."
    exit 0
fi

# Loop over the file list
for file in $file_list; do
    # Get the directory containing the current file
    file_dir=$(dirname "$file")

    # Check if the file is executable
    if [ ! -x "$file" ]; then
        echo "Warning: The file $file is not executable. Skipping."
        continue
    fi

    # Change to the directory containing the file
    cd "$file_dir" || { echo "Error: Failed to cd into $file_dir"; exit 1; }

    echo "Launching run_sim.sh in $file_dir..."

    # Execute the run_sim.sh script
    ./run_sim.sh || echo "Warning: Execution of $file failed."

    # Return to the original working directory
    cd "$cwd" || { echo "Error: Failed to return to $cwd"; exit 1; }
done

echo "Finished executing all run_sim.sh scripts."

