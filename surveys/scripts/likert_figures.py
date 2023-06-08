import argparse
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from tools_experience import configure_matplotlib

def read_data(csv_file):
    """
    Read data from a CSV file.

    Args:
        csv_file (str): The path to the CSV file.

    Returns:
        pandas.DataFrame: The data read from the CSV file.
    """
    data = pd.read_csv(csv_file)
    return data

def process_data(data, start_col, end_col):
    """
    Process the data by extracting Likert scale columns and converting them to proportions.

    Args:
        data (pandas.DataFrame): The input data.
        start_col (int): The index of the starting column.
        end_col (int): The index of the ending column.

    Returns:
        pandas.DataFrame: The proportions of each category in the Likert scale columns.
        list: The categories in the Likert scale.
    """
    likert_columns = data.iloc[:, start_col:end_col]
    likert_columns.columns = [
        'Low false positives',
        'Low false negatives',
        'Ease of use',
        'Documentation',
        'Report quality'
    ]
    categories = [
        'Strongly disagree',
        'Disagree',
        'Neither agree nor disagree',
        'Agree',
        'Strongly agree'
    ]
    for col in likert_columns.columns:
        likert_columns[col] = pd.Categorical(likert_columns[col], categories=categories, ordered=True)
    proportions = likert_columns.apply(lambda x: x.value_counts(normalize=True)).T.fillna(0)
    return proportions, categories


def plot_likert_chart(proportions, categories, output_file):
    """
        Plot a stacked horizontal bar chart of Likert scale proportions.

        Args:
            proportions (pandas.DataFrame): The proportions of each category.
            categories (list): The categories in the Likert scale.
            output_file (str): The path to the output file (PDF).

        Returns:
            None
        """
    sns.set(style="whitegrid")
    ax = proportions.plot(kind='barh', stacked=True, colormap='coolwarm_r', edgecolor='black')

    ax.set_xticklabels([])  # Remove x-tick labels
    plt.xlim(0, 1)  # Adjust x-axis limits to remove empty space on the right

    # Add percentages inside bars
    for idx, container in enumerate(ax.containers):
        for bar, prop in zip(container, proportions.iloc[:, idx]):
            if prop > 0:
                ax.text(
                    bar.get_x() + bar.get_width() / 2,
                    bar.get_y() + bar.get_height() / 2,
                    '{:.1%}'.format(prop),
                    ha='center',
                    va='center',
                    fontsize=17,
                    color='black'
                )
    ax.tick_params(axis='y', labelsize=20)

    # Add legend to the right of the figure
    ax.legend(categories, loc='upper center', bbox_to_anchor=(0.5, -0.01), ncol=len(categories)-2, frameon=True, prop={'size':15})

    # Save the figure
    fig = plt.gcf()
    fig.set_size_inches(10, 6)
    fig.tight_layout()
    plt.savefig(output_file, bbox_inches='tight')

def main(input_path_auditors, input_path_devs, output_path_auditors, output_path_devs):
    """
    The main function that orchestrates the data processing and plotting.

    Args:
        input_path (str): The path to the input CSV file.
        output_path (str): The path to the output PDF file.

    Returns:
        None
    """
    configure_matplotlib()
    data_audits = read_data(input_path_auditors)
    data_devs = read_data(input_path_devs)

    proportions_aud, categories_aud = process_data(data_audits, 11, 16)
    plot_likert_chart(proportions_aud, categories_aud, output_path_auditors)
    proportions_devs, categories_devs = process_data(data_devs, 11, 16)
    plot_likert_chart(proportions_devs, categories_devs, output_path_devs)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some files.')
    parser.add_argument('--input_auditors_path', required=True, help='The path to the input CSV file.')
    parser.add_argument('--input_devs_path', required=True, help='The path to the input CSV file.')
    parser.add_argument('--output_path_auditors', required=True, help='The path to the likert auditors PDF file.')
    parser.add_argument('--output_path_devs', required=True, help='The path to the likert developers PDF file.')
    args = parser.parse_args()

    main(args.input_auditors_path, args.input_devs_path, args.output_path_auditors, args.output_path_devs)
