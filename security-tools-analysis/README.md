# Analysis of exploited smart contracts

This directory contains the scripts to reproduce figures Figures 3, 6, and 7, which are related to RQ1 and RQ2 in the paper.

There are three scripts:

* `scripts/attack_descriptive_statistics.py` => Figure 3
* `scripts/tool_effectiveness_and_damage.py` => Figure 6
* `scripts/summary_of_tool_results.py` => Figure 7

Each script takes as arguments the filepath to the database and a latex file to save the results.

## Requirements

```
pip install pandas tabulate
```

## Instructions

First, we need to execute the scripts to generate the respective latex code.

```
python scripts/attack_descriptive_statistics.py ../dataset/database/retro.db latexcode/descriptive_statistics.tex
python scripts/tool_effectiveness_and_damage.py ../dataset/database/retro.db latexcode/tool_effectiveness_and_damage.tex
python scripts/summary_of_tool_results.py ../dataset/database/retro.db latexcode/summary_of_tools.tex
```

The three .tex files produced by the scripts are exported in the latexcode directory. 

Finally, we need to run `make` inside `latexcode` to generate the pdf of the respective figures.

```
cd latexcode && make
```
