#!/usr/bin/env bash

set -u -o pipefail
set -E

usage() {
    echo "Usage: $0 [-i input.jpg] [-o dir] [-l levels] [-d]" 1>&2
    exit 1
}

output_dir=.
min_zoom_size=256
tile_size=256

while getopts "i:o:l:dm:t:" opt; do
    case ${opt} in
        d) set -x ;;
        i) input="$OPTARG" ;;
        l) levels="$OPTARG" ;;
        o) output_dir="$OPTARG" ;;
        m) min_zoom_size="$OPTARG" ;;
        t) tile_size="$OPTARG" ;;
        *) usage ;;
    esac
done

shift "$((OPTIND-1))"

if [ ! -d "$output_dir" ]; then
    echo "Output directory ${output_dir} does not exist." 1>&2
    exit 1
fi

extension="${input##*.}"

function get_dimensions() {
    local input="$1"
    echo $(identify -format '%w' "$input")
}

function create_tiles() {
    local input="$1"
    local level="$2"
    local output_dir_lvl="${output_dir}/${level}"
    local level_size=$(( $min_zoom_size * (2**$level) ))

    mkdir -p "$output_dir_lvl"
    convert "$input" \
        -resize ${level_size}x${level_size} \
        -crop ${tile_size}x${tile_size} \
        -set filename:tile \
        ${output_dir_lvl}/%[fx:page.x/${tile_size}]-%[fx:page.y/${tile_size}] %[filename:tile].${extension}
}

for level in $(eval echo {0..$levels}) ; do
    create_tiles "$input" "$level"
done
