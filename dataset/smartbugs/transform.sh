#!/bin/bash

# Check if all arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: ./transform.sh <results_dir> <contracts_dir> <new_results_dir>"
    exit 1
fi

results_dir="$1"
contracts_dir="$2"
new_results_dir="$3"

eth_subdir="eth"
bsc_subdir="bsc"

bytecodes_eth_dir="$contracts_dir/bytecodes/$eth_subdir"
bytecodes_bsc_dir="$contracts_dir/bytecodes/$bsc_subdir"
sources_eth_dir="$contracts_dir/sources/$eth_subdir/sol"
sources_bsc_dir="$contracts_dir/sources/$bsc_subdir/sol"

# Check if the first argument is a directory
if [ ! -d "$results_dir" ]; then
    echo "Error: '$results_dir' is not a directory."
    exit 1
fi

# Check if the second argument is a directory containing the required dirs
if [ ! -d "$contracts_dir" ]; then
    echo "Error: '$contracts_dir' does not exist."
    exit 1
fi

if [ ! -d "$bytecodes_eth_dir" ]; then
    echo "Error: '$bytecodes_eth_dir' does not exist."
    exit 1
fi

if [ ! -d "$bytecodes_bsc_dir" ]; then
    echo "Error: '$bytecodes_bsc_dir' does not exist."
    exit 1
fi

if [ ! -d "$sources_eth_dir" ]; then
    echo "Error: '$sources_eth_dir' does not exist."
    exit 1
fi

if [ ! -d "$sources_bsc_dir" ]; then
    echo "Error: '$sources_bsc_dir' does not exist."
    exit 1
fi


# Loop through the results directory
for tool_dir in "$results_dir"/*; do
    # Skip logs directory
    if [[ "$tool_dir" == */logs ]]; then
        continue
    fi
    
    # Get the tool name
    tool=$(basename "$tool_dir")
    
    # Loop through the tool directory
    for timestamp_dir in "$tool_dir"/*; do
        # Get the timestamp
        timestamp=$(basename "$timestamp_dir")
        
        # Loop through the contracts directory
        for contract_dir in "$timestamp_dir"/*; do
            # Skip non-directory entries
            if [ ! -d "$contract_dir" ]; then
                continue
            fi
            
            # Get the contract directory name
            contract=$(basename "$contract_dir")
            
            # Extract the file type
            file_type="${contract##*.}"

            # Extract the file name without the extension
            file_name="${contract%.*}"
            
            if [ "$file_type" = "hex" ]; then
                # Check if the contract exists 
                if [ -f "$bytecodes_eth_dir/$contract" ] && [ -f "$bytecodes_bsc_dir/$contract" ]; then
                    echo "Contract '$contract' exists in both bytecodes_eth_dir and bytecodes_bsc_dir. Exiting..."
                    exit 1
                elif [ ! -f "$bytecodes_eth_dir/$contract" ] && [ ! -f "$bytecodes_bsc_dir/$contract" ]; then
                    echo "Contract '$contract' does not exist in bytecodes_eth_dir or bytecodes_bsc_dir. Exiting..."
                    exit 1
                fi
                
                # Determine the chain based on the contract's existence
                if [ -f "$bytecodes_eth_dir/$contract" ]; then
                    chain="eth"
                else
                    chain="bsc"
                fi
                
                # Create the new directory in results_bytecodes
                new_dir="$new_results_dir/results_bytecode_$chain/$tool/$timestamp/$file_name"
                mkdir -p "$new_dir"
                
                # Copy everything from the contract directory to the new directory
                cp -R "$contract_dir"/* "$new_dir/"
            elif [ "$file_type" = "sol" ]; then
                # Check if the contract exists 
                if [ -f "$sources_eth_dir/$contract" ] && [ -f "$sources_bsc_dir/$contract" ]; then
                    echo "Contract '$contract' exists in both sources_eth_dir and sources_bsc_dir. Exiting..."
                    exit 1
                elif [ ! -f "$sources_eth_dir/$contract" ] && [ ! -f "$sources_bsc_dir/$contract" ]; then
                    echo "Contract '$contract' does not exist in sources_eth_dir or sources_bsc_dir. Exiting..."
                    exit 1
                fi
                
                # Determine the chain based on the contract's existence
                if [ -f "$sources_eth_dir/$contract" ]; then
                    chain="eth"
                else
                    chain="bsc"
                fi
                
                # Create the new directory in results_bytecodes
                new_dir="$new_results_dir/results_source_$chain/$tool/$timestamp/$file_name"
                mkdir -p "$new_dir"
                
                # Copy everything from the contract directory to the new directory
                cp -R "$contract_dir"/* "$new_dir/"
            else
                echo "File type '$file_type' is not supported. Skipping..."
                continue
            fi
        done
    done
done
# Add your logic to perform the transformation of results here

echo "Transformation completed successfully!"
