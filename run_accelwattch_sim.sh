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
email=bqtran2@wisc.edu
exec_file="justrun.sh" # This is for accelwattch simulations
#exec_file="run.sh" #This is for nvbit tracing
# Generate a list of file paths containing "run_sim.sh"
file_list=$(find "$directory" -name $exec_file)

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

    echo "Launching $exec_file in $file_dir..."

    # Execute the run_sim.sh script
    # $exec_file > accelwattch_sim_output.log || echo "Warning: Execution of $file failed."
    $exec_file
   # && echo "$file" | mail -s "Finished $file" $email || echo "Warning: Execution of $file failed." | mail -s "Failed: $file" $email

    # Return to the original working directory
    cd "$cwd" || { echo "Error: Failed to return to $cwd"; exit 1; }
done

echo "Finished executing all run_sim.sh scripts." | mail -s "Finished All Run" $email

