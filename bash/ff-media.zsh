#
#  media-commands.zsh
#  bash
#  
#  Created by Tanner Bennett on 2024-11-12
#

# Some notes:
# • AVC = h.264
# • HEVC = h.265
# • AV1 is marginally better than HEVC but not widely supported yet

# tag: HEVC MKV → HEVC MP4
# transcode: AVC MKV → AVC MP4
# convert: AVC anything → HEVC MP4

transcodeHEVCAll() {
    for file in "$1"/**/*(.); do
        transcodeHEVC "$file"
    done
}

transcodeHEVC() {
    file="$1"
    ext="${file##*.}"
    base=$(basename "$file" $ext)
    out="$(pwd)/${base}mp4"

    ffmpeg -i "$file" -metadata:s:a:0 language=eng -metadata:s:a:0 title="ENG" -c copy -c:s mov_text -tag:v hvc1 "$out"
}

transcodeAll() {
    for file in "$1"/**/*(.); do
        avc2mp4 "$file"
    done
}

avc2mp4() {
    transcodeWSubs "$1"
}

transcodeNoSub() {
    file="$1"
    ext="${file##*.}"
    base=$(basename "$file" $ext)
    out="$(pwd)/${base}mp4"

    ffmpeg -i "$file" -c copy "$out"
}

transcodeWSubsAll() {
    for file in "$1"/**/*(.); do
        transcodeWSubs "$file"
    done
}

transcodeWSubs() {
    file="$1"
    ext="${file##*.}"
    base=$(basename "$file" $ext)
    out="$(pwd)/${base}mp4"

    ffmpeg -i "$file" -metadata:s:a:0 language=eng -metadata:s:a:0 title="ENG" -c:v copy -c:a copy -c:s mov_text "$out"
}

convertAll() {
    for file in "$1"/**/*(.); do
        convert "$file"
    done
}

avc2mp4_() {
    file="$1"
    ext="${file##*.}"
    base=$(basename "$file" $ext)
    out="$(pwd)/${base}mp4"

    ffmpeg -i "$file" -metadata:s:a:0 language=eng -metadata:s:a:0 title="ENG" -c:v libx265 -tag:v hvc1 -crf 23 -c:a eac3 -b:a 320k -c:s mov_text "$out"
}

tagAll() {
    for file in "$1"/**/*(.); do
        hevc2mp4 "$file"
    done
}

tagAllNoSubs() {
    for file in "$1"/**/*(.); do
        tagNoSubs "$file"
    done
}

# Tag HEVC MP4 files with the `hvc1` tag so they display correctly on Apple platforms
hevc2mp4() {
    file="$1"
    ext="${file##*.}"
    base=$(basename "$file" $ext)
    tagged="$(pwd)/${base}-tagged.mp4"
    out="$(pwd)/${base}mp4"

    ffmpeg -i "$file" -c copy -c:s mov_text -tag:v hvc1 "$tagged"
    mv "$tagged" "$out"
}

tagNoSubs() {
    file="$1"
    ext="${file##*.}"
    base=$(basename "$file" $ext)
    tagged="$(pwd)/${base}-tagged.mp4"
    out="$(pwd)/${base}mp4"

    ffmpeg -i "$file" -c copy -tag:v hvc1 "$tagged"
    mv "$tagged" "$out"
}

ffsub() {
    video="$1"
    subs="$2"

    video_ext="${file##*.}"
    video_base=$(basename $video $video_ext)
    subbed="$(pwd)/${base}-subbed.mp4"

    output="$video"

    ffmpeg -i "$video" -i "$subs" -c copy -c:s mov_text \
        -metadata:s:a:0 language=eng -metadata:s:a:0 title="ENG" \
        -metadata:s:s:0 language=eng -metadata:s:s:0 title="ENG" \
        "$subbed"

    rm -r "$video"
    rm -r "$subs"

    mv -v "$subbed" "$output"
}

applySubs() {
    files=(
        "/Volumes/SSD/Media/Movies/Dallas Buyer's Club (2013)"
        "/Volumes/SSD/Media/Movies/Days of Heaven (1978)"
        "/Volumes/SSD/Media/Movies/Delicatessen (1991)"
        "/Volumes/SSD/Media/Movies/Would It Kill You To Laugh (2022)"
    )

    for file in $files; do
        ffsub "${file}.mp4" "${file}.srt"
    done
}

hevcVideo() {
    file="$1"
    file_name=$file:t:r

    echo "Converting $file_name to HEVC..."

    input="$(pwd)/${file_name}.x264.mp4"
    tmp_output="$(pwd)/${file_name}.x265.mp4"
    output="$(pwd)/${file_name}.mp4"

    mv "$file" "$input"
    ffmpeg -i "$input" -c:v libx265 -tag:v hvc1 -crf 23 -c:a eac3 -b:a 320k "$tmp_output"
    mv "$tmp_output" "$output"
    # rm -rf "$input"

    echo "Converted $output to HEVC!"
}

hevcAll() {
    for file in "$1"/**/*(.); do
        isHevc="$(ffprobe -v error -select_streams v -show_entries stream=codec_name,codec_type -of default=noprint_wrappers=1 "$file" | grep hevc)"

        # Not HEVC; -z == empty string
        if [ -z $isHevc ]; then
            hevcVideo "$file"
        else
            file_name=$file:t:r
            echo "Skipping $file_name; Already HEVC"
        fi
    done
}
