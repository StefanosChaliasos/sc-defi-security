import sqlite3
import pandas as pd
from collections import defaultdict
import argparse
import os


def connect_to_db(database: str) -> sqlite3.Connection:
    """Connects to the SQLite database.

    Args:
        database: The database file path.

    Returns:
        Connection object.
    """
    con: sqlite3.Connection = sqlite3.connect(database)
    return con


def get_args():
    """Argument parsing"""
    parser = argparse.ArgumentParser(
        prog="attack descriptive statistics",
        description="Parse the results of the analysis tools and print their findings"
    )
    parser.add_argument(
        "db",
        help="The database file (note that you should provide valid inputs.")

    parser.add_argument(
        "output",
        help="The output file for the LaTeX formatted table."
    )
    return parser.parse_args()


def count_incidents_by_categories(con: sqlite3.Connection) -> int:
    """Counts incidents caused by Smart Contract and Protocol categories.

    Args:
        con: SQLite Connection object.

    Returns:
        The count of incidents.
    """
    query = """
    SELECT DISTINCT incident_title
    FROM Incident
    JOIN IncidentCause IC on Incident.incident_id = IC.incident_id
    JOIN Cause C on C.cause_id = IC.cause_id
    JOIN VulnerabilitiesMap VM on C.vuln_map_id = VM.vuln_map_id
    WHERE VM.category in ('Smart Contract', 'Protocol')
    """
    df = pd.read_sql(query, con)
    return len(df)


def calculate_damage_by_categories(con: sqlite3.Connection) -> float:
    """Calculates the total damage done by incidents of specific categories.

    Args:
        con: SQLite Connection object.

    Returns:
        Total damage amount.
    """
    query = """
    SELECT DISTINCT incident_title, avg_reported_damage_in_usd
    FROM Incident
    JOIN IncidentCause IC on Incident.incident_id = IC.incident_id
    JOIN Cause C on C.cause_id = IC.cause_id
    JOIN VulnerabilitiesMap VM on C.vuln_map_id = VM.vuln_map_id
    WHERE VM.category in ('Smart Contract', 'Protocol')
    """
    df = pd.read_sql(query, con)
    total_damage = df['avg_reported_damage_in_usd'].sum()

    return total_damage


def get_tool_vulnerabilities(con: sqlite3.Connection) -> dict:
    """Returns vulnerabilities covered by each tool for specific categories.

    Args:
        con: SQLite Connection object.

    Returns:
        Dictionary with tool names as keys and vulnerabilities as values.
    """
    query = """
    SELECT tool_name, vuln_title
    FROM Tool
    JOIN ToolsVulnerabilities TVD on TVD.tool_id = Tool.tool_id
    JOIN VulnerabilitiesMap VM on VM.vuln_map_id = TVD.vuln_map_id
    WHERE VM.category in ('Smart Contract', 'Protocol')
    """
    df = pd.read_sql(query, con)
    tool_vulnerabilities = defaultdict(set)
    for index, row in df.iterrows():
        tool_vulnerabilities[row['tool_name']].add(row['vuln_title'])
    return tool_vulnerabilities


def get_incident_vulnerabilities(con: sqlite3.Connection) -> dict:
    """Returns vulnerabilities found in each incident for specific categories.

    Args:
        con: SQLite Connection object.

    Returns:
        Dictionary with incident names as keys and vulnerabilities as values.
    """
    query = """
    SELECT incident_title, vuln_title
    FROM Incident
    JOIN IncidentCause IC on Incident.incident_id = IC.incident_id
    JOIN Cause C on C.cause_id = IC.cause_id
    JOIN VulnerabilitiesMap VM on C.vuln_map_id = VM.vuln_map_id
    WHERE VM.category in ('Smart Contract', 'Protocol')
    """
    df = pd.read_sql(query, con)
    incidents_vulnerabilities = defaultdict(set)
    for index, row in df.iterrows():
        incidents_vulnerabilities[row['incident_title']].add(row['vuln_title'])
    return incidents_vulnerabilities


