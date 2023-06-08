import os
import sqlite3
import argparse


def get_args():
    """
        Parse command line arguments.
        Returns:
            Parsed command line arguments.
        """
    parser = argparse.ArgumentParser(
        prog="attack descriptive statistics",
        description="Parse the results of the analysis tools and print their findings"
    )
    parser.add_argument("db", help="The database file.")
    parser.add_argument("--dirs", nargs="+", help="Directories to be processed.")
    parser.add_argument("--src_dirs", nargs="+", help="Source directories.")
    parser.add_argument("--chains", nargs="+", help="Blockchain chains associated with the directories.")
    parser.add_argument("--txt_path", help="Path of text files for cross-checking.")
    return parser.parse_args()


def setup_db(db_path):
    """
    Set up SQLite database connection.
    Args:
        db_path: Path to the SQLite database file.
    Returns:
        Tuple containing a connection object and a cursor object.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    return conn, cursor


def get_filenames(dir_path):
    """
    List all files in the directories and remove the ".hex" extension.
    Args:
        dir_path: Path to the directory.
    Returns:
        List of filenames without the ".hex" extension.
    """
    return [f[:-4] for f in os.listdir(dir_path) if f.endswith('.hex') or f.endswith('.sol')]


def check_db_for_file(cursor, filename, chain):
    """
    For each file in directory, check if it exists in the database table column.
    Args:
        cursor: SQLite database cursor.
        filename: Filename to check.
        chain: Associated blockchain chain.
    """
    cursor.execute(
        "SELECT contract_address FROM VulnerableContract WHERE contract_address = ? AND chain = ? AND is_proxy != 1",
        (filename, chain))
    contract_addresses = [row[0] for row in cursor.fetchall()]
    if not contract_addresses:
        print(f"The file '{filename}' from '{chain}' does not exist in the database with is_proxy not equal to 1.")
    return not contract_addresses


def process_dir(cursor, dir_path, chain):
    """
    Process each file in directory with respect to the specified chain.
    Args:
        cursor: SQLite database cursor.
        dir_path: Path to the directory.
        chain: Associated blockchain chain.
    """
    filenames = get_filenames(dir_path)
    not_in_db = 0
    for filename in filenames:
        not_in_db += check_db_for_file(cursor, filename, chain)

    if not not_in_db:
        print(f"For each bytecode file in directory {dir_path}, check if it exists in the database table column. OK")


def check_db_entries_in_dir(cursor, dir_path, chain):
    """
    Check the database entries for each file in the directory.
    Args:
        cursor: SQLite database cursor.
        dir_path: Path to the directory.
        chain: Associated blockchain chain.
    """
    cursor.execute(f"SELECT contract_address FROM VulnerableContract WHERE chain = '{chain}'")
    contract_addresses = [row[0] for row in cursor.fetchall()]
    filenames = get_filenames(dir_path)
    missing_files = [x for x in contract_addresses if x not in filenames]

    # Flag to check if any file from database is missing in the directory
    missing_flag = False

    for file in missing_files:
        cursor.execute(f"SELECT is_proxy FROM VulnerableContract WHERE contract_address = '{file}'")
        result = cursor.fetchone()
        if result == 1:
            print(f"The database entry '{file}' from '{chain}' does not exist in the directory.")
            missing_flag = True

    if not missing_flag:
        print(f"Check the database entries for each file in the directory {dir_path}: OK")


def search_in_db_and_dirs(db, dirs, chains):
    """
    Search in database and directories, process each directory, and check db entries.
    Args:
        db: SQLite database file.
        dirs: List of directories.
        chains: List of associated blockchain chains.
    """
    conn, cursor = setup_db(db)
    for dir_path, chain in zip(dirs, chains):
        process_dir(cursor, dir_path, chain)
        check_db_entries_in_dir(cursor, dir_path, chain)


def cross_check_dirs_with_txt(dir_paths, txt_file_paths):
    """
      Cross-check the directories with the text files.

      This function takes as input a list of directory paths and a path to a set of text files.
      It checks if the filenames in the directory are present in the text files. The function is specific
      to directories and text files that contain 'bsc' and 'eth' in their names.

      Args:
          dir_paths (list): List of directory paths. The list should contain directories with 'bsc' and 'eth' in their paths.
          txt_file_paths (str): The directory path where the text files are located.

      Raises:
          ValueError: If the list of directory paths does not contain both 'bsc' and 'eth' directories.
      """
    dir_path1, dir_path2 = None, None
    for path in dir_paths:
        if 'bsc' in path:
            dir_path1 = path
        elif 'eth' in path:
            dir_path2 = path

    if not dir_path1 or not dir_path2:
        raise ValueError("Both 'bsc' and 'eth' directories must be provided.")

    # Get file names from both directories and text file
    filenames1 = get_filenames(dir_path1)
    filenames2 = get_filenames(dir_path2)

    # Flag to check if any file from directory is missing in the txt files
    missing_flag = False

    # Iterate over files in the directory
    for txt_file in os.listdir(txt_file_paths):
        if txt_file.endswith('.txt'):
            # Full path to the text file
            full_path = os.path.join(txt_file_paths, txt_file)

            # Open the text file and read all lines
            with open(full_path, 'r') as f:
                txt_filenames = f.read().splitlines()

                # Check if the txt file is 'eth.txt' or 'bsc.txt'
                if txt_file == 'eth.txt':
                    filenames_to_check = filenames2
                    dir_to_check = dir_path2
                elif txt_file == 'bsc.txt':
                    filenames_to_check = filenames1
                    dir_to_check = dir_path1
                else:
                    continue  # if the txt file is not 'eth.txt' or 'bsc.txt', skip to the next iteration

                # Get filenames that are not in txt_filenames
                not_included_filenames = [name for name in filenames_to_check if name not in txt_filenames]

                # Print filenames that are not included
                if not_included_filenames:
                    print(
                        f"Filenames in {dir_to_check} that are not in the text file {txt_file}: {not_included_filenames}")
                    missing_flag = True

    if not missing_flag:
        print(f"Cross-check the source directories with the text files in data/source directory: OK")


def main():
    """
    Main function to parse command line arguments and perform operations.
    """
    args = get_args()
    search_in_db_and_dirs(args.db, args.dirs, args.chains)
    cross_check_dirs_with_txt(args.src_dirs, args.txt_path)  # <-- pass source directories here


if __name__ == "__main__":
    main()
