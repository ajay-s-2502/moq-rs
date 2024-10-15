#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -o OUTPUT_FILE"
    echo "  -o OUTPUT_FILE    File to store timestamps"
    exit 1
}

# Parse command line arguments
while getopts "o:" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if OUTPUT_FILE is set
if [ -z "$OUTPUT_FILE" ]; then
    usage
fi

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Run the subscriber and capture timestamps
docker compose run sub moq-sub --name bbb https://relay:443/bbb | \
ffplay -vf "drawtext=text='%{pts\:hms}':x=10:y=10" -loglevel debug - 2>&1 | \
grep --line-buffered -o -E "t:[0-9]+\.[0-9]+" | \
while read -r line; do
    # Get the current date and time with milliseconds
    current_time=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    # Output the current time and the playback timestamp
    echo "$current_time $line" >> "$OUTPUT_FILE"
done
