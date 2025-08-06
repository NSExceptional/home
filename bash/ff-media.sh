#
#  ff-media.sh
#  bash
#  
#  Created by Tanner Bennett on 2024-07-10
#  Copyright © 2025 Tanner Bennett. All rights reserved.
#

# Some notes:
# • AVC = h.264
# • HEVC = h.265
# • AV1 is marginally better than HEVC but not widely supported yet

__h26ify_flags="-c:v libx265 -tag:v hvc1 -movflags use_metadata_tags -copyts"

# Accepts a file path and converts it to an h.265 file and saves it with the
# same name but with the extension .hevc.mp4, replacing the old extension.
h26ify() {
    ffmpeg -i "$1" $__h26ify_flags -crf 15 "${1%.*}.hevc.mp4"
}

# Shrink a screen recording down where quality doesn't matter
srshrink() {
    ffmpeg -i "$1" $__h26ify_flags -crf 30 "${1%.*}.mp4"
}

# Like h26ify but you can specify the crf quality

h26ifyq() {
    ffmpeg -i "$1" $__h26ify_flags -crf $2 "${1%.*}.hevc.mp4"
}

# Like h26ify but keeps the original quality
h26ifyo() {
    local output="${1%.*}.hevc.mp4"
    if [ -n "$2" ]; then
        output="$2"
    fi
    
    ffmpeg -i "$1" $__h26ify_flags "$output"
}

hevc2mp4() {
    zsh_invoke $@
}

_ffinfo() {
    local ffargs="-v error -select_streams v:0 -of default=noprint_wrappers=1:nokey=1 -show_entries -count_frames"
    local codec="stream=codec_name"
    local codec_long="stream=codec_long_name"
    local container_long="format=format_long_name"
    local containers="format=format_name"
    local width="stream=width"
    local height="stream=height"
    local fps="stream=r_frame_rate"
    local total_frames="stream=nb_frames"
    local duration="format=duration"
    
    # If `-c <field>` is passed, copy that field to the clipboard
    if [[ $1 == "-c" ]]; then
        ffargs="-v error -select_streams v:0 -of default=noprint_wrappers=1:nokey=1 -show_entries"
        shift
        local copy="$1"
        local copy_field=""
        
        case $copy in
            codec) copy_field=$codec ;;
            codec_long) copy_field=$codec_long ;;
            container_long) copy_field=$container_long ;;
            containers) copy_field=$containers ;;
            width) copy_field=$width ;;
            height) copy_field=$height ;;
            fps) copy_field=$fps ;;
            total_frames) copy_field=$total_frames ;;
            duration) copy_field=$duration ;;
            *) echo "Invalid field: $copy"; return 1 ;;
        esac
        
        echo ffprobe $ffargs $copy_field "$2" | pbcopy
        return
    fi
    
    codec=`ffprobe $ffargs $codec "$1"`
    codec_long=`ffprobe $ffargs $codec_long "$1"`
    container_long=`ffprobe $ffargs $container_long "$1"`
    containers=`ffprobe $ffargs $containers "$1"`
    width=`ffprobe $ffargs $width "$1"`
    height=`ffprobe $ffargs $height "$1"`
    fps=`ffprobe $ffargs $fps "$1"`
    total_frames=`ffprobe $ffargs $total_frames "$1"`
    duration=`ffprobe $ffargs $duration "$1"`
    duration=$(echo "$duration" | awk '{printf "%d:%02d:%02d", $1/3600, ($1%3600)/60, $1%60}')
    
    echo "Codec: $codec ($codec_long)"
    echo "Container: $containers ($container_long)"
    echo "Resolution: $width x $height"
    echo "FPS: $fps"
    echo "Total Frames: $total_frames"
    echo "Duration: $duration"
    
    # echo "(AVC = h.264 | HEVC = h.265)"
}

_ffinfojson() {
    ffprobe -v error -show_format -show_streams -print_format json "$1"
}

# Print all functions in this file with their description
ffhelp() {
    local functions=(
        "ffinfo: Print information about a video file"
        "ffinfojson: Print information about a video file in JSON format"
        "h26ify: Convert a video file to h.265"
        "h26ifyq: Convert a video file to h.265 with a specified quality"
        "h26ifyo: Convert a video file to h.265 with the original quality"
        "hevc2mp4: Convert a HEVC video file to MP4"
        "srshrink: Shrink a screen recording down where quality doesn't matter"
    )

    for func in "${functions[@]}"; do
        echo "  $func"
    done
}
