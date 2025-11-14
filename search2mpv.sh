#!/bin/sh

RESULTS_COUNT=30
QUALITY="480"       # 144, 240, ..., best, worst, bestaudio (audio only)
FPS="30"
VIDEO_CODEC="avc1"  # avc1 (h264), vp9, av01 (av1), any
AUDIO_CODEC="any"   # opus, mp4a (aac), any

#####

if [[ -z "$1" ]]; then
  echo "Usage: $0 search_query"
  exit 1
fi

echo "Searching..."
tmp_file=$(mktemp)
yt-dlp --flat-playlist "ytsearch$RESULTS_COUNT:$*" --print "%(id)s|||%(title)s|||%(uploader_id)s|||%(duration_string)s" > "$tmp_file"

# output formatting
cat "$tmp_file" | sed 's/^[^|]*|||//' | sed 's/|||/ :: [/' | sed 's/|||/] - /' | nl -w1 -s'. '

read -p "Number? " n
video_id=$(sed -n "${n}p" "$tmp_file" | cut -d'|' -f1)
rm "$tmp_file"

if [[ -z "$video_id" ]]; then
  echo "Invalid video id :("
  exit 1
fi

echo "Playing..."
if [[ "$VIDEO_CODEC" == "any" ]]; then
  vcodec_selector=""
else
  vcodec_selector="[vcodec^=${VIDEO_CODEC}]"
fi

if [[ "$AUDIO_CODEC" == "any" ]]; then
  acodec_selector=""
else
  acodec_selector="[acodec^=${AUDIO_CODEC}]"
fi

if [[ "$QUALITY" == "bestaudio" ]]; then
  format="bestaudio"
elif [[ "$QUALITY" == "best" ]]; then
  format="best"
elif [[ "$QUALITY" == "worst" ]]; then
  format="worst"
else
  format="bestvideo${vcodec_selector}[height<=${QUALITY}][fps<=${FPS}]+bestaudio/bestvideo[height<=${QUALITY}]+bestaudio/bestvideo+bestaudio/best"
fi

mpv_opts="--ytdl-format=$format --volume=80 --no-cache --vo=gpu --hwdec=auto"
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
  mpv_opts="$mpv_opts --gpu-context=drm"
  echo "mpv: TTY mode - using DRM..."
fi

mpv $mpv_opts "https://www.youtube.com/watch?v=$video_id"

