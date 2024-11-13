#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -o PACKET_SIZE_LOG"
    echo "  -o PACKET_SIZE_LOG     File to store packet sizes"
    exit 1
}

# Parse command line arguments
while getopts "p:o:" opt; do
    case $opt in
        o) PACKET_SIZE_LOG="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if PACKET_SIZE_LOG is set
if [ -z "$PACKET_SIZE_LOG" ]; then
    usage
fi

# Clear the log file if exists
> "$PACKET_SIZE_LOG"

# Run the subscriber and capture timestamps
docker compose run sub moq-sub --name bbb https://relay:443/bbb > out.mp4 2> >( \
grep --line-buffered -o -E "size: [0-9]+" | \
while read -r line; do
    # Extract the packet size
    size=$(echo "$line" | awk '{print $2}')
    # Get the current timestamp
    current_time=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    # Write the timestamped packet size to a log file
    echo "$current_time packet size: $size" >> "$PACKET_SIZE_LOG"
done)
