#!/usr/bin/env bash

set -u -o pipefail
set -E

usage() {
    echo "Usage: $0 [-i input.jpg] [-o dir] [-p prefix] [-l levels] [-d]" 1>&2
    exit 1
}

output_dir=.;

while getopts ":i:o:w:h:p:l:d" opt; do
    case ${opt} in
        d) set -x ;;
        i) input="$OPTARG" ;;
        l) levels="$OPTARG" ;;
        o) output_dir="$OPTARG" ;;
        p) prefix="$OPTARG" ;;
        *) usage ;;
    esac
done

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
    local output_dir="$2"
    local tile_width=256
    local tile_height=256

    convert -crop "${tile_width}x${tile_height}" +repage "$input" "${output_dir}/tile_%d.${extension}"
}

function rename_tiles() {
    local output_dir="$1"
    local tiles=$(ls "${output_dir}/" | wc -l)
    local row=0
    local column=0
    local width="$2"
    local tiles_per_column=$(($width/256))

    for tile in $(seq 0 $((tiles-1))); do
        local filename="${output_dir}/tile_${tile}.${extension}"
        local target="${output_dir}/${prefix}${column}_${row}.${extension}"
        mv "${filename}" "${target}"

        (( column++ ))

        if [ "$column" -gt "$tiles_per_column" ]; then
            column=0
            (( row++ ))
        fi 
    done
}


min_level=$((20-$levels))
level_list=$(eval echo {20..$min_level})

for level in ${level_list} ; do
    output_dir_lvl="${output_dir}/${level}"
    mkdir -p "$output_dir_lvl"

    current_image="${output_dir}/level_${level}.${extension}"

    if [[ $level -eq 20 ]]; then
        cp "$input" "$current_image"
    else
        convert "${output_dir}/level_$((level+1)).${extension}" -resize 50% "$output_dir/level_${level}.${extension}"
    fi

    create_tiles "${current_image}" "$output_dir_lvl"
    width=($(get_dimensions "$current_image"))
    rename_tiles "${output_dir_lvl}" "$width"
done
