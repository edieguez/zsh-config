#! /usr/bin/env bash
source $ZSH_CUSTOM/lib/screencast.sh
set_inputs

ffmpeg -y \
    $parsed_inputs $audio_opts \
    -f x11grab -i :0.0 $video_opts \
    output.mkv
