#!/bin/bash

# Check if a file was provided as an argument
if [ "$#" -eq 0 ]; then
    echo "❌ Error: No input file provided."
    echo "Usage: ./process_video.sh <input_video_file>"
    echo "Example: ./process_video.sh my_recording.mov"
    exit 1
fi

INPUT_FILE="$1"

# Check if the file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Extract the filename without extension to name the output file
BASENAME=$(basename "$INPUT_FILE")
FILENAME="${BASENAME%.*}"
OUTPUT_FILE="${FILENAME}_processed.mp4"

echo "=========================================="
echo " 🎬 FFmpeg Video Post-Processor"
echo "=========================================="
echo "Input File : $INPUT_FILE"
echo "Output File: $OUTPUT_FILE"
echo "=========================================="
echo "Processing... This may take a moment depending on the video length."
echo ""

# Run the exact FFmpeg command provided
ffmpeg -i "$INPUT_FILE"   -c:v libx264 -crf 20 -preset medium -pix_fmt yuv420p   -af "afftdn=nr=12:nf=-30,pan=stereo|c0=0.5*c0+0.5*c1|c1=0.5*c0+0.5*c1"   "$OUTPUT_FILE"

echo ""
echo "=========================================="
echo "✅ Processing Complete!"
echo "Your new file is ready: $OUTPUT_FILE"
echo "=========================================="
