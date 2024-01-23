# Artifact: Smart Contract and DeFi Security Tools: Do They Meet the Needs of Practitioners?

This artifact complements the ICSE'24 paper titled "Smart Contract and DeFi Security Tools: Do They Meet the Needs of Practitioners?" by providing comprehensive resources for reproducing and extending its research findings. The artifact includes 'retro.db', a database of 127 DeFi attacks discussed in sections 4.1 and 4.2 of the paper. This database comprises data on the attacks and the outcomes derived from various analysis tools applied to the vulnerable contracts. Additionally, it provides thorough instructions on how to reapply these tools to the dataset, as well as guidance on integrating and running additional tools. Finally, it includes anonymized responses from the survey participants, which are used to recreate the analysis presented in sections 4.3, 4.4, and 4.5. 

## Purpose

The purpose of the artifact is to ensure that researchers and practitioners can validate the findings of our work and further build upon them.

Badges:

* Available
* Reusable

## Provenance

The artifact can be downloaded from <https://zenodo.org/records/10435996>. 
The artifact consists:

* `paper.pdf`: The ICSE'24 paper.
* `README.md`: The artifact's README, containing a description and all relevant instructions.
* `sc-defi-security.zip`: A zip of the directory containing all data and software for reproducing and extending the paper's results. The most updated version is available at <https://github.com/StefanosChaliasos/sc-defi-security>.

When you download the artifact remember to extract `sc-defi-security.zip`

__NOTE: The Zenodo version of the artifact is archived and should be the one evaluated by reviewers.__

## License

The license of the artifact can be found in `sc-defi-security/LICENSE.md`.

## Data

The artifact includes data from the analysis of the 127 DeFi attacks and the survey responses.

### Automated Analysis Data:

* `sc-defi-security/dataset/data`: Contains the raw data.
* `sc-defi-security/dataset/data/sources/{eth,bsc}.txt`: Addresses of exploitable smart contracts deployed on Ethereum (ETH) and Binance Smart Chain (BSC).
* `sc-defi-security/dataset/data/vyper/{eth,bsc}.txt`: Addresses of smart contracts written in Vyper.
* `sc-defi-security/dataset/data/proxy/{eth,bsc}.txt`: Addresses of unresolved proxy smart contracts.
* `sc-defi-security/dataset/data/contracts/bytecodes/{eth,bsc}/0x.*.bin`: Files containing the bytecode of the smart contracts.
* `sc-defi-security/dataset/data/contracts/sources/{eth,bsc}/0x.*.json`: The responses from BSCScan and Etherscan.
* `sc-defi-security/dataset/data/contracts/sources/{eth,bsc}/0x.*.sol`: The source code of the contracts. For multiple files, use `scripts/flattening.sh` to merge them.
* `sc-defi-security/dataset/data/cause_to_vuln_map.csv`: Mapping of SOK's cause names to the current vulnerability classification.
* `sc-defi-security/dataset/data/sc_vuln_to_vuln_map.csv`: Mapping of vulnerability names used by tools to the current classification.
* `sc-defi-security/dataset/data/vuln_map.csv`: Classification of vulnerabilities.
* `sc-defi-security/dataset/data/tools.csv`: Tools used for smart contract analysis.
* `sc-defi-security/dataset/database/defi_sok.db`: The database from the SoK paper.
* `sc-defi-security/dataset/database/retro.db`: An SQLite database containing all results.
* `sc-defi-security/dataset/database/retro.pdf`: The database schema.
* `sc-defi-security/dataset/results`: SmartBugs' output on our contract corpus.
    * `sc-defi-security/dataset/results/results_source_bsc/`: BSC source code results.
    * `sc-defi-security/dataset/results/results_source_eth/`: Ethereum source code results.
    * `sc-defi-security/dataset/results/results_bytecode_bsc/`: BSC bytecode results.
    * `sc-defi-security/dataset/results/results_bytecode_eth/`: Ethereum bytecode results.

### Survey Data:

Filtered answers to demographic questions and text answers provided by practitioners are excluded.

The results are in the following files:

* `responses/devs.csv`
* `responses/auditors.csv`
 
## Setup

To analyze the results of our analyses and surveys and reproduce the figures and conclusions in the paper, you will need:

* Python3
* pdflatex
* PyPI packages: `pip install numpy pandas matplotlib seaborn tabulate`

A Docker image with the necessary dependencies is also available. To install, navigate to `sc-defi-security` and run:

```
docker build -t sc-defi-security .
```

To run the Docker image:

```
docker run -it --rm --name artifact-sc-defi-sec \
    -v ./dataset:/home/dataset \
    -v ./security-tools-analysis:/home/security-tools-analysis \
    -v ./surveys:/home/surveys sc-defi-security
```

