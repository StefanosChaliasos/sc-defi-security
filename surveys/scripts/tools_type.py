import matplotlib.pyplot as plt
import argparse
from tools_experience import configure_matplotlib


def compute_percentages(responses, total_responses):
    """
    Compute the percentages of each response based on the total number of responses.

    Args:
        responses (dict): A dictionary containing the number of responses for each category.
        total_responses (int): The total number of responses.

    Returns:
        list: A list of percentages corresponding to each response category.
    """
    return [responses[key] / total_responses * 100 for key in responses.keys()]


def create_plot(responses, percentages, output_file):
    """
    Create a horizontal bar plot of the responses with their corresponding percentages.

    Args:
        responses (dict): A dictionary containing the number of responses for each category.
        percentages (list): A list of percentages corresponding to each response category.

    Returns:
        None
    """
    fig, ax = plt.subplots()

    bar_width = 0.25
    bars = ax.barh(list(responses.keys()), list(responses.values()), height=bar_width, color='lightblue')

    for i, bar in enumerate(bars):
        ax.text(bar.get_width() + 1, bar.get_y() + bar.get_height() / 2, f"{percentages[i]:.1f}\%", va='center')

    ax.set_xlabel('Number of Responses')

    fig = plt.gcf()
    fig.set_size_inches(10, 4)
    axis = plt.gca()
    fig.tight_layout()
    plt.savefig(output_file, bbox_inches='tight')


def main():
    """
    The main function that orchestrates the computation and creation of the plot.

    Returns:
        None
    """
    configure_matplotlib()
    total_responses = 27
    responses = {
        "OSS": 25,
        "Internally developed": 14,
        "Extended existing OSS": 9,
        "Third-party service": 7,
        "Not using security tools": 2,
    }

    percentages = compute_percentages(responses, total_responses)
    create_plot(responses, percentages)


def main(output_file):
    configure_matplotlib()
    """
    The main function that orchestrates the computation and creation of the plot.

    Returns:
        None
    """
    configure_matplotlib()
    total_responses = 27
    responses = {
        "OSS": 25,
        "Internally developed": 14,
        "Extended existing OSS": 9,
        "Third-party service": 7,
        "Not using security tools": 2,
    }

    percentages = compute_percentages(responses, total_responses)
    create_plot(responses, percentages, output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some files.')
    parser.add_argument('--output_file', required=True, help='The path to the output PDF file.')
    args = parser.parse_args()

    main(args.output_file)
