import sys
from datetime import datetime

def parse_file(file_path):
    timestamps = []
    with open(file_path, 'r') as file:
        for line in file:
            # Split the line into timestamp and PTS
            parts = line.strip().split(' t:')
            if len(parts) == 2:
                system_time = datetime.strptime(parts[0], "%Y-%m-%d %H:%M:%S.%f")
                pts = float(parts[1])
                timestamps.append((system_time, pts))
    return timestamps

def calculate_latency(pub_file, sub_file):
    pub_entries = parse_file(pub_file)
    sub_entries = parse_file(sub_file)
    # print(pub_entries)
    # print(sub_entries)

    latencies = []
    
    for sub_time, sub_pts in sub_entries:
        # Find the corresponding PTS in the pub entries
        for pub_time, pub_pts in pub_entries:
            if abs(pub_pts - sub_pts) < 0.001:  # Allow for slight differences
                latency = (sub_time - pub_time).total_seconds()
                latencies.append(latency)
                break  # Stop after finding the first match

    if latencies:
        average_latency = sum(latencies) / len(latencies)
        print(f'Average End-to-End Latency: {average_latency:.6f} seconds')
        print(len(latencies))
    else:
        print('No matching PTS found.')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <pub_file> <sub_file>")
        sys.exit(1)

    pub_file = sys.argv[1]
    sub_file = sys.argv[2]

    calculate_latency(pub_file, sub_file)