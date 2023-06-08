from tools_experience import configure_matplotlib
import re
import numpy as np
import pandas as pd
import argparse
import matplotlib.pyplot as plt

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
    name = re.sub(r'Other\.[1-9]', 'Other', name)
    name = name.replace('Other formal verification / model checking tool', 'Other FV')
    name = name.replace("Foundry's propert-based fuzzer", "Foundry's fuzzer")
    name = name.replace('Other static analyzer', 'Other SA')
    name = name.replace('Other symbolic execution tool', 'Other SE')
    name = name.replace('Other runtime monitoring', 'Runtime monitoring')
    name = re.sub(r'\(.*\)', '', name).strip()
    return name

def replace_tools(row):
    """
    Replace and clean specific tool names in a row of the DataFrame.

    Args:
        row (pandas.Series): A row in the DataFrame.

    Returns:
        pandas.Series: The modified row.
    """
    if row['Other.4'] == "We (ConsenSys Diligence) use our fuzzer Harvey":
        row['Other.4'] = np.nan
    if row['Other.4'] == "contract library etc":
        row['Other.4'] = np.nan
        row["Other static analyzer (similar to Slither)"] = "Other static analyzer (similar to Slither)"
    if row['Other.4'] == "our static analyzer + symbolic execution tool":
        row['Other.4'] = np.nan
        row["Other static analyzer (similar to Slither)"] = "Other static analyzer (similar to Slither)"
        row[
            "Other symbolic execution tool (Similar to Mythril)"] = "Other symbolic execution tool (Similar to Mythril)"
    if row['Other.4'] == "Analyses running on top of the gigahorse framework":
        row['Other.4'] = np.nan
        row["Other static analyzer (similar to Slither)"] = "Other static analyzer (similar to Slither)"
    return row

def analyze_devs_data(devs_file_path):
    """
    Analyze the developers' data by counting tool mentions and computing statistics.

    Args:
        devs_file_path (str): The path to the developers' CSV file.

    Returns:
        pandas.Series: The tool counts by developers.
        int: The number of responses from developers.
    """
    df_devs = pd.read_csv(devs_file_path)
    tools_df_devs = df_devs.iloc[:, 51:71]
    tools_df_devs = tools_df_devs.notna()
    tools_df_devs = tools_df_devs.loc[:, ~(
                ((tools_df_devs.columns == 'Maian') | (tools_df_devs.columns == 'Securify2')) & ~(
                    tools_df_devs == True).any())]
    counts_df_devs = tools_df_devs.sum(axis=0)
    counts_df_devs = counts_df_devs.sort_values(ascending=False)
    counts_df_devs.index = counts_df_devs.index.map(clean_tool_name)

    num_responses_devs = 24
    print('Number of Devs Responses:', num_responses_devs)

    num_tools_per_reply_devs = tools_df_devs.sum(axis=1)
    avg_tools_per_reply_devs = num_tools_per_reply_devs.mean()
    max_tools_per_reply_devs = num_tools_per_reply_devs.max()
    min_tools_per_reply_devs = num_tools_per_reply_devs.min()

    print('Average Number of Tools Mentioned in a Devs Response:', avg_tools_per_reply_devs)
    print('Maximum Number of Tools Mentioned in a Devs Response:', max_tools_per_reply_devs)
    print('Minimum Number of Tools Mentioned in a Devs Response:', min_tools_per_reply_devs)

    return counts_df_devs, num_responses_devs

