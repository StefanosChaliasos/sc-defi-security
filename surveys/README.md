# Survey Questions and Results

## Questions

You can find the surveys sent to developers and auditors under `questionnaires` directory. 
We need to run `make` inside `questionnaires` to generate the pdf of the respective questionnaire.

```
cd questionnaires && make
```

Then, the following files will be generated: 
* `questionnaires/developers.pdf`
* `questionnaires/auditors.pdf`

## Results

We have filtered out the answers to the demographic questions and the text answers provided by the practitioners.

The results can be found in the following files:

* `responses/devs.csv`
* `responses/auditors.csv`

## Analysis

### Installation

```
pip install numpy pandas matplotlib seaborn
```

### Instructions

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
