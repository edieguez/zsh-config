#! /usr/bin/env bash
source $ZSH_CUSTOM/lib/screencast.sh
set_inputs

output_file="ffrecord_$(date +%F_%H:%M:%S).mp3"
echo "Recording to $output_file"

ffmpeg -y $parsed_inputs -filter_complex amix=inputs=$inputs_length:duration=longest $output_file