def analyze_auditors_data(auditors_file_path):
    """
    Analyze the auditors' data by counting tool mentions and computing statistics.

    Args:
        auditors_file_path (str): The path to the auditors' CSV file.

    Returns:
        pandas.Series: The tool counts by auditors.
        int: The number of responses from auditors.
    """
    df_auditors = pd.read_csv(auditors_file_path)
    tools_df_auditors = df_auditors.iloc[:, 50:70]

    tools_df_auditors = tools_df_auditors.apply(replace_tools, axis=1)
    tools_df_auditors = tools_df_auditors.notna()
    tools_df_auditors = tools_df_auditors.loc[:, ~(
                ((tools_df_auditors.columns == 'Maian') | (tools_df_auditors.columns == 'Securify2')) & ~(
                    tools_df_auditors == True).any())]
    counts_df_auditors = tools_df_auditors.sum(axis=0)
    counts_df_auditors = counts_df_auditors.sort_values(ascending=False)
    counts_df_auditors.index = counts_df_auditors.index.map(clean_tool_name)

    num_responses_auditors = 22
    print('Number of Auditors Responses:', num_responses_auditors)

    num_tools_per_reply_auditors = tools_df_auditors.sum(axis=1)
    avg_tools_per_reply_auditors = num_tools_per_reply_auditors.mean()
    max_tools_per_reply_auditors = num_tools_per_reply_auditors.max()
    min_tools_per_reply_auditors = num_tools_per_reply_auditors.min()

    print('Average Number of Tools Mentioned in an Auditors Response:', avg_tools_per_reply_auditors)
    print('Maximum Number of Tools Mentioned in an Auditors Response:', max_tools_per_reply_auditors)
    print('Minimum Number of Tools Mentioned in an Auditors Response:', min_tools_per_reply_auditors)

    return counts_df_auditors, num_responses_auditors

def plot_tools_usage(counts_df_devs, counts_df_auditors, num_responses_devs, num_responses_auditors, output_file):
    """
    Plot the usage of tools by developers and auditors.

    Args:
        counts_df_devs (pandas.Series): The tool counts by developers.
        counts_df_auditors (pandas.Series): The tool counts by auditors.
        num_responses_devs (int): The number of responses from developers.
        num_responses_auditors (int): The number of responses from auditors.
        output_file (str): The path to the output file (PDF).

    Returns:
        None
    """
    counts_df_devs_pct = (counts_df_devs / num_responses_devs) * 100
    counts_df_devs_pct = counts_df_devs_pct[:-1]
    counts_df_auditors_pct = (counts_df_auditors / num_responses_auditors) * 100
    counts_df_auditors_pct = counts_df_auditors_pct[:-1]

    tools = [clean_tool_name(t) for t in counts_df_devs_pct.index.tolist()]

    fig, ax = plt.subplots()

    bar_width = 0.35
    x_devs = np.arange(len(tools))
    x_auditors = x_devs + bar_width

    counts_df_auditors_pct = counts_df_auditors_pct.reindex(counts_df_devs_pct.index)

    devs_bars = ax.barh(x_devs, counts_df_devs_pct, height=bar_width, color='lightblue', label='Devs')
    auditors_bars = ax.barh(x_auditors, counts_df_auditors_pct, height=bar_width, color='lightcoral', label='Auditors')

    ax.set_xlabel('Percentage of Responses')
    ax.set_xticks(np.arange(0, 90, 10))
    ax.set_xticklabels([f"{x:.0f}%" for x in np.arange(0, 90, 10)])

    ax.set_yticks(x_devs + bar_width / 2)
    ax.set_yticklabels(tools, ha='right')

    ax.legend()

    plt.legend(loc='upper right', prop={'size': 10}, frameon=True)
    fig = plt.gcf()
    fig.set_size_inches(9, 8)
    axis = plt.gca()
    fig.tight_layout()
    plt.savefig(output_file, bbox_inches='tight')

def main(devs_file_path, auditors_file_path, output_file):
    """
    The main function that orchestrates the analysis and plotting.

    Args:
        devs_file_path (str): The path to the developers' CSV file.
        auditors_file_path (str): The path to the auditors' CSV file.
        output_file (str): The path to the output PDF file.

    Returns:
        None
    """
    configure_matplotlib()
    counts_df_devs, num_responses_devs = analyze_devs_data(devs_file_path)
    counts_df_auditors, num_responses_auditors = analyze_auditors_data(auditors_file_path)
    plot_tools_usage(counts_df_devs, counts_df_auditors, num_responses_devs, num_responses_auditors, output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some files.')
    parser.add_argument('--devs_file_path', required=True, help='The path to the devs CSV file.')
    parser.add_argument('--auditors_file_path', required=True, help='The path to the auditors CSV file.')
    parser.add_argument('--output_file', required=True, help='The path to the output PDF file.')
    args = parser.parse_args()

    main(args.devs_file_path, args.auditors_file_path, args.output_file)
