import sqlite3
import pandas as pd
from collections import defaultdict
import argparse
import os

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
        prog="tool effectiveness and damage",
        description="Parse the results of the analysis tools and print their findings"
    )
    parser.add_argument(
        "db",
        help="The database file (note that you should provide valid inputs."
    )
    parser.add_argument(
        "output",
        help="The tex output file."
    )
    return parser.parse_args()

def get_tools_and_analysis_mode(con: sqlite3.Connection) -> pd.DataFrame:
    """
    Get tools and analysis mode.

    Args:
        con (sqlite3.Connection): SQLite database connection object.

    Returns:
        pd.DataFrame: DataFrame with tools and analysis modes.
    """
    query = """
    SELECT DISTINCT tool, is_bytecode
    FROM RetroAnalysis
    """
    tools_bytecode = pd.read_sql(query, con)
    total_index = len(tools_bytecode.index)
    tools_bytecode.loc[len(tools_bytecode)] = ['total', '']

    return tools_bytecode, total_index

def get_incident_vuln(cur):
    """
    Get incident vulnerabilities.

    Args:
        cur: SQLite cursor object.

    Returns:
        defaultdict: Dictionary with incidents as keys and lists of vulnerabilities as values.
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

def get_tool_inscope_vulns(cur):
    """
    Get tool vulnerabilities that are in scope.

    Args:
        cur: SQLite cursor object.

    Returns:
        defaultdict: Dictionary with tools as keys and lists of vulnerabilities as values.
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
    Get incidents that have a source.

    Args:
        cur: SQLite cursor object.

    Returns:
        set: Set of incidents with a source.
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


def get_tool_findings_for_incidents(cur):
    """
    Get tool findings for incidents.

    Args:
        cur: SQLite cursor object.

    Returns:
        defaultdict: Nested dictionary with tool, incident, vulnerability, and contract address as keys.
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
    return findings_contracts


def has_intersection(list1, list2):
    """
    Check if there's an intersection between two lists.

    Args:
        list1: First list.
        list2: Second list.

    Returns:
        bool: True if there's an intersection, False otherwise.
    """
    return len(set(list1) & set(list2)) > 0


def add_incidents_in_scope_to_vulns(tools_bytecode, total_index, tool_vulns, incident_vulns):
    """
    Add incidents in scope to vulnerabilities.

    Args:
        tools_bytecode (pd.DataFrame): DataFrame with tools and analysis modes.
        total_index (int): Index of the total row.
        tool_vulns (defaultdict): Dictionary with tools as keys and lists of vulnerabilities as values.
        incident_vulns (defaultdict): Dictionary with incidents as keys and lists of vulnerabilities as values.
    """
    tools_bytecode['incidents_in_scope'] = ""
    tools_bytecode.at[total_index, 'incidents_in_scope'] = set()
    for index, row in tools_bytecode.iterrows():
        if index == total_index:
            continue
        tool = row['tool']
        tool_vulnerabilities = tool_vulns[tool]
        incidents_in_scope = set([
            incident for incident, vulns in incident_vulns.items()
            if has_intersection(vulns, tool_vulnerabilities)
        ])
        tools_bytecode.at[index, 'incidents_in_scope'] = incidents_in_scope
        tools_bytecode.at[total_index, 'incidents_in_scope'].update(incidents_in_scope)

def get_incident_could_prevented(cur, tools_bytecode, total_index, incident_vulns, findings_contracts):
    """
    Get incidents that could have been prevented.

    Args:
        cur: SQLite cursor object.
        tools_bytecode (pd.DataFrame): DataFrame with tools and analysis modes.
        total_index (int): Index of the total row.
        incident_vulns (defaultdict): Dictionary with incidents as keys and lists of vulnerabilities as values.
        findings_contracts (defaultdict): Nested dictionary with tool, incident, vulnerability, and contract address as keys.
    """
    tools_bytecode['prevented_incidents'] = ""
    tools_bytecode['false_positives'] = ""
    tools_bytecode.at[total_index, 'prevented_incidents'] = set()
    tools_bytecode.at[total_index, 'false_positives'] = set()
    for index, row in tools_bytecode.iterrows():
        if index == total_index:
            continue
        tool = row['tool']
        is_bytecode = row['is_bytecode']
        incidents_in_scope = row['incidents_in_scope']
        prevented_incidents = set([
            incident for incident in incidents_in_scope
            if has_intersection(incident_vulns[incident], findings_contracts[(tool, is_bytecode)][incident])
        ])
        false_positives = set()
        if tool == 'solhint':
            false_positives = prevented_incidents
            prevented_incidents = []
        tools_bytecode.at[index, 'prevented_incidents'] = prevented_incidents
        tools_bytecode.at[index, 'false_positives'] = false_positives
        tools_bytecode.at[total_index, 'prevented_incidents'].update(prevented_incidents)
        tools_bytecode.at[total_index, 'false_positives'].update(false_positives)


def merge_dataframes_on_bytecode(tools_bytecode):
    """
    Merge dataframes on bytecode.

    Args:
        tools_bytecode (pd.DataFrame): DataFrame with tools and analysis modes.

    Returns:
        pd.DataFrame: Merged dataframe.
    """
    df_new = tools_bytecode.copy()[0:0]
    for index, row in tools_bytecode.iterrows():
        if row['tool'] not in set(df_new['tool']):
            df_new.loc[len(df_new)] = row
        else:
            loc = df_new.loc[df_new['tool'] == row['tool']].index[0]
            df_new.at[loc, 'prevented_incidents'].update(row['prevented_incidents'])
            df_new.at[loc, 'false_positives'].update(row['false_positives'])
            df_new.at[loc, 'incidents_in_scope'].update(row['incidents_in_scope'])
    tools_bytecode = df_new
    tools_bytecode = tools_bytecode.drop(columns=['is_bytecode'])
    return tools_bytecode

def get_damage_per_incident(cur, tools_bytecode):
    """
    Get damage per incident.

    Args:
        cur: SQLite cursor object.
        tools_bytecode (pd.DataFrame): DataFrame with tools and analysis modes.

    Returns:
        dict: Dictionary with incident titles as keys and average reported damage as values.
    """
    query = """
    SELECT incident_title, avg_reported_damage_in_usd as damage
    FROM Incident
    """
    qset = cur.execute(query)
    damage = {title: damage for title, damage in qset}
    tools_bytecode['damage_in_scope'] = ""
    for index, row in tools_bytecode.iterrows():
        tool = row['tool']
        incidents_in_scope = row['incidents_in_scope']
        damage_in_scope = int(sum(
            damage[incident] for incident in incidents_in_scope
        ))
        tools_bytecode.at[index, 'damage_in_scope'] = damage_in_scope
    return damage

def get_damage_inscope_per_tool(tools_bytecode, damage):
    """
    Get damage in scope per tool.

    Args:
        tools_bytecode (pd.DataFrame): DataFrame with tools and analysis modes.
        damage (dict): Dictionary with incident titles as keys and average reported damage as values.
    """
    tools_bytecode['prevented_damage'] = ""
    for index, row in tools_bytecode.iterrows():
        tool = row['tool']
        prevented_incidents = row['prevented_incidents']
        prevented_damage = int(sum(
            damage[incident] for incident in prevented_incidents
        ))
        tools_bytecode.at[index, 'prevented_damage'] = prevented_damage

def list_length(df):
    """
    Get the length of each list in the DataFrame.

    Args:
        df (pd.DataFrame): DataFrame to process.

    Returns:
        pd.DataFrame: DataFrame with lists replaced by their lengths.
    """
    new_df = df.copy()
    for column in df.columns:
        if column != 'false_positives':
            if isinstance(df[column].iloc[0], set):
                new_df[column] = df[column].apply(len)
            else:
                new_df[column] = df[column]
        else:
            new_df = new_df.drop(columns=['false_positives'])
    return new_df


def generate_tex_table(output_file, table_rows):
    # The LaTeX table header
    header = r"""
    \documentclass{article}
    \usepackage[margin=1.5cm]{geometry}
    \usepackage{booktabs}
    \usepackage{multirow}
    \begin{document}
    \begin{figure}[tb]
    \setlength{\tabcolsep}{3pt}
    \centering
    \footnotesize
    \begin{tabular}{lcccrr}
    \toprule
    \bf Tool (Version)
    & \bf Method
    & \multirow{2}{*}{\shortstack[l]{\bf Attacks\\\bf In Scope}}
    & \bf Detected
    & \multirow{2}{*}{\shortstack[l]{\bf Damage\\\bf In Scope}}
    & \multirow{2}{*}{\shortstack[l]{\bf Detected\\\bf Damage}} \\
    & & & & \\
    \midrule"""

    # The LaTeX table footer
    footer = r"""\hline
    \bottomrule
    \end{tabular}
    \caption{Tool effectiveness and damage that could have been prevented. SE: Symbolic Execution, SA: Static Analysis.}
    \label{tab:effectiveness}%
