#!/usr/bin/env bash


OUTPUT=""
INPUT=""
DIR=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--input) INPUT="$2"; shift ;;
        -o|--output) OUTPUT="$2"; shift ;;
        -d|--dir) DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done     

MODE=""
if [ -n "$INPUT" ]; then MODE="file"; fi
if [ -n "$DIR" ]; then MODE="dir"; fi

if [ -z "$MODE" ]; then exit 1; fi

convert() {

    in="$1"
    out="$2"

    ffmpeg -i $in -b:v 2000k -b:a 96k -f webm -threads 6 -y $out

} && export -f convert


if [ "$MODE" == "file" ]; then

    if [ -z "$OUTPUT" ]; then
        OUTPUT=$(basename $INPUT .mp4)
        OUTPUT="${OUTPUT}.webm"
    fi

    convert $INPUT $OUTPUT
fi

if [ "$MODE" == "dir" ]; then

    if [ -z "$OUTPUT" ]; then
        OUTPUT="./out"
    fi

    mkdir -p $OUTPUT

    for f in $DIR/*.mp4
    do
        FILE_NAME=$(basename $f .mp4)
        FILE_NAME="$OUTPUT/${FILE_NAME}.webm"
        convert $f $FILE_NAME
    done
fi
