# Use an official Python runtime as a parent image
FROM python:3.10

WORKDIR /home

# Install pdflatex
RUN apt-get update && \
    apt-get install -y texlive-latex-base texlive-latex-recommended texlive-latex-extra texlive-science && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir numpy pandas matplotlib seaborn tabulate

# Set bash as the default command
CMD ["/bin/bash"]
