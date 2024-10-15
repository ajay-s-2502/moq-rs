#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -o OUTPUT_FILE -v VIDEO_FILE"
    echo "  -o OUTPUT_FILE    File to store timestamps"
    echo "  -v VIDEO_FILE     Input video file"
    exit 1
}

# Parse command line arguments
while getopts "o:v:" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG" ;;
        v) VIDEO_FILE="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if both OUTPUT_FILE and VIDEO_FILE are set
if [ -z "$OUTPUT_FILE" ] || [ -z "$VIDEO_FILE" ]; then
    usage
fi

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Run ffmpeg and process logs
ffmpeg -stream_loop -1 -re -i "$VIDEO_FILE" \
  -vf "drawtext=text='%{pts\:hms}':x=10:y=10" \
  -an -c:v libx265 -preset ultrafast -tune zerolatency -f mp4 \
  -movflags cmaf+separate_moof+delay_moov+skip_trailer+frag_every_frame \
  -loglevel debug - 2> >(while read line; do
      if [[ $line =~ t:([0-9]+\.[0-9]+) ]]; then
          echo "$(date '+%Y-%m-%d %H:%M:%S.%3N') t:${BASH_REMATCH[1]}" >> "$OUTPUT_FILE"
      fi
  done) | \
  docker compose run -T pub moq-pub --name bbb https://relay:443
