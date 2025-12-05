#!/usr/bin/env bash

INPUT_DIR=""
OUTPUT_DIR=""

QUALITY=80
MAX_HEIGHT=1800

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--input) INPUT_DIR="$2"; shift ;;
        -o|--output) OUTPUT_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done  

if [ -z "$INPUT_DIR" ]; then exit 1; fi
if [ -z "$OUTPUT_DIR" ]; then 
    OUTPUT_DIR="${INPUT_DIR}_converted"
fi

get_jpg_size() {
    file="$1"
    
    echo $file
    ffprobe -v error -select_streams v:0 \
        -show_entries stream=width,height \
        -of csv=p=0 $file
}

convert_photo() {

    in="$1"
    out="$2"

    # -resize_mode <string> .. one of: up_only, down_only, always (default)

    echo "Converting photo: $in to $out"
    cwebp -q $QUALITY -preset photo -hint photo \
        -metadata all \
        -resize 0 $MAX_HEIGHT \
        -mt \
        -quiet \
        "$in" -o "$out"
}

convert_video() {

    in="$1"
    out="$2"

    echo "Converting video: $in to $out"
    ffmpeg -i $in -b:v 2000k -b:a 96k -f webm -threads 6 \
        -hide_banner -nostats -loglevel error -y $out
}

mkdir -p $OUTPUT_DIR

for f in "$INPUT_DIR"/*
do
    FILE_EXT="${f##*.}"
    FILE_NAME=$(basename "$f" ".$FILE_EXT")
    case "$FILE_EXT" in
        png|PNG|jpg|JPG|jpeg|JPEG)
            FILE_OUT="$OUTPUT_DIR/${FILE_NAME}.webp"
            convert_photo "$f" "$FILE_OUT"
            ;;
        mp4|MP4|mov|MOV|avi|AVI)
            FILE_OUT="$OUTPUT_DIR/${FILE_NAME}.webm"
            convert_video "$f" "$FILE_OUT"
            ;;
        *)
            echo "Skipping unsupported file type: $f"
            ;;
    esac
done    
