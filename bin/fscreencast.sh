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

    local inputs_length=$(echo $inputs | wc -w)

    echo "$inputs_opts -filter_complex amix=inputs=$inputs_length:duration=longest"
}

record_video() {
    local inputs=$(get_inputs)
    local parsed_inputs=$(parse_inputs $inputs)

    local audio_opts="-acodec pcm_s16le"
    local video_opts="-vcodec libx264 -pix_fmt yuv420p -preset ultrafast -crf 0 -threads 0 -probesize 42M -framerate 10"

    read -p "Fullscreen or Window? [F/w] " -n 1 -r mode

    if [[ $mode =~ ^[Ww]$ ]]; then
        local coordinates=$(get_window_coordinates)

        ffmpeg -y \
            $parsed_inputs $audio_opts \
            -f x11grab $coordinates $video_opts \
            output.mkv
    else
        ffmpeg -y \
            $parsed_inputs $audio_opts \
            -f x11grab -i :0.0 $video_opts \
            output.mkv
    fi
}

get_window_coordinates() {
    coordinates=($(xwininfo | grep -E '(Absolute|Height|Width)' | grep -Eo '[[:digit:]]+$'))

    x=${coordinates[0]}
    y=${coordinates[1]}

    width=$(_base_2 ${coordinates[2]})
    height=$(_base_2 ${coordinates[3]})

    echo "-s ${width}x${height} -i :0.0+${x},${y}"
}

_base_2() {
    if [ $(($1 % 2)) -eq 1 ]; then
        echo $(($1 - 1))
    else
        echo $1
    fi
}

record_video
