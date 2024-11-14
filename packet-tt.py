import re
import sys
from collections import deque

# Regex patterns to extract timestamps and sizes
timestamp_pattern = r"([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}Z)"
size_pattern = r"size: (\d+)"

def parse_log(file_path):
    """Parse the log file and extract timestamps and packet sizes."""
    packets = []
    with open(file_path, 'r') as f:
        for line in f:
            # Extract timestamp and size from each line
            timestamp_match = re.search(timestamp_pattern, line)
            size_match = re.search(size_pattern, line)
            if timestamp_match and size_match:
                timestamp = timestamp_match.group(1)
                size = int(size_match.group(1))
                packets.append((timestamp, size))
    return deque(packets)

def timestamp_to_seconds(timestamp):
    """Convert timestamp to seconds (including microseconds)."""
    date_str, time_str = timestamp.split('T')
    time_str, _ = time_str.split('Z')  # Remove 'Z' at the end
    hours, minutes, seconds = map(float, time_str.split(':'))
    total_seconds = hours * 3600 + minutes * 60 + seconds
    return total_seconds

def calculate_latency(pub_log_file, sub_log_file):
    """Calculate the latency between pub and sub logs."""
    # Parse the pub and sub logs
    pub_packets = parse_log(pub_log_file)
    sub_packets = parse_log(sub_log_file)
    
    latencies = []
    
    while pub_packets and sub_packets:
        pub_timestamp, pub_size = pub_packets[0]
        sub_timestamp, sub_size = sub_packets[0]
        
        # Check if sizes match
        if pub_size == sub_size:
            # Convert timestamps to seconds (including microseconds)
            pub_time = timestamp_to_seconds(pub_timestamp)
            sub_time = timestamp_to_seconds(sub_timestamp)
            latency = sub_time - pub_time  # Subtract sub timestamp from pub timestamp
            latencies.append(latency)
            pub_packets.popleft()  # Move to next pub packet
            sub_packets.popleft()  # Move to next sub packet
        else:
            # If sizes don't match, move to the next pub packet
            pub_packets.popleft()
    
    # Output the latency results
    if latencies:
        avg_latency = sum(latencies) / len(latencies)
        
        for latency in latencies:
            if latency < 0:
                print("negative latency found")

        print(len(latencies))
        print(f"Average latency: {avg_latency*1000:.3f} ms")
    else:
        print("No matching packets found.")

# Command line argument parsing
if len(sys.argv) != 3:
    print("Usage: python script.py <pub_log_file> <sub_log_file>")
    sys.exit(1)

pub_log_file = sys.argv[1]
sub_log_file = sys.argv[2]

# Calculate and print latency
calculate_latency(pub_log_file, sub_log_file)
