#! /usr/bin/env bash

get_inputs() {
    echo $(pactl list short sources | cut -f2 | fzf \
        --multi \
        --height=80% \
        --layout=reverse \
        --info=inline \
        --border \
        --margin=1 \
        --padding=1 \
        --prompt="Use TAB to select the input sources: "
    )
}

set_inputs() {
    inputs=$(get_inputs)
    inputs_length=$(echo $inputs | wc -w)
    parsed_inputs=$(parse_inputs $inputs)

    echo $parsed_inputs
}

parse_inputs() {
    local inputs_opts=''

    for input in "$@"; do
        inputs_opts+="-f pulse -thread_queue_size 1024 -i $input "
    done

    echo $inputs_opts
}

record_audio() {
    set_inputs

    ffmpeg -y $parsed_inputs -filter_complex amix=inputs=$inputs_length:duration=longest audio.mp3
}

record_audio