## Usage

This section provides instructions for both reproducing and validating the results 
presented in the paper, as well as for rerunning and extending the automated analysis.

### Reproducing Results

You can use the Docker container or install the dependencies locally for reproducing the results.

#### Section 4.1 and 4.2 Results

To reproduce the results for Section 4.1 and 4.2, navigate to the `security-tools-analysis` directory. This directory contains the following scripts:

* `scripts/attack_descriptive_statistics.py` => Figure 3
* `scripts/tool_effectiveness_and_damage.py` => Figure 6
* `scripts/summary_of_tool_results.py` => Figure 7

Next, we need to execute the scripts to generate the respective latex code.

```
cd security-tools-analysis
python scripts/attack_descriptive_statistics.py ../dataset/database/retro.db latexcode/descriptive_statistics.tex
python scripts/tool_effectiveness_and_damage.py ../dataset/database/retro.db latexcode/tool_effectiveness_and_damage.tex
python scripts/summary_of_tool_results.py ../dataset/database/retro.db latexcode/summary_of_tools.tex
```

The three `.tex` files produced by the scripts are exported in the latexcode directory.

Finally, we need to run `make` inside `latexcode` to generate the pdf of the respective figures.

```
cd latexcode && make
```

This will create three pdf:

* Figure 3 => `security-tools-analysis/latexcode/descriptive_statistics.pdf`
* Figure 6 => `security-tools-analysis/latexcode/tool_effectiveness_and_damage.pdf`
* Figure 7 => `security-tools-analysis/latexcode/summary_of_tools.pdf`

#### Section 4.3, 4.4, and 4.5 Results

To reproduce the results for Sections 4.3, 4.4, and 4.5, which include survey results, navigate to the surveys directory.

The surveys sent to developers and auditors are located in the questionnaires directory. Run make inside questionnaires to generate the PDFs of the respective questionnaires:

```
cd questionnaires && make
```

Then, the following files will be generated:

* `questionnaires/developers.pdf`
* `questionnaires/auditors.pdf`

To perform the analysis, execute the following scripts

```bash
# Figure 8
python scripts/tools_experience.py --devs_file_path responses/devs.csv \
--auditors_file_path responses/auditors.csv \
--output_path figures/tools_experience.pdf
# Figure 9
python scripts/tools_type.py --output_file figures/tools_type.pdf
# Figure 10
python scripts/tools_usage.py --devs_file_path responses/devs.csv \
--auditors_file_path responses/auditors.csv \
--output_file tools_usage.pdf
# Figure 11
python scripts/likert_figures.py --input_auditors_path responses/auditors.csv \
--input_devs_path responses/devs.csv \
--output_path_auditors figures/likert_auditors.pdf \
--output_path_devs figures/likert_devs.pdf
# Figure 12
python scripts/vulns.py --devs_file_path responses/devs.csv \
--auditors_file_path responses/auditors.csv \
--output_file figures/vulns.pdf
# Figure 12
python scripts/vulns_tools.py --input_auditors_path responses/auditors.csv \
--input_devs_path responses/devs.csv \
--output_path figures/vulns_tools.pdf
```

The scripts will generate the following:

|    script_name    |                 output file               | figure in paper |
|-------------------|-------------------------------------------|-----------------|
| tools_experience.py | tools_experience.pdf                    |    figure 8     |
| tools_type.py     | tools_type.pdf                            |    figure 9     |
| tools_usage.py    | tools.pdf                                 |   figure 10     |
| likert_figures.py | likert_devs.pdf & likert_audits.pdf       |   figure 11     |
| vulns.py & vulns_tools.py | vulns.pdf & vuln_tools.py         |   figure 12     |


### Re-running/Extending the Analyses (optional)

__NOTE 1: The previously mentioned Docker image is not suitable for this task and cannot be reused.__

__NOTE 2: Undertaking this step is optional and it is estimated to require approximately 48 hours.__

In this section, we describe the process for employing SmartBugs to replicate the analysis conducted using the following five tools: Oyente, Slither, Solhint, Mythril, and Confuzzius. The estimated time to complete this task is around 2 days.

To start, navigate to the dataset directory.

#### Extracting the tar

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

#### Sample analysis

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

#### Complete analysis

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
│   └── 20230613_1553.log
├── oyente
│   └── 20230613_1553
│       ├── 0x00cc9375a6579b5375813ed8d41eafda6d519409.hex
│       │   ├── result.json
│       │   ├── result.log
│       │   └── smartbugs.json
│       └── 0x00cc9375a6579b5375813ed8d41eafda6d519409.sol
│           ├── result.json
│           ├── result.log
│           └── smartbugs.json
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


#### Processing / Analysis

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

#### Adding more tools

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