def classify_incidents_by_scope(tool_vulnerabilities: dict, incidents_vulnerabilities: dict) -> tuple:
    """Classifies incidents into 'in-scope' and 'out-of-scope' based on the vulnerabilities that tools can cover.

    Args:
        tool_vulnerabilities: A dictionary containing the vulnerabilities that each tool can cover.
        incidents_vulnerabilities: A dictionary containing the vulnerabilities that were found in each incident.

    Returns:
        A tuple containing:
            - Number of 'in-scope' incidents
            - Number of 'out-of-scope' incidents
            - Set of 'out-of-scope' incidents
    """
    vuln_in_scope_tools = set().union(*tool_vulnerabilities.values())
    inscope_incidents = {incident for incident, vulns in incidents_vulnerabilities.items() if
                         vulns & vuln_in_scope_tools}
    out_of_scope_incidents = set(incidents_vulnerabilities.keys()) - inscope_incidents
    return len(inscope_incidents), len(out_of_scope_incidents), out_of_scope_incidents


def calculate_damage_by_incident_scope(con: sqlite3.Connection, incidents: set, scope: str) -> float:
    """Calculates the total damage done by a set of incidents.

    Args:
        con: SQLite Connection object.
        incidents: A set of incident titles.
        scope: A string indicating whether the incidents are 'in-scope' or 'out-of-scope'.

    Returns:
        Total damage amount.
    """
    keys = ",".join(f"'{incident}'" for incident in incidents)
    query = f"""
    SELECT avg_reported_damage_in_usd
    FROM Incident
    WHERE incident_title in ({keys})"""
    df = pd.read_sql(query, con)
    total_damage = df['avg_reported_damage_in_usd'].sum()
    return total_damage


def format_damage(damage):
    return "{:,.0f}$".format(damage)


def generate_tex_file(output_path, attack_count, total_damage, num_outscope, attacks_out_of_scope_percf,
                      damage_out_of_scope, damage_out_of_scope_percf, num_inscope, damage_in_scope,
                      damage_in_scope_percf):
    def format_damage(damage):
        # Convert damage to a string with thousands separator and append a dollar sign after it
        return "{:,.0f} \\$".format(damage)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    header = r"""
       \documentclass{article}

       \usepackage{xcolor}
       \usepackage{multirow}
       \usepackage{pifont}
       \usepackage{sepnum}
       \usepackage{xspace}
       \usepackage[group-separator={,}]{siunitx}
       \usepackage[most]{tcolorbox}
       \usepackage{subcaption}
       \usepackage{bigstrut}
       \usepackage{makecell}
       \usepackage{booktabs}
       \usepackage{enumitem}

       \newcommand{\cmark}{\ding{51}}%
       \newcommand{\xmark}{\ding{55}}%
       \newcommand*\rot{\rotatebox{90}}


       \usepackage{colortbl}
       \definecolor{gainsboro}{rgb}{0.86, 0.86, 0.86}
       \newcommand{\clg}[1]{\cellcolor{gainsboro}{#1}}

       \begin{document} """

    footer = """ \end{document} """

    with open(output_path, 'w') as file:
        # Write the LaTeX formatted text
        file.write(f' {header} \n')
        file.write('\\begin{figure}[t]\n')
        file.write('    \\centering\n')
        file.write('    \\footnotesize\n')
        file.write('    \\begin{tabular}{lr}\n')
        file.write('    \\toprule\n')
        file.write(f'    \\textbf{{Attacks}} & {attack_count} \\\\\n')
        file.write(f'    \\textbf{{Damage}} & {format_damage(total_damage)} \\\\\n')

        # Escaping the percentage sign by replacing '%' with '\\%'
        attacks_out_of_scope_percf = attacks_out_of_scope_percf.replace('%', '\\%')
        damage_out_of_scope_percf = damage_out_of_scope_percf.replace('%', '\\%')
        damage_in_scope_percf = damage_in_scope_percf.replace('%', '\\%')

        # Using '\\textquotesingle' for single quote
        file.write(
            f"    \\textbf{{Attacks out of selected tools\\textquotesingle scope}} & {num_outscope} ({attacks_out_of_scope_percf}) \\\\\n")
        file.write(
            f"    \\textbf{{Damage out of selected tools\\textquotesingle scope}} & {format_damage(damage_out_of_scope)} ({damage_out_of_scope_percf}) \\\\\n")
        file.write(
            f"    \\textbf{{Attacks in selected tools\\textquotesingle scope}} & {num_inscope} ({attacks_out_of_scope_percf}) \\\\\n")
        file.write(
            f"    \\textbf{{Damage in selected tools\\textquotesingle scope}} & {format_damage(damage_in_scope)} ({damage_in_scope_percf}) \\\\\n")
        file.write('    \\bottomrule\n')
        file.write('    \\end{tabular}\n')
        file.write('    \\vspace{-0.25cm}\n')
        file.write('    \\caption{Overall descriptive statistics of the analysed attacks.}\n')
        file.write('    \\label{tab:scope}\n')
        file.write('\\end{figure}\n')
        file.write(f' {footer} \\n')
