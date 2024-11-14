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
grep --line-buffered -o -E "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}Z.*size: [0-9]+" | \
while read -r line; do
    echo "$line" >> "$PACKET_SIZE_LOG"
done)
