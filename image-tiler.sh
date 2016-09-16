#!/usr/bin/env bash

set -u -o pipefail
set -E

exists_in_path () {
    command -v "$1" >/dev/null 2>&1 \
        || { echo >&2 "I require $1 but it's not installed.  Aborting."; exit 1; }
}

for cmd in vips parallel advdef; do
    exists_in_path "$cmd"
done

usage() {
    echo "Usage: $0 [-i input.jpg] [-o dir] [-s .png] [-d]" 1>&2
    exit 1
}


output_dir=tiles
suffix=.png
tile_size=256

while getopts "i:o:ds:t:" opt; do
    case ${opt} in
        d) set -x ;;
        i) input="$OPTARG" ;;
        o) output_dir="$OPTARG" ;;
        s) suffix="$OPTARG" ;;
        t) tile_size="$OPTARG" ;;
        *) usage ;;
    esac
done

shift "$((OPTIND-1))"

function _get_new_pngs() {
    find "$output_dir" -iname "*.png"
}

echo "Creating tiles"
vips dzsave "$input" "$output_dir" --suffix "$suffix" --tile-size "$tile_size" --layout google

echo "Optimizing pngs with optipng"
_get_new_pngs | parallel -X 'optipng -quiet -o7 "{}"'

echo "Optimizing pngs with advdef"
_get_new_pngs | parallel -X 'advdef --quiet --shrink-extra -z "{}"'

echo "Done!"