def main():
    """Main function to run the analysis."""

    # Parse the arguments
    args = get_args()

    # Create a database connection
    con = connect_to_db(args.db)

    # Count the number of attacks of Smart Contract and Protocol categories
    attack_count = count_incidents_by_categories(con)
    # print(f"Attacks: {attack_count}")

    # Calculate the total damage done by incidents of Smart Contract and Protocol categories
    total_damage = calculate_damage_by_categories(con)
    # print(f"Damage: {format_damage(total_damage)}")

    # Get the vulnerabilities covered by each tool
    tool_vulnerabilities = get_tool_vulnerabilities(con)

    # Get the vulnerabilities found in each incident
    incident_vulnerabilities = get_incident_vulnerabilities(con)

    # Classify incidents into 'in-scope' and 'out-of-scope'
    num_inscope, num_outscope, out_of_scope_incidents = classify_incidents_by_scope(tool_vulnerabilities,
                                                                                    incident_vulnerabilities)
    attacks_out_of_scope_perc = (num_outscope / attack_count) * 100
    attacks_out_of_scope_percf = "{:,.0f}%".format(attacks_out_of_scope_perc)
    # print(f"Attacks out of selected tools’ scope: {num_outscope}" + f"({attacks_out_of_scope_percf})")

    # Calculate the total damage done by 'out-of-scope' incidents
    damage_out_of_scope = calculate_damage_by_incident_scope(con, out_of_scope_incidents, 'out-of-scope')
    damage_out_of_scope_perc = (damage_out_of_scope / total_damage) * 100
    damage_out_of_scope_percf = "{:,.0f}%".format(damage_out_of_scope_perc)
    # print(
        # f"Damage out of selected tools’ scope: {format_damage(damage_out_of_scope)}" + f"({damage_out_of_scope_percf})")

    # Calculate the total damage done by 'in-scope' incidents
    in_scope_incidents = set(incident_vulnerabilities.keys()) - out_of_scope_incidents

    attacks_in_scope_perc = (num_inscope / attack_count) * 100
    attacks_out_of_scope_percf = "{:,.0f}%".format(attacks_in_scope_perc)
    # print(f"Attacks in selected tools’ scope: {num_inscope}" + f"({attacks_out_of_scope_percf})")

    damage_in_scope = calculate_damage_by_incident_scope(con, in_scope_incidents, 'in-scope')
    damage_in_scope_perc = (damage_in_scope / total_damage) * 100
    damage_in_scope_percf = "{:,.0f}%".format(damage_in_scope_perc)
    # print(f"Damage in selected tools’ scope: {format_damage(damage_in_scope)}" + f"({damage_in_scope_percf})")

    # Create table
    table = [
        ["Attacks", attack_count],
        ["Damage", format_damage(total_damage)],
        ["Attacks out of selected tools' scope", f"{num_outscope} ({attacks_out_of_scope_percf})"],
        ["Damage out of selected tools' scope", f"{format_damage(damage_out_of_scope)} ({damage_out_of_scope_percf})"],
        ["Attacks in selected tools' scope", f"{num_inscope} ({attacks_out_of_scope_percf})"],
        ["Damage in selected tools' scope", f"{format_damage(damage_in_scope)} ({damage_in_scope_percf})"],
    ]

    generate_tex_file(
        args.output,
        attack_count,
        total_damage,
        num_outscope,
        attacks_out_of_scope_percf,
        damage_out_of_scope,
        damage_out_of_scope_percf,
        num_inscope,
        damage_in_scope,
        damage_in_scope_percf
    )


# Run the main function
if __name__ == "__main__":
    main()