\end{figure}
    \end{document}
    """

    # List of methods corresponding to each tool
    methods = ["Fuzzing", "SE", "SE", "SA", "Linting", "Total"]

    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    # Writing the table to the output file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(header.strip() + '\n')

        # Adding each row to the table
        for i, row in enumerate(table_rows):
            tool, incidents_in_scope, prevented_incidents, damage_in_scope, prevented_damage = row
            method = methods[i]
            formatted_damage_in_scope = "\\${:,.0f}".format(damage_in_scope)  # Note the extra backslash
            formatted_prevented_damage = "\\${:,.0f}".format(prevented_damage)  # Note the extra backslash
            f.write(
                f"    {tool} & {method} & {incidents_in_scope} & {prevented_incidents} & {formatted_damage_in_scope} & {formatted_prevented_damage} \\\\\n")

        f.write(footer.strip() + '\n')

def main():
    """
    Main function.
    """
    args = get_args()
    con, cursor = setup_db(args.db)

    # Get tools and analysis mode
    tools_bytecode, total_index = get_tools_and_analysis_mode(con)

    # Get incident vulns
    incident_vulns = get_incident_vuln(cursor)

    # Get tool vulns
    tool_vulns = get_tool_inscope_vulns(cursor)

    # Get tool findings for incidents
    findings_contracts = get_tool_findings_for_incidents(cursor)

    # Add incidents in scope to vulns
    add_incidents_in_scope_to_vulns(tools_bytecode, total_index, tool_vulns, incident_vulns)

    # Get incident could prevented
    get_incident_could_prevented(cursor,tools_bytecode, total_index, incident_vulns, findings_contracts)

    # Merge dataframes on bytecode
    tools_bytecode = merge_dataframes_on_bytecode(tools_bytecode)

    # Get damage per incident
    damage = get_damage_per_incident(cursor, tools_bytecode)

    # Get damage inscope per tool
    get_damage_inscope_per_tool(tools_bytecode, damage)

    # List length
    tools_bytecode_to_print = list_length(tools_bytecode)

    # Prepare table data for LaTeX
    table_data = tools_bytecode_to_print.values.tolist()

    # Call the generate_tex_table function
    generate_tex_table(args.output, table_data)

    con.close()




if __name__ == "__main__":
    main()
