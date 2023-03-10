#! /usr/bin/env bash
source $ZSH_CUSTOM/lib/screencast.sh
set_inputs

coordinates=$(get_window_coordinates)

ffmpeg -y \
    $parsed_inputs $audio_opts \
    -f x11grab $coordinates $video_opts \
    output.mkv
