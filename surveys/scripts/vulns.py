import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import re
import argparse
from tools_experience import configure_matplotlib

def clean_tool_name(name):
    """
    Clean the tool name by applying various replacements and formatting.

    Args:
        name (str): The tool name to be cleaned.

    Returns:
        str: The cleaned tool name.
    """
    name = str(name)
    # Replacements
    name = name.replace('Integer Overflow and Underflow', 'Integer Overflow/Underflow')
    name = name.replace('Function/State Visibility Error', 'Function/State Visibility Error')
    name = name.replace('Timestamp Dependency', 'Timestamp Dependency')
    name = name.replace('Token standard incompatibility', 'Token standard incompatibility')
    name = re.sub(r'Other\.[1-9]', 'Other', name)
    name = name.replace('Reentrancy', 'Reentrancy')
    name = name.replace('Unhandled or mishandled exception', 'Unhandled/mishandled exception')
    name = name.replace('Absence of coding logic or sanity check', 'Absence of coding logic')
    name = name.replace('Improper asset locks or frozen asset', 'Improper asset locks/frozen asset')
    name = name.replace('Logic errors', 'Logic errors')
    name = name.replace('Oracle manipulation', 'Oracle manipulation')
    name = name.replace('Other formal verification / model checking tool', 'Other FV')
    name = name.replace("Foundry's propert-based fuzzer", "Foundry's fuzzer")
    name = name.replace('Other static analyzer', 'Other SA')
    name = name.replace('Other symbolic execution tool', 'Other SE')
    name = name.replace('Other runtime monitoring', 'Runtime monitoring')
    name = re.sub(r'\(.*\)', '', name).strip()
    return name

def analyze_data(csv_file, start_col, end_col, num_responses):
    """
    Analyze the data from a CSV file by counting tool mentions.

    Args:
        csv_file (str): The path to the CSV file.
        start_col (int): The index of the starting column.
        end_col (int): The index of the ending column.
        num_responses (int): The number of responses.

    Returns:
        pandas.Series: The tool counts.
        int: The number of responses.
    """
    df = pd.read_csv(csv_file)
    tools_df = df.iloc[:, start_col:end_col]
    tools_df = tools_df.notna()
    counts_df = tools_df.sum(axis=0)
    counts_df = counts_df.sort_values(ascending=False)
    counts_df.index = counts_df.index.map(clean_tool_name)
    print(f'Number of Responses: {num_responses}')
    num_tools_per_reply = tools_df.sum(axis=1)
    print(f'Average Number of Tools Mentioned in a Response: {num_tools_per_reply.mean()}')
    print(f'Maximum Number of Tools Mentioned in a Response: {num_tools_per_reply.max()}')
    print(f'Minimum Number of Tools Mentioned in a Response: {num_tools_per_reply.min()}')
    return counts_df, num_responses

def create_bar_chart(counts_df_devs, counts_df_auditors, num_responses_devs, num_responses_auditors, output_file):
    """
    Create a bar chart comparing tool mentions by developers and auditors.

    Args:
        counts_df_devs (pandas.Series): The tool counts by developers.
        counts_df_auditors (pandas.Series): The tool counts by auditors.
        num_responses_devs (int): The number of responses from developers.
        num_responses_auditors (int): The number of responses from auditors.
        output_file (str): The path to the output file (PDF).

    Returns:
        None
    """
    fig, ax = plt.subplots()
    counts_df_devs_pct = (counts_df_devs / num_responses_devs) * 100
    counts_df_auditors_pct = (counts_df_auditors / num_responses_auditors) * 100
    bar_width = 0.35
    tools = [clean_tool_name(t) for t in counts_df_devs_pct.index.tolist()]
    x_devs = np.arange(len(tools))
    x_auditors = x_devs + bar_width
    counts_df_auditors_pct = counts_df_auditors_pct.reindex(counts_df_devs_pct.index)
    devs_bars = ax.barh(x_devs, counts_df_devs_pct, height=bar_width, color='lightblue', label='Devs')
    auditors_bars = ax.barh(x_auditors, counts_df_auditors_pct, height=bar_width, color='lightcoral', label='Auditors')
    ax.set_xlabel('Percentage of Responses')
    ax.set_xticks(np.arange(0, 70, 10))
    ax.set_xticklabels([f"{x:.0f}%" for x in np.arange(0, 70, 10)])
    ax.set_yticks(x_devs + bar_width / 2)
    ax.set_yticklabels(tools, ha='right')
    ax.legend()
    plt.legend(loc='upper right', prop={'size':22}, frameon=True)
    fig = plt.gcf()
    fig.set_size_inches(10,6)
    axis = plt.gca()
    fig.tight_layout()
    plt.savefig(output_file, bbox_inches='tight')

def main(devs_file_path, auditors_file_path, output_file):
    """
    The main function that orchestrates the data analysis and chart creation.

    Args:
        devs_file_path (str): The path to the developers' CSV file.
        auditors_file_path (str): The path to the auditors' CSV file.
        output_file (str): The path to the output PDF file.

    Returns:
        None
    """
    configure_matplotlib()
    counts_df_devs, _ = analyze_data(devs_file_path, 16, 27, 27)
    counts_df_auditors, _ = analyze_data(auditors_file_path, 16, 27, 21)
    create_bar_chart(counts_df_devs, counts_df_auditors, 27, 21, output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some files.')
    parser.add_argument('--devs_file_path', required=True, help='The path to the devs CSV file.')
    parser.add_argument('--auditors_file_path', required=True, help='The path to the auditors CSV file.')
    parser.add_argument('--output_file', required=True, help='The path to the output PDF file.')
    args = parser.parse_args()

    main(args.devs_file_path, args.auditors_file_path, args.output_file)
