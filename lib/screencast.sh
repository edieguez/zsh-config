audio_opts="-acodec pcm_s16le"
video_opts="-vcodec libx264 -pix_fmt yuv420p -preset ultrafast -crf 0 -threads 0 -probesize 42M -framerate 10"

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
}

parse_inputs() {
    echo $@ | xargs -d ' ' -i echo "-f pulse -thread_queue_size 1024 -i {}" | tr '\n' ' '
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
