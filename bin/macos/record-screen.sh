#!/usr/bin/env bash
# set -x
set -euo pipefail

check_dependencies() {
  local dependencies=("ffmpeg" "sox")

  echo "🔍 Checking for required dependencies"

  for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
      echo "  ❌ $dep is not installed"
      exit 1
    else
      echo "  ✅ $dep is installed."
    fi
  done

  ffmpeg -f avfoundation -list_devices true -i "" &> ${tmp_devices_file} || true
  black_hole_device=$(grep -io "BlackHole 2ch" "$tmp_devices_file")

  if [[ -n "$black_hole_device" ]]; then
    echo "  ✅ Found BlackHole audio device. Internal audio will be captured"
  else
    echo "  ❌ BlackHole audio device not found. Not capturing internal audio"
  fi
}

# Clean up temp files and stop audio capture
cleanup() {
  echo "🧹 Cleaning up..."
  rm -fv "$tmp_devices_file" "$tmp_internal_audio_file" "$tmp_mic_audio_file" "$tmp_video_file"

  kill "$SOX_INTERNAL_PID" 2> /dev/null || true
  kill "$SOX_MIC_PID" 2> /dev/null || true
}

stop_audio_capture() {
  # Stop audio capture if still running
  if [[ -n "$black_hole_device" ]]; then
    kill "$SOX_INTERNAL_PID" 2> /dev/null || true
  fi

  kill "$SOX_MIC_PID" 2> /dev/null || true
}

# Configuration variables
base_name="$(date +%Y-%m-%d_%H-%M-%S)"
tmp_internal_audio_file="${base_name}_internal_audio.mp3"
tmp_mic_audio_file="${base_name}_mic_audio.mp3"
tmp_video_file="${base_name}_video.mp4"
tmp_devices_file=${base_name}_devices.txt
output_file="screencast_${base_name}.mp4"

trap cleanup EXIT INT TERM HUP
check_dependencies

echo "🎬 Starting media streams capture"

if [[ -n "$black_hole_device" ]]; then
  # Start audio recording with sox (BlackHole)
  echo "  🔈 Capturing internal audio"
  sox -q -t coreaudio "BlackHole 2ch" -r 48000 -c 2 -t mp3 "$tmp_internal_audio_file" 2> /dev/null & SOX_INTERNAL_PID=$!
fi

# Start microphone audio capture with sox
# echo "  🎙️ Capturing microphone audio"
# sox -q -t coreaudio "Nameless's Buds3 Pro 1" -r 48000 -c 2 -t mp3 "$tmp_mic_audio_file" 2> /dev/null & SOX_MIC_PID=$!

# Capture screen with hardware encoding + bitrate control
echo "  🖥️ Capturing screen"
# ffmpeg -loglevel quiet -stats \
#   -f avfoundation \
#   -i "Capture screen 0:MacBook Pro Microphone" \
#   -framerate 25 \
#   -vf "scale=trunc(iw/4)*2:trunc(ih/4)*2" \
#   -vcodec libx264 -crf 24 \
#   "$tmp_video_file" 2> /dev/null

stop_audio_capture

# Merge audio + video using GPU encoder
echo "🧬 Merging audio and video..."
# ffmpeg -loglevel quiet -stats \
# ffmpeg -loglevel quiet -stats \
#   -i "$tmp_video_file" \
#   -i "$tmp_internal_audio_file" \
#   -i "$tmp_mic_audio_file" \
#   -filter_complex "[1:a][2:a]amix=inputs=2:duration=shortest[aout]" \
#   -map 0:v \
#   -map "[aout]" \
#   -c:v copy \
#   -c:a aac -shortest "$output_file"

echo "✅ Saved as $output_file"

# mpv "$output_file"
