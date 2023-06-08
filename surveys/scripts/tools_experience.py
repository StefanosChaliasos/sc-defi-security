import argparse
import csv
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import matplotlib
import re

def configure_matplotlib():
    """
    Configure the matplotlib settings for the plot.

    Returns:
        None
    """
    matplotlib.rcParams['text.usetex'] = True
    matplotlib.use('Agg')
    sns.set(font_scale=2.3)
    sns.set_style("whitegrid")

    width = 4
    font = {'family' : 'normal',
            'weight' : 'normal',
            'size'   : 22}
    plt.rc('font', **font)

def clean_tool_name(name):
    """
    Clean the tool name by removing unnecessary characters and patterns.

    Args:
        name (str): The original tool name.

    Returns:
        str: The cleaned tool name.
    """
    name = str(name)
    name = re.sub(r'Other\.[1-9]', 'Other', name)
    name = name.replace('Model checking/', '')
    name = name.replace('/Bytecode hardening', '')
    name = re.sub(r'\(.*\)', '', name).strip()
    return name

def read_data(file_path, columns_range):
    """
    Read the data from the CSV file and compute the tool counts and statistics.

    Args:
        file_path (str): The path to the CSV file.
        columns_range (range): The range of columns containing the tool data.

    Returns:
        pandas.Series: The tool counts.
        int: The number of responses.
        float: The average number of tools mentioned in a response.
        int: The maximum number of tools mentioned in a response.
        int: The minimum number of tools mentioned in a response.
    """
    df = pd.read_csv(file_path)
    tools_df = df.iloc[:, columns_range]
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

def create_plot(counts_df_devs, counts_df_auditors, num_responses_devs, num_responses_auditors, output_file):
    """
    Create a horizontal bar plot of the tool usage by developers and auditors.

    Args:
        counts_df_devs (pandas.Series): The tool counts by developers.
        counts_df_auditors (pandas.Series): The tool counts by auditors.
        num_responses_devs (int): The number of responses from developers.
        num_responses_auditors (int): The number of responses from auditors.
        output_file (str): The path to the output PDF file.

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
    ax.set_xticks(np.arange(0, 110, 10))
    ax.set_xticklabels([f"{x:.0f}\%" for x in np.arange(0, 110, 10)])
    ax.set_yticks(x_devs + bar_width / 2)
    ax.set_yticklabels(tools)
    ax.legend()

    plt.legend(loc='upper right', prop={'size':22}, frameon=True)
    fig = plt.gcf()
    fig.set_size_inches(11,6)
    axis = plt.gca()
    fig.tight_layout()
    plt.savefig(output_file, bbox_inches='tight')

def main(devs_file_path, auditors_file_path, output_path):
    """
    The main function that orchestrates the analysis and plotting.

    Args:
        devs_file_path (str): The path to the developers' CSV file.
        auditors_file_path (str): The path to the auditors' CSV file.
        output_path (str): The path to the output PDF file.

    Returns:
        None
    """
    configure_matplotlib()

    counts_df_devs, num_responses_devs, avg_tools_devs, max_tools_devs, min_tools_devs = read_data(devs_file_path, range(1,11))
    print('Devs Responses:', num_responses_devs, avg_tools_devs, max_tools_devs, min_tools_devs)

    counts_df_auditors, num_responses_auditors, avg_tools_auditors, max_tools_auditors, min_tools_auditors = read_data(auditors_file_path, range(1,11))
    print('Auditors Responses:', num_responses_auditors, avg_tools_auditors, max_tools_auditors, min_tools_auditors)

    create_plot(counts_df_devs, counts_df_auditors, num_responses_devs, num_responses_auditors, output_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some files.')
    parser.add_argument('--devs_file_path', required=True, help='The path to the devs CSV file.')
    parser.add_argument('--auditors_file_path', required=True, help='The path to the auditors CSV file.')
    parser.add_argument('--output_path', required=True, help='The path to the output PDF file.')
    args = parser.parse_args()

    main(args.devs_file_path, args.auditors_file_path, args.output_path)
