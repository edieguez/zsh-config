#! /usr/bin/env bash
source $ZSH_CUSTOM/lib/screencast.sh
set_inputs

coordinates=$(get_window_coordinates)
output_file="ffwindowcast_$(date +%F_%H:%M:%S).mkv"
echo "Recording to $output_file"

ffmpeg -y \
    $parsed_inputs $audio_opts \
    -f x11grab $coordinates $video_opts \
    $output_file
