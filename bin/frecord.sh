#! /usr/bin/env bash
source $ZSH_CUSTOM/lib/screencast.sh
set_inputs

ffmpeg -y $parsed_inputs -filter_complex amix=inputs=$inputs_length:duration=longest audio.mp3
