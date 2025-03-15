#! /usr/bin/env bash
source $ZSH_CUSTOM/lib/screencast.sh
set_inputs

output_file="ffscreencast_$(date +%F_%H:%M:%S).mkv"
echo "Recording to $output_file"

ffmpeg -y \
    $parsed_inputs $audio_opts \
    -f x11grab -i :0.0 $video_opts \
    $output_file
