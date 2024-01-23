# Dataset

This directory contains the dataset for our analyses, as well as the code for 
retrieving the final database built on top of the database from the 
[SOK](https://eprint.iacr.org/2022/1773) paper. It includes all the results of our analyses.

## Contents

- `data`: Contains the raw data.
- `data/sources/{eth,bsc}.txt`: Addresses of exploitable smart contracts deployed on ETH and BSC.
- `data/vyper/{eth,bsc}.txt`: Addresses of smart contracts written in Vyper.
- `data/proxy/{eth,bsc}.txt`: Addresses of unresolved proxy smart contracts.
- `data/contracts/bytecodes/{eth,bsc}/0x.*.bin`: Files containing the bytecode of the smart contracts.
- `data/contracts/sources/{eth,bsc}/0x.*.json`: The responses from BSCScan and Etherscan.
- `data/contracts/sources/{eth,bsc}/0x.*.sol`: The source code of the contracts. In cases where the blockchain explorer returned multiple files, we used `scripts/flattening.sh` to merge them into a single file.
- `data/cause_to_vuln_map.csv`: Mapping of SOK's cause names to the current classification of vulnerabilities.
- `data/sc_vuln_to_vuln_map.csv`: Mapping of vulnerability names used by tools to the current classification of vulnerabilities.
- `data/vuln_map.csv`: Classification of vulnerabilities.
- `data/tools.csv`: Tools used to analyze smart contracts.
- `database/defi_sok.db`: [The database of the SoK paper](https://arxiv.org/pdf/2208.13035.pdf).
- `database/retro.db`: An SQLite database containing all the results.
- `database/retro.pdf`: The schema of the database.
- `results`: SmartBugs' output on our contract corpus.
  - `results/results_source_bsc/`: BSC source code results. 
  - `results/results_source_eth/`: Ethereum source code results. 
  - `results/results_bytecode_bsc/`: BSC bytecode results. 
  - `results/results_bytecode_eth/`: Ethereum bytecode results. 
- `scripts`: Scripts for processing and gathering data.
- `docker_images`: Directory containing Docker images to run with SmartBugs.
- `smartbugs`: Fork of the SmartBugs framework.

In the following, we present how to reconstruct and replicate the existing study. If you want to perform further analyses on the results or reproduce the final results, you can refer to the `analysis` directory. We provide instructions on how to re-run the tools, post-process the results, use them to feed the final database including all the results, and finally, how to include more tools.

### Re-running the tools

In this section, we outline how to utilize SmartBugs to replicate the findings of the following five tools: Oyente, Slither, Solhint, Mythril, and Confuzzius (estimated time: `2` days).

To begin, you need extract the Docker images for the five tools and import them into Docker.

# Extract the tar

```
tar xvf docker_images.tar.gz
# Load the images
cd docker_images
docker load -i confuzius_4315fb7.tar
docker load -i oyente_4315fb7.tar
docker load -i solhint_3.3.8.tar
docker load -i mythril_0.23.15.tar
docker load -i slither_0.8.3.tar
cd ..
```
Next, let's proceed with the installation of SmartBugs.

Change to the "smartbugs" directory:

```
cd smartbugs
```

Run the setup script to configure the virtual environment:

```
install/setup-venv.sh
```

SmartBugs offers two modes: one for analyzing binary files and another for analyzing source files. Mythril and Oyente can analyze both source code and binary files, while all five tools (Solhint, Slither, Oyente, Mythril, and Confuzzius) can analyze source code files.

For example, to run Oyente in binary mode with a timeout of 3600 seconds and analyze a specific contract, use the following command:

```
./smartbugs -t oyente \
    -f ../data/contracts/bytecodes/bsc/0x00cc9375a6579b5375813ed8d41eafda6d519409.hex \ 
    --processes 1 --json --timeout 3600 --runtime
```

The above command will analyze the specified contract using Oyente in binary mode. The results will be written to `results/oyente/<timestamp>/<contract>`.

Similarly, you can analyze the source code of the same contract using Solhint with the following command:

```
./smartbugs -t solhint \
    -f ../data/contracts/sources/bsc/sol/0x00cc9375a6579b5375813ed8d41eafda6d519409.sol \
    --processes 1 --json --timeout 3600
```

To perform all the analyses, you can use the `run.sh` script. This script will take approximately `2` days when using `7` cores. You can modify the number of cores within the `run.sh` script to match your system's specification

```
# Remember to clean up the results
rm -rf results
# Run the tools
run.sh
```

The results will be in a format similar to the following:

```
results
├── logs
│   └── 20230613_1553.log
├── oyente
│   └── 20230613_1553
│       ├── 0x00cc9375a6579b5375813ed8d41eafda6d519409.hex
│       │   ├── result.json
│       │   ├── result.log
│       │   └── smartbugs.json
│       └── 0x00cc9375a6579b5375813ed8d41eafda6d519409.sol
│           ├── result.json
│           ├── result.log
│           └── smartbugs.json
└── solhint
    └── 20230613_1553
        └── 0x00cc9375a6579b5375813ed8d41eafda6d519409.sol
            ├── result.json
            ├── result.log
            └── smartbugs.json
```

Finally, we need to transform the results into the directory format that our parser can interpret, similar to the following structure:

```
results/results_bytecode_bsc/mythril/<timestamp>/<contract>/<results>
```

To do so, you can use the `transform.sh` script:

```
./transform.sh results ../data/contracts/ new_results
# Most probably mythril is saved as mythril-0.23.15 so we want to rename it
mv new_results/results_bytecode_bsc/mythril-0.23.15/ new_results/results_bytecode_bsc/mythril
mv new_results/results_bytecode_eth/mythril-0.23.15/ new_results/results_bytecode_eth/mythril
mv new_results/results_source_eth/mythril-0.23.15/ new_results/results_source_eth/mythril
mv new_results/results_source_bsc/mythril-0.23.15/ new_results/results_source_bsc/mythril
```

We can then use the `new_results` directory in place of `dataset/results` to perform our analysis.


### Processing / Analysis

In this section, we outline the steps to prepare the `retro.db` database using `defi_sok.db` and the results obtained from the security tools. We also provide instructions on how to re-run the tools (estimated time 5 minutes). 

First, we have to create `retro.db` and add new tables.

```
# remove old files
rm -rf database/retro.db 
# Copy db
cp database/defi_sok.db database/retro.db
sqlite3 database/retro.db < scripts/amendments.sql
```

Next, we'll update the `VulnerableContract` table with`is_proxy` and `has_source`.

```
python scripts/update_db_vulnerable_contracts.py \
    data/proxy/eth.txt data/proxy/bsc.txt \
    data/sources/eth.txt data/sources/bsc.txt \
    data/vyper/eth.txt data/vyper/bsc.txt \
    database/retro.db
sqlite3 database/retro.db < update_commands.sql
rm update_commands.sql
```

Then we need to parse the results and generate CSV files with the results.

```
python scripts/parser.py db database/retro.db csvs \
    results/results_bytecode_bsc results/results_bytecode_eth \
    results/results_source_bsc results/results_source_eth
```

Following that we have to import the data into the tables.

```
sqlite3 database/retro.db < csvs/populate.sql
rm -rf csvs
```

Finally, we need to import the mapping between `Cause`, 
`SmartContractVulnerabilities`, and `VulnerabilitiesMap`.
This script will also perform various sanity checks.

```
python scripts/import_mapping.py \
    data/cause_to_vuln_map.csv \
    data/sc_vuln_to_vuln_map.csv \
    database/retro.db
sqlite3 database/retro.db < mapping_commands.sql
rm mapping_commands.sql
```

### Adding more tools

To add support for a new tool that is included in SmartBugs, follow these steps:

1. Include the tool name in `data/tools.csv`.
2. Run the analyses through SmartBugs.
3. Implement a parser in `scripts/result_parsing/<tool_name>.py` that extends the `Base` class from `scripts/result_parsing/base.py`.
   - You can refer to `scripts/result_parsing/mythril.py` as an example parser for Mythril.
   - The parser should contain a `vuln_map` dictionary that maps vulnerability names from the tool to the vulnerability categories in scope.
   - Include a list called `errors` that contains potential error messages.
   - Implement a function called `process_analysis` that stores the number of vulnerabilities per contract in a dictionary.
4. Include the new parser in the `PARSERS` dictionary in `scripts/parser.py`, after importing it.

If a tool is not included in SmartBugs, you need to first include it in the SmartBugs framework: [https://github.com/smartbugs/smartbugs](https://github.com/smartbugs/smartbugs).
