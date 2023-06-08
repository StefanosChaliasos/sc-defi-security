#!/bin/bash
# Flattening contracts retrieved from etherscan and bscscan
#
# You should have installed poanetwork/solidity-flattener and jq before running 
# this script
#
# npm i @poanet/solidity-flattener
# brew install jq or apt install jq
#
# Example run:
# ./scripts/flattening.sh data/sources/bsc/sol/ data/sources/bsc/json/ 
#
# Check errors:
# cat flattening_logs

if [ $# -lt 2 ]; then
    echo "$0": usage: flattening.sh sol_directory json_directory
    exit 1
fi

SOL=$1
JSON=$2

for contract in $(ls $SOL); do
    logs=flattening_logs
    path=$SOL/$contract
    if [[ -d "$path" ]]; then
        json_path=$JSON/$(echo $contract | sed 's/\.sol/\.json/g')
        echo "Processing $path"
        # TODO use sed if linux
        contract_name=$(jq '.ContractName' $json_path | sed 's/"//g')
        gsed -i 's/import *".*\//import ".\//g' $path/*
        gsed -i "s/import *'.*\//import '.\//g" $path/*
        # set contract_name hardcoded when we cannot detect it.
        #contract_name=xWinFarmVaultSingleFile
        ./node_modules/.bin/poa-solidity-flattener $path/$contract_name.sol > flat_out 2>&1
        # We do not get the contract name correctly
        # i.e., the contract name is not the same as the solidity file name
        # that contains that contract.
        # TODO We could try to detect the correct one with grep
        if grep -q "Error:" flat_out; then
            echo "poa-solidity-flattener error occured"
            echo "File: $path" >> $logs
            cat flat_out >> $logs
        # We don't handle cases like the following: 
        # import {OwnableUpgradeable} from "./access/OwnableUpgradeable.sol";
        # We can then fix thoses cases manually 
        # TODO fix such imports
        elif grep -q "SOURCE FILE WAS NOT FOUND" flat_out; then
            echo "SOURCE FILE WAS NOT FOUND"
            echo "File: $path" >> $logs
            cat flat_out >> $logs
        else
            rm -rf $path && mv out/${contract_name}_flat.sol $path && rm -rf out
        fi
        rm flat_out
    fi
done
