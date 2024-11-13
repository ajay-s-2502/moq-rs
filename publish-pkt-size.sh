#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -o PACKET_SIZE_LOG -v VIDEO_FILE"
    echo "  -o PACKET_SIZE_LOG   File to store packet sizes"
    echo "  -v VIDEO_FILE          Input video file"
    exit 1
}

# Parse command line arguments
while getopts "o:v:" opt; do
    case $opt in
        o) PACKET_SIZE_LOG="$OPTARG" ;;
        v) VIDEO_FILE="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if both PACKET_SIZE_LOG and VIDEO_FILE are set
if [ -z "$PACKET_SIZE_LOG" ] || [ -z "$VIDEO_FILE" ]; then
    usage
fi

# Clear the packet size log file if it exists
> "$PACKET_SIZE_LOG"

# Run ffmpeg and moq-pub, then log packet sizes
ffmpeg -stream_loop -1 -re -i "$VIDEO_FILE" \
  -vf "drawtext=text='%{pts\:hms}':x=10:y=10" \
  -an -c:v libx265 -preset ultrafast -tune zerolatency -f mp4 \
  -movflags cmaf+separate_moof+delay_moov+skip_trailer+frag_every_frame - | \
  docker compose run -T pub moq-pub --name bbb https://relay:443 2> >( \
  grep --line-buffered -o -E "size: [0-9]+" | \
  while read -r line; do
      size=$(echo "$line" | awk '{print $2}')
      current_time=$(date '+%Y-%m-%d %H:%M:%S.%3N')
      echo "$current_time packet size: $size" >> "$PACKET_SIZE_LOG"
  done)

