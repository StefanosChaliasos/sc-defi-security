# Smart Contract and DeFi Security Tools: Do They Meet the Needs of Practitioners?

This project delves into the efficacy and adoption of security tools tailored for smart contracts and DeFi applications. Utilizing a dataset of 127 real-world attacks sourced from [sok.defi.security](sok.defi.security) and executed through [SmartBugs](https://github.com/smartbugs/smartbugs), we conducted an exhaustive analysis of five tools. The outcome? Only 32 of these attacks are in the tools' scope.  Furthermore, only a mere 11 vulnerabilities were detectable, all of which were reentrancy issues. Nonetheless, the current completely automated and easy-to-use tools could have mitigated a staggering $149 million in losses.

Additionally, we gathered valuable feedback via surveys from 49 developers and auditors, seeking their perspectives on smart contract security tools. Their consensus was clear: there's a critical demand for tools that support a broader range of vulnerabilities. There was significant emphasis on the promise held by semi-automated tools (e.g., invariant fuzzers), with their prowess in detecting logic bugs.

Finally, it's important to benchmark tools against real-world datasets. There's also a need to push toward research that broadens vulnerability detection scopes and focuses more on semi-automated tools adept at identifying logic-related vulnerabilities.

## Contents

This project consists of three main parts: `Dataset`, `Analysis`, and `Surveys`.

### Dataset

The `dataset` directory contains all the raw data used to perform the empirical analysis of the automated security tools, as well as the results obtained from using those tools. Additionally, it includes an SQLite database located at `dataset/database/retro.db`, which encompasses all the data used for the analysis.

### Analysis

The `security-tools-analysis` directory comprises scripts that can be used to process the results of the tools on the dataset. The analysis relies on the `dataset/database/retro.db` file.

### Survey

The `survey` directory contains the questionnaires sent to developers and auditors, the raw data from the surveys, and scripts to analyze the data.

## Contributing

We welcome all types of contributions to our project, including but not limited to:

* Adding support for more tools through SmartBugs
* Adding new bugs in the dataset. This should happen in the [original dataset repository](https://github.com/Research-Imperium/SoKDeFiAttacks)
* Suggesting improvements/extensions to the existing classification of the bugs
* Correcting mislabeled bugs

__NOTE:__ Once more tools or more vulnerabilities are added, the analyses could be re-executed.

## Cite

* Stefanos Chaliasos, Marcos Antonios Charalambous, Liyi Zhou, Rafaila Galanopoulou, Arthur Gervais, Dimitris Mitropoulos, and Benjamin Livshits. [Smart Contract and DeFi Security: Insights from Tool Evaluations and Practitioner Surveys](https://arxiv.org/pdf/2304.02981.pdf). In 46rd International Conference on Software Engineering, ICSE '24, 14-20 April 2024.

If you use the dataset, please cite the following work.

* Liyi Zhou, Xihan Xiong, Jens Ernstberger, Stefanos Chaliasos, Zhipeng Wang, Ye Wang, Kaihua Qin, Roger Wattenhofer, Dawn Song, Arthur Gervais. [SoK: Decentralized Finance (DeFi) Attacks](https://arxiv.org/pdf/2208.13035). In 2023 IEEE Symposium on Security and Privacy (SP), May 2023.

## License

For the code/scripts, check `LICENSE`. For re-using the data from the original dataset, you should follow the instructions from the [original repository](https://github.com/Research-Imperium/SoKDeFiAttacks/blob/main/README.md).
