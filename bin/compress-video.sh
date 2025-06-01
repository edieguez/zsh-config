#! /usr/bin/env bash
set -eu

validate_arguments() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input_video"
    exit 1
  fi

  if [ ! -f "$1" ]; then
      echo "Error: Input file '$1' does not exist."
      exit 1
  fi
}

get_output_filename() {
  local input_file="$1"
  local basename=$(basename "$input_file")

  # echo "${basename%.*}-compressed.${basename##*.}"
  echo "${basename%.*}-compressed.mp4"
}

validate_arguments "$@"
input_file="$1"
output_file=$(get_output_filename "$input_file")

# Compress the video using ffmpeg to half its original size and using GPU
# Reference
#   1. https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg
#   2. ffmpeg -i "$input_file" -vf "scale=trunc(iw/4)*2:trunc(ih/4)*2" -c:v h264_videotoolbox "$output_file"
ffmpeg -i "$input_file" -vf "scale=trunc(iw/4)*2:trunc(ih/4)*2" -c:v h264_videotoolbox "$output_file"
