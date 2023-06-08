import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import re
from tools_experience import configure_matplotlib
import argparse

def clean_tool_name(name):
    """
    Clean the tool name by replacing certain patterns and removing unnecessary characters.

    Args:
        name (str): The tool name to clean.

    Returns:
        str: The cleaned tool name.
    """
    name = str(name)
    replacements = {
        'Integer Overflow and Underflow.1': 'Integer Overflow/Underflow',
        'Function/State Visibility Error.1': 'Function/State Visibility Error',
        'Token standard incompatibility.1': 'Token standard incompatibility',
        'Reentrancy.1': 'Reentrancy',
        'Unhandled or mishandled exception.1': 'Unhandled/mishandled exception',
        'Absence of coding logic or sanity check.1': 'Absence of coding logic',
        'Improper asset locks or frozen asset.1': 'Improper asset locks/frozen asset',
        'Logic errors.1': 'Logic errors',
        'Oracle manipulation.1': 'Oracle manipulation',
        'Other formal verification / model checking tool': 'Other FV',
        "Foundry's propert-based fuzzer": "Foundry's fuzzer",
        'Other static analyzer': 'Other SA',
        'Other symbolic execution tool': 'Other SE',
        'Other runtime monitoring': 'Runtime monitoring'
    }

    for old, new in replacements.items():
        name = name.replace(old, new)

    name = re.sub(r'Other\.[1-9]', 'Other', name)
    name = re.sub(r'\(.*\)', '', name).strip()
    return name


def load_and_process_data(file_path):
    """
    Load and process data from a CSV file.

    Args:
        file_path (str): The path to the CSV file.

    Returns:
        tuple: A tuple containing the processed data:
            - counts_df (pd.Series): Tool counts sorted in descending order.
            - num_responses (int): Number of responses.
            - avg_tools_per_reply (float): Average number of tools mentioned per response.
            - max_tools_per_reply (int): Maximum number of tools mentioned in a response.
            - min_tools_per_reply (int): Minimum number of tools mentioned in a response.
    """
    df = pd.read_csv(file_path)
    tools_df = df.iloc[:, 27:38]
    tools_df = tools_df.notna()

    counts_df = tools_df.sum(axis=0)
    counts_df = counts_df.sort_values(ascending=False)
    counts_df.index = counts_df.index.map(clean_tool_name)

    num_responses = len(df)
    num_tools_per_reply = tools_df.sum(axis=1)
    avg_tools_per_reply = num_tools_per_reply.mean()
    max_tools_per_reply = num_tools_per_reply.max()
    min_tools_per_reply = num_tools_per_reply.min()

    return counts_df, num_responses, avg_tools_per_reply, max_tools_per_reply, min_tools_per_reply


def create_bar_chart(counts_devs, counts_auditors, num_responses_devs, num_responses_auditors, output_file):
    """
    Create a bar chart comparing tool usage between developers and auditors.

    Args:
        counts_devs (pd.Series): Tool counts for developers.
        counts_auditors (pd.Series): Tool counts for auditors.
        num_responses_devs (int): Number of responses from developers.
        num_responses_auditors (int): Number of responses from auditors.
        output_file (str): Path to save the chart as an image file.
    """
    fig, ax = plt.subplots()

    counts_devs_pct = (counts_devs / num_responses_devs) * 100
    counts_auditors_pct = (counts_auditors / num_responses_auditors) * 100

    bar_width = 0.35
    tools = [clean_tool_name(t) for t in counts_devs_pct.index.tolist()]

    x_devs = np.arange(len(tools))
    x_auditors = x_devs + bar_width

    counts_auditors_pct = counts_auditors_pct.reindex(counts_devs_pct.index)

    devs_bars = ax.barh(x_devs, counts_devs_pct, height=bar_width, color='lightblue', label='Devs')
    auditors_bars = ax.barh(x_auditors, counts_auditors_pct, height=bar_width, color='lightcoral', label='Auditors')

    ax.set_xlabel('Percentage of Responses')
    ax.set_xticks(np.arange(0, 80, 10))
    ax.set_xticklabels([f"{x:.0f}%" for x in np.arange(0, 80, 10)])
    ax.set_yticks(x_devs + bar_width / 2)
    ax.set_yticklabels(tools, ha='right')
    ax.legend()

    fig.set_size_inches(10, 6)
    fig.tight_layout()
    plt.savefig(output_file, bbox_inches='tight')


def main(input_path_auditors, input_path_devs, output_path):
    """
    Main function to process input files and generate a bar chart.

    Args:
        input_path_auditors (str): Path to the input CSV file for auditors.
        input_path_devs (str): Path to the input CSV file for developers.
        output_path (str): Path to save the generated chart as an image file.
    """
    configure_matplotlib()
    devs_file_path = input_path_devs
    auditors_file_path = input_path_auditors

    counts_devs, num_responses_devs, avg_devs, max_devs, min_devs = load_and_process_data(devs_file_path)
    counts_auditors, num_responses_auditors, avg_auditors, max_auditors, min_auditors = load_and_process_data(
        auditors_file_path)

    print(f'Number of Devs Responses: {num_responses_devs}')
    print(f'Average Number of Tools Mentioned in a Devs Response: {avg_devs}')
    print(f'Maximum Number of Tools Mentioned in a Devs Response: {max_devs}')
    print(f'Minimum Number of Tools Mentioned in a Devs Response: {min_devs}')

    print(f'Number of Auditors Responses: {num_responses_auditors}')
    print(f'Average Number of Tools Mentioned in an Auditors Response: {avg_auditors}')
    print(f'Maximum Number of Tools Mentioned in an Auditors Response: {max_auditors}')
    print(f'Minimum Number of Tools Mentioned in an Auditors Response: {min_auditors}')

    create_bar_chart(counts_devs, counts_auditors, num_responses_devs, num_responses_auditors, output_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some files.')
    parser.add_argument('--input_auditors_path', required=True, help='The path to the input CSV file for auditors.')
    parser.add_argument('--input_devs_path', required=True, help='The path to the input CSV file for developers.')
    parser.add_argument('--output_path', required=True, help='The path to save the generated chart as an image file.')
    args = parser.parse_args()

    main(args.input_auditors_path, args.input_devs_path, args.output_path)
