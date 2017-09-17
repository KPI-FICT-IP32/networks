#!/bin/sh

# Exit on error
set -e

usage="$(basename "$0") [-h] PATH SIZE MODE

Sets given MODE to all files in PATH whose size is twice as big as SIZE.

Options:
    -h      print this help and exit
    PATH    path to the directory in which action should be performed
    SIZE    reference size. New permissions will be set to all files
            whose size is twice as big as SIZE.
    MODE    permissions bitmask, i.e. 777, 540, etc. See MODES section
            of man chmod (1) for more details

Examples:
    # Set 777 mode to all files in /root whose sizes are exactly 10 bytes
    $(basename "$0") /root 5c 777
    $(basename "$0") /root 5 777

    # Set 644 mode to all files in / whose sizes are exactly 20k
    $(basename "$0") / 10k 644
"

while getopts 'h' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
  esac
done

shift $((OPTIND - 1))

target_path="$1"
if [ -z "$target_path" ]; then
    echo "Missing PATH parameter" >&2
    echo "$usage" >&2
    exit 1
fi

reference_size="$2"
if [ -z "$reference_size" ]; then
    echo "Missing SIZE parameter" >&2
    echo "$usage" >&2
    exit 1
fi

mode="$3"
if [ -z "$mode" ]; then
    echo "Missing MODE parameter" >&2
    echo "$usage" >&2
    exit 1
fi

size_modifier=$(echo -n "$reference_size" | tail -c 1)
case "$size_modifier" in
    [ckMGTP]) 
        search_size=$((${reference_size%?} * 2))
        search_size="${search_size}${size_modifier}"
        ;;
    *)
        search_size=$(($reference_size * 2))
        search_size="${search_size}c"  # c is used for exact bytes
        ;;
esac
find "$target_path" \
    -maxdepth 1 -size "$search_size" \
    -exec chmod "$mode" {} \;
