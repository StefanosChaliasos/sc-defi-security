import sqlite3
import pandas as pd
from collections import defaultdict
import argparse
import os
from tabulate import tabulate


def setup_db(db_path):
    """
    Set up SQLite database connection.

    Args:
        db_path (str): Path to the SQLite database file.

    Returns:
        Tuple: A tuple containing a connection object and a cursor object.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    return conn, cursor


def get_args():
    """
    Argument parsing.

    Returns:
        argparse.Namespace: Parsed command-line arguments.
    """
    parser = argparse.ArgumentParser(
        prog="attack descriptive statistics",
        description="Parse the results of the analysis tools and print their findings"
    )
    parser.add_argument(
        "db",
        help="The database file (note that you should provide valid inputs)."
    )
    parser.add_argument(
        "output",
        help="The output file."
    )
    return parser.parse_args()


def get_incident_per_bug_category(con):
    """
    Retrieve the number of incidents for each bug category.

    Args:
        con: SQLite database connection object.

    Returns:
        pandas.DataFrame: DataFrame containing the bug category, total incidents, and incident IDs.
    """
    query = """
    SELECT vuln_title, VulnerabilitiesMap.category, COUNT(DISTINCT I.incident_id) as total, GROUP_CONCAT(I.incident_title) as ids
    FROM VulnerabilitiesMap
    LEFT JOIN Cause C on VulnerabilitiesMap.vuln_map_id = C.vuln_map_id
    LEFT JOIN IncidentCause IC on C.cause_id = IC.cause_id
    LEFT JOIN Incident I on I.incident_id = IC.incident_id
    GROUP BY vuln_title
    ORDER BY total DESC
    """
    incidents_per_bug_category = pd.read_sql(query, con)
    incidents_per_bug_category['ids'] = incidents_per_bug_category['ids'].apply(lambda x: list(set([x for x in x.split(',')] if x is not None else [])))
    incidents_per_bug_category
    # 2. Only the categories we include in the study
    incidents_per_ic_bug_category = incidents_per_bug_category.loc[incidents_per_bug_category['category'].isin(['Smart Contract', 'Protocol'])]
    return incidents_per_ic_bug_category


def count_incidents_in_scope(con):
    """
    Count the number of incidents in scope.

    Args:
        con: SQLite database connection object.

    Returns:
        pandas.DataFrame: DataFrame containing the incident titles of incidents in scope.
        set: Set of incident titles in scope.
    """
    query = """
    SELECT DISTINCT incident_title
    FROM Incident
    JOIN IncidentCause IC on Incident.incident_id = IC.incident_id
    JOIN Cause C on C.cause_id = IC.cause_id
    JOIN VulnerabilitiesMap VM on C.vuln_map_id = VM.vuln_map_id
    WHERE VM.category in ('Smart Contract', 'Protocol')
    """
    count_incidents_in_scope = pd.read_sql(query, con)
    incidents = list(count_incidents_in_scope.incident_title)
    return count_incidents_in_scope, incidents


def get_tools(cur, incidents_per_ic_bug_category):
    """
    Retrieve the tools used for analysis.

    Args:
        cur: SQLite database cursor object.
        incidents_per_ic_bug_category: DataFrame containing the bug category, total incidents, and incident IDs.

    Returns:
        pandas.DataFrame: DataFrame containing the tools used for analysis for each bug category.
    """
    query = """
    SELECT vm.vuln_title, t.tool_name
    FROM ToolsVulnerabilities tv
    JOIN Tool t ON tv.tool_id = t.tool_id
    JOIN VulnerabilitiesMap VM on tv.vuln_map_id = VM.vuln_map_id;
    """
    qset = cur.execute(query)
    df_tools = incidents_per_ic_bug_category
    tools = {v: [] for v in incidents_per_ic_bug_category.vuln_title}
    for vuln, tool in qset:
        tools[vuln].append(tool)
    df_tools['Tools'] = list(tools.values())
    return df_tools


def get_vulns_per_tool(cur):
    """
    Retrieve the vulnerabilities per tool.

    Args:
        cur: SQLite database cursor object.

    Returns:
        dict: Dictionary with tool names as keys and a list of vulnerabilities as values.
    """
    query = """
    SELECT
        T.tool_name,
        VM.vuln_title
    FROM Tool T
    JOIN ToolsVulnerabilities TV ON T.tool_id = TV.tool_id
    JOIN VulnerabilitiesMap VM ON TV.vuln_map_id = VM.vuln_map_id;
    """
    qset = cur.execute(query)
    tool_vulns = defaultdict(list)
    for tool, vuln in qset:
        tool_vulns[tool].append(vuln)
    return tool_vulns


def get_incidents_with_source(cur):
    """
    Retrieve incidents where all contracts have source.

    Args:
        cur: SQLite database cursor object.

    Returns:
        set: Set of incident titles where all contracts have source.
    """
    query = """
    SELECT
        DISTINCT I.incident_title
    FROM
        Incident I
    WHERE
        I.incident_id NOT IN (
            SELECT
                DISTINCT V.incident_id
            FROM
                Victim V
            JOIN VulnerableContract VC ON V.victim_id = VC.victim_id
            WHERE
                VC.has_source = 0
        );
    """
    qset = cur.execute(query)
    incidents_with_source = set([i[0] for i in qset])
    return incidents_with_source


def get_findings_per_tool(cur):
    """
    Retrieve the findings per tool for incidents.

    Args:
        cur: SQLite database cursor object.

    Returns:
        dict: Dictionary with tool names as keys, incident titles as subkeys, and lists of findings as values.
    """
    query = """
    SELECT
        I.incident_title,
        RA.tool,
        RA.is_bytecode,
        VM.vuln_title,
        VC.contract_address
    FROM
        Incident I
    JOIN
        Victim V ON I.incident_id = V.incident_id
    JOIN
        VulnerableContract VC ON V.victim_id = VC.victim_id
    JOIN
        RetroAnalysis RA ON VC.vulnerable_contract_id = RA.vulnerable_contract_id
    JOIN
        RetroFindings RF ON RA.analysis_id = RF.analysis_id
    JOIN
        SmartContractVulnerabilities SCV ON RF.vulnerability_type_id = SCV.vulnerability_type_id
    JOIN
        VulnerabilitiesMap VM ON SCV.vuln_map_id = VM.vuln_map_id;
    """
    qset = cur.execute(query)
    findings = defaultdict(lambda: defaultdict(list))
    findings_merged = defaultdict(lambda: defaultdict(set))
    findings_contracts = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    for incident, tool, is_bytecode, vuln_title, contract_address in qset:
        findings[(tool, is_bytecode)][incident].append(vuln_title)
        findings_merged[tool][incident].add(vuln_title)
        findings_contracts[(tool, is_bytecode)][incident][vuln_title].append(contract_address)
    return findings_merged


def get_tools_and_analysis(con):
    """
    Retrieve the tools and analysis mode.

    Args:
        con: SQLite database connection object.

    Returns:
        pandas.DataFrame: DataFrame containing the tools used for analysis and their analysis mode.
        int: Index of the total row in the DataFrame.
    """
    query = """
    SELECT DISTINCT tool, is_bytecode
    FROM RetroAnalysis
    """
    tools_analysis = pd.read_sql(query, con)
    total_index = len(tools_analysis.index)
    tools_analysis.loc[total_index] = ['total', '']
    return tools_analysis, total_index


def has_intersection(list1, list2):
    """
    Check if there is an intersection between two lists.

    Args:
        list1: First list.
        list2: Second list.

    Returns:
        bool: True if there is an intersection, False otherwise.
    """
    return len(set(list1) & set(list2)) > 0


def get_vulns_per_incident(cur):
    """
    Retrieve the vulnerabilities per incident.

    Args:
        cur: SQLite database cursor object.

    Returns:
        dict: Dictionary with incident titles as keys and a list of vulnerabilities as values.
    """
    query = """
    SELECT DISTINCT
        I.incident_title,
        VM.vuln_title
    FROM Incident I
    JOIN IncidentCause IC ON I.incident_id = IC.incident_id
    JOIN Cause C ON IC.cause_id = C.cause_id
    JOIN VulnerabilitiesMap VM ON C.vuln_map_id = VM.vuln_map_id;
    """
    qset = cur.execute(query)
    incident_vulns = defaultdict(list)
    for incident, vuln in qset:
        incident_vulns[incident].append(vuln)

    return incident_vulns


def get_incidents_and_vulns_per_tool(cur, con, incidents):
    """
    Retrieve the incidents and vulnerabilities per tool.

    Args:
        cur: SQLite database cursor object.
        con: SQLite database connection object.
        incidents: List of incident titles.

    Returns:
        pandas.DataFrame: DataFrame containing the incident titles, total vulnerabilities, and detected vulnerabilities.
        dict: Dictionary with incident titles as keys and a set of detected vulnerabilities as values.
        dict: Dictionary with incident titles as keys and a list of vulnerabilities as values.
    """
    query = """
    SELECT incident_title, vuln_title
    FROM Incident
    JOIN IncidentCause IC on Incident.incident_id = IC.incident_id
    JOIN Cause C on C.cause_id = IC.cause_id
    JOIN VulnerabilitiesMap VM on C.vuln_map_id = VM.vuln_map_id
    WHERE VM.category in ('Smart Contract', 'Protocol')
    """
    qset = cur.execute(query)
    incidents_vulnerabilities = defaultdict(set)
    for incident_title, vuln_title in qset:
        incidents_vulnerabilities[incident_title].add(vuln_title)
    query = """
    SELECT incident_title, contract_address, tool, is_bytecode, vuln_title, occurences
    FROM Incident
    JOIN Victim V on Incident.incident_id = V.incident_id
    JOIN VulnerableContract VC on V.victim_id = VC.victim_id
    JOIN RetroAnalysis RA on VC.vulnerable_contract_id = RA.vulnerable_contract_id
    JOIN RetroFindings RF on RA.analysis_id = RF.analysis_id
    JOIN SmartContractVulnerabilities SCV on RF.vulnerability_type_id = SCV.vulnerability_type_id
    JOIN VulnerabilitiesMap VM on SCV.vuln_map_id = VM.vuln_map_id
    WHERE incident_title in ({})
    GROUP BY incident_title, contract_address, tool, is_bytecode, vuln_title, occurences
    """.format(','.join('"' + i + '"' for i in incidents))
    qset = cur.execute(query)
    incidents_findings = defaultdict(set)
    for incident_title, _, _, _, vuln_title, _ in qset:
        incidents_findings[incident_title].add(vuln_title)

    incidents_aggr_results = []
    for incident, vulns in incidents_vulnerabilities.items():
        if incident not in incidents_findings:
            detected = 0
        else:
            detected = sum(1 for vuln in vulns if vuln in incidents_findings[incident])
        incidents_aggr_results.append([incident, len(vulns), detected])
    df_incidents_aggr_results = pd.DataFrame(
        incidents_aggr_results, columns=["Incident", "Total Vulns", "Detected Vulns"]
    )

    df_incidents_aggr_results["At least one"] = df_incidents_aggr_results["Detected Vulns"] > 0
    df_incidents_aggr_results["All"] = df_incidents_aggr_results["Total Vulns"] == df_incidents_aggr_results["Detected Vulns"]
    # print("Total Incidents: {}, At least one: {}, All {}".format(
    #     len(df_incidents_aggr_results.index),
    #     len(df_incidents_aggr_results[df_incidents_aggr_results['At least one'] == True]),
    #     len(df_incidents_aggr_results[df_incidents_aggr_results['All'] == True]),
    # ))
    return df_incidents_aggr_results, incidents_findings, incidents_vulnerabilities


def calculate_prevented_incidents_per_category(incidents_per_ic_bug_category, incidents_vulnerabilities, incidents_findings):
    """
    Calculate the number of prevented incidents per bug category.

    Args:
        incidents_per_ic_bug_category: DataFrame containing the bug category, total incidents, and incident IDs.
        incidents_vulnerabilities: Dictionary with incident titles as keys and a list of vulnerabilities as values.
        incidents_findings: Dictionary with incident titles as keys and a set of detected vulnerabilities as values.

    Returns:
        pandas.DataFrame: DataFrame containing the bug category, total incidents, detectable incidents, and findings.
    """
    prev_incidents_per_category = incidents_per_ic_bug_category

    vulnerabilities_detected = {t: set() for t in incidents_per_ic_bug_category.vuln_title}
    vulnerabilities_findings = {t: set() for t in incidents_per_ic_bug_category.vuln_title}
    for incident, vulns in incidents_vulnerabilities.items():
        for vuln in vulns:
            if vuln in incidents_findings[incident]:
                vulnerabilities_detected[vuln].add(incident)
        for vuln in incidents_findings[incident]:
            if vuln in vulnerabilities_findings:
                vulnerabilities_findings[vuln].add(incident)
    prev_incidents_per_category['Detectable'] = list(len(i) for i in vulnerabilities_detected.values())
    prev_incidents_per_category['detectable_ids'] = list(vulnerabilities_detected.values())
    prev_incidents_per_category['Findings'] = list(len(i) for i in vulnerabilities_findings.values())
    prev_incidents_per_category['detectable_ids'] = list(vulnerabilities_detected.values())
    prev_incidents_per_category['findings_ids'] = list(vulnerabilities_findings.values())
    return prev_incidents_per_category


def calculate_damage_per_incident(cur, df_tools, df_incidents_aggr_results, incident_vulns):
    """
    Calculate the damage per incident.

    Args:
        cur: SQLite database cursor object.
        df_tools: DataFrame containing the bug category, total incidents, incident IDs, and tools used.
        df_incidents_aggr_results: DataFrame containing the incident titles, total vulnerabilities, and detected vulnerabilities.
        incident_vulns: Dictionary with incident titles as keys and a list of vulnerabilities as values.

    Returns:
        set: Set of incident titles.
        set: Set of incidents in scope.
    """
    query = """
    SELECT incident_title, avg_reported_damage_in_usd as damage
    FROM Incident
    """
    qset = cur.execute(query)
    damage = {title: damage for title, damage in qset}

    total_vuln_categories = df_tools['vuln_title'].count()

    incidents = df_incidents_aggr_results['Incident']
    in_scope_incidents = set(incidents)
    total_incidents = df_incidents_aggr_results['Incident'].count()
    total_incidents_in_scope = df_tools[df_tools['Tools'].apply(len) > 0]['ids']
    incidents_in_scope = set(i for l in total_incidents_in_scope for i in l)
    total_incidents_in_scope = len(incidents_in_scope)
    incidents_out_of_scope = set(i for i in incidents if i not in incidents_in_scope)
    total_incidents_out_of_scope = len(incidents_out_of_scope)
    detectable_incidents = set(i for l in df_tools["detectable_ids"] for i in l)
    total_detectable_incidents = len(detectable_incidents)

    total_value = int(sum(damage[i] for i in df_incidents_aggr_results['Incident']))
    total_value_out_of_scope = int(sum(damage[i] for i in incidents_out_of_scope))
    total_value_in_scope = int(sum(damage[i] for i in incidents_in_scope))
    total_value_could_have_been_saved = int(sum(damage[i] for i in detectable_incidents))

    return incidents, incidents_in_scope


def get_incidents_in_scope(tool_vulns, tools_analysis, total_index, incident_vulns):
    """
    Retrieve the incidents in scope for each tool.

    Args:
        tool_vulns: Dictionary with tool names as keys and a list of vulnerabilities as values.
        tools_analysis: DataFrame containing the tools used for analysis and their analysis mode.
        total_index: Index of the total row in the DataFrame.
        incident_vulns: Dictionary with incident titles as keys and a list of vulnerabilities as values.

    Returns:
        DataFrame: Updated DataFrame with the incidents in scope for each tool.
    """
    tools_analysis['incidents_in_scope'] = ""

    tools_analysis.at[total_index, 'incidents_in_scope'] = set()

    for index, row in tools_analysis.iterrows():
        if index == total_index:
            continue
        tool = row['tool']
        tool_vulnerabilities = tool_vulns[tool]
        incidents_in_scope = set([
            incident for incident, vulns in incident_vulns.items()
            if has_intersection(vulns, tool_vulnerabilities)
        ])
        tools_analysis.at[index, 'incidents_in_scope'] = incidents_in_scope
        tools_analysis.at[total_index, 'incidents_in_scope'].update(incidents_in_scope)

    return tools_analysis


def get_tool_findings(cur, df_tools, findings_merged, in_scope_incidents):
    """
    Retrieve the findings per tool.

    Args:
        cur: SQLite database cursor object.
        df_tools: DataFrame containing the bug category, total incidents, incident IDs, and tools used.
        findings_merged: Dictionary with tool names as keys, incident titles as sub-keys, and a set of detected vulnerabilities as values.
        in_scope_incidents: Set of incidents in scope.

    Returns:
        DataFrame: DataFrame containing the tool names, detected vulnerabilities, and incidents not exploited by the tool.
    """
    query = """
    SELECT DISTINCT tool_name
    FROM Tool;
    """
    qset = cur.execute(query)
    tool_findings = pd.DataFrame()

    tool_findings['vuln'] = ""
    for tool in qset:
        if tool[0] == 'manticore':
            continue
        tool_findings[tool[0] + "_detected"] = ""
        tool_findings[tool[0] + "_not_exploited"] = ""
    tool_findings['total_attacks'] = ""
    tool_findings['total_detected'] = ""
    tool_findings['total_not_exploited'] = ""
    for index, row in df_tools.iterrows():
        tool_findings_index = len(tool_findings)
        if len(row['Tools']) == 0:
            continue
        tool_findings.at[tool_findings_index, 'vuln'] = row['vuln_title']
        tool_findings.at[tool_findings_index, 'total_attacks'] = row['total']
        detected_ids = set()
        not_exploited_ids = set()
        for tool in row['Tools']:
            tool_detected = {
                incident for incident, findings in findings_merged[tool].items()
                for finding in findings
                if finding == row['vuln_title'] and incident in row['ids']
            }
            tool_findings.at[tool_findings_index, tool + "_detected"] = len(tool_detected)
            detected_ids.update(tool_detected)
            tool_not_exploited = {
                incident for incident, findings in findings_merged[tool].items()
                for finding in set(findings)
                if finding == row['vuln_title'] and incident not in row['ids'] and incident in in_scope_incidents
            }
            tool_findings.at[tool_findings_index, tool + "_not_exploited"] = len(tool_not_exploited)
            not_exploited_ids.update(tool_not_exploited)
        tool_findings.at[tool_findings_index, 'total_detected'] = len(detected_ids)
        tool_findings.at[tool_findings_index, 'total_not_exploited'] = len(not_exploited_ids)
    return tool_findings


def f_format(x):
    """
    Format a value for printing.

    Args:
        x: Value to be formatted.

    Returns:
        str: Formatted value.
    """
    if isinstance(x, float):
        return "\\xmark"
    if isinstance(x, int):
        return f"\\num{{{x}}}"
    return f"{x}"


def generate_tex_table(output_file, table_rows):
    header = r"""
    \documentclass{article}
    \usepackage[margin=1.5cm]{geometry} % Adjust the margin values as needed
    \usepackage{booktabs}
    \usepackage{adjustbox}
    \usepackage{colortbl}
    \usepackage{pifont}
    \usepackage{bigstrut}
    \usepackage[group-separator={,}]{siunitx}
    
    \definecolor{gainsboro}{rgb}{0.86, 0.86, 0.86}
    \newcommand{\clg}[1]{\cellcolor{gainsboro}{#1}}
    \newcommand{\cmark}{\ding{51}}
    \newcommand{\xmark}{\ding{55}}
        
    \begin{document}
    \begin{figure*}[t]
    \centering
    \footnotesize
    \begin{tabular}{|l|cc|cc|cc|cc|cc|ccc|}
    \hline
    \textbf{Vulnerability}
    & \multicolumn{2}{|c|}{\textbf{Slither}}
    & \multicolumn{2}{|c|}{\textbf{Oyente}}
    & \multicolumn{2}{|c|}{\textbf{ConFuzzius}}
    & \multicolumn{2}{|c|}{\textbf{Mythril}}
    & \multicolumn{2}{|c|}{\textbf{Solhint}}
    & \multicolumn{3}{|c|}{\textbf{Total}} \bigstrut[t] \\
    \hline\hline
    & D & ODI 
    & D & ODI
    & D & ODI
    & D & ODI
    & D & ODI
    & TA & D & ODI \bigstrut[t] \\
    \hline"""
    footer = r"""\hline
    \end{tabular}
    \caption{Summary of tool results. D (Detected). ODI (Other Detected Issues): other findings including false positives, defects that cannot be exploited (e.g., in protected functions),
    or exploitable defects not included in the dataset (i.e., not used in the attacks).
    TA (Total Attacks).}
    \label{tab:tools-results}%
    \end{figure*}
    \end{document}
    """

    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(header.strip() + '\n')
        for row in table_rows:
            f.write(row.rstrip('\n') + '\n')
        f.write(footer.strip() + '\n')


def main():
    """
    Main function to run the program.
    """
    args = get_args()
    db_path = args.db
    output_file = args.output

    conn, cursor = setup_db(db_path)

    incidents_per_ic_bug_category = get_incident_per_bug_category(conn)

    incidents = count_incidents_in_scope(conn)[1]
    df_incidents_aggr_results, incidents_findings, incidents_vulnerabilities = get_incidents_and_vulns_per_tool(cursor, conn, incidents)
    df_tools = get_tools(cursor, incidents_per_ic_bug_category)
    tool_vulns = get_vulns_per_tool(cursor)
    tools_analysis, total_index = get_tools_and_analysis(conn)
    tools_analysis = get_incidents_in_scope(tool_vulns, tools_analysis, total_index, incidents_vulnerabilities)
    tool_findings = get_tool_findings(cursor, df_tools, get_findings_per_tool(cursor), incidents_findings)

    table_rows = []
    for _, row in tool_findings.iterrows():
        table_rows.append("{}\\\\".format(" & ".join(f_format(c) for c in row)))

    generate_tex_table(output_file, table_rows)

    conn.close()


if __name__ == "__main__":
    main()
