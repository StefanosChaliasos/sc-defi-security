import datetime
import json
import os

from scripts.utils.z_dasp10extended_map import VULNS_LOOKUP


def canonicalise(vuln):
    try:
        return VULNS_LOOKUP[vuln]
    except KeyError:
        print(f"Error: {vuln} does not exists in VULNS_LOOKUP")
        import sys
        sys.exit()


path = "../../smartbugs/results"

result_id_counter = 0
print("Processing ", path)

finding_id_counter = 0
total_duration_eth = 0
total_duration_bsc = 0
total_duration = 0
result_rows = []
finding_rows = []
conkas = 0
HoneyBadger = 0
MadMax = 0
Maian = 0
Mythril = 0
Osiris = 0
Oyente = 0
Securify = 0
Vandal = 0

for dirpath, dirnames, filenames in os.walk(path):
    # Last directory that does not have any subdirectories.
    if len(dirnames) == 0:
        dirpath_minus_addr, address = os.path.split(dirpath)
        dirpath_minus_date, result_date = os.path.split(dirpath_minus_addr)
        _, tool_name = os.path.split(dirpath_minus_date)

        for filename in [f for f in filenames if f.endswith(".json")]:

            result_path = os.path.join(dirpath, filename)
            with open(result_path, 'r') as f:
                results = json.load(f)
                if 'contract' not in results:
                    continue

                duration = results['duration']
                if result_date in ["20220709_1907", "20220802_0043"]:  # Ethereum runs
                    total_duration_eth += duration
                else:
                    total_duration_bsc += duration
                total_duration += duration

                if tool_name == "conkas":
                    conkas += duration
                elif tool_name == "honeybadger":
                    HoneyBadger += duration
                elif tool_name == "madmax":
                    MadMax += duration
                elif tool_name == "maian":
                    Maian += duration
                elif tool_name == "mythril":
                    Mythril += duration
                elif tool_name == "osiris":
                    Osiris += duration
                elif tool_name == "oyente":
                    Oyente += duration
                elif tool_name == "securify":
                    Securify += duration
                elif tool_name == "vandal":
                    Vandal += duration

print(f"Total Execution Time: {str(datetime.timedelta(seconds=total_duration))}")
print(f"Total Ethereum Execution Time: {str(datetime.timedelta(seconds=total_duration_eth))}")
print(f"Total BSC Execution Time: {str(datetime.timedelta(seconds=total_duration_bsc))}")

print(f"Ethereum Avg Time per Contract: {str(datetime.timedelta(seconds=total_duration_eth / 314))}")
print(f"BSC Avg Time per Contract: {str(datetime.timedelta(seconds=total_duration_eth / 213))}")
print()
print("Tool\tAvg time / contract\t\tTotal")
print("Conkas:\t" + str(datetime.timedelta(seconds=conkas / 527)) + "\t" + str(datetime.timedelta(seconds=conkas)))
print("HoneyBadger:\t" + str(datetime.timedelta(seconds=HoneyBadger / 527)) + "\t" + str(
    datetime.timedelta(seconds=HoneyBadger)))
print("MadMax:\t" + str(datetime.timedelta(seconds=MadMax / 527)) + "\t" + str(datetime.timedelta(seconds=MadMax)))
print("Maian:\t" + str(datetime.timedelta(seconds=Maian / 527)) + "\t" + str(datetime.timedelta(seconds=Maian)))
print("Mythril:\t" + str(datetime.timedelta(seconds=Mythril / 527)) + "\t" + str(datetime.timedelta(seconds=Mythril)))
print("Osiris:\t" + str(datetime.timedelta(seconds=Osiris / 527)) + "\t" + str(datetime.timedelta(seconds=Osiris)))
print("Oyente:\t" + str(datetime.timedelta(seconds=Oyente / 527)) + "\t" + str(datetime.timedelta(seconds=Oyente)))
print(
    "Securify:\t" + str(datetime.timedelta(seconds=Securify / 527)) + "\t" + str(datetime.timedelta(seconds=Securify)))
print("Vandal:\t" + str(datetime.timedelta(seconds=Vandal / 527)) + "\t" + str(datetime.timedelta(seconds=Vandal)))
