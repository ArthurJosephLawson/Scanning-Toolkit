#!/bin/bash

TARGET="${1:-.}"

if [[ ! -d "$TARGET" ]]; then
    echo "Error: $TARGET is not a directory"
    exit 1
fi

echo "Folder Scanner"
echo "=============="
echo "Scanning: $(realpath "$TARGET")"
echo ""

stat --printf="Name: %n\nType: %F\nSize: %s bytes\nAccess: %a (%A)\nUID/GID: %u/%g\nCreated: %w\nModified: %y\nChanged: %z\nAccessed: %x\n" "$TARGET"

echo ""
echo "Contents"
echo "--------"
echo "Date              Size  Perms  Owner    Name"
echo "----------------  ----- ------ -------- -------------------"
ls -la --time-style=long-iso "$TARGET" | tail -n +2 | while read -r line; do
    perms=$(echo "$line" | awk '{print $1}')
    owner=$(echo "$line" | awk '{print $3}')
    group=$(echo "$line" | awk '{print $4}')
    size=$(echo "$line" | awk '{print $5}')
    date=$(echo "$line" | awk '{print $6}')
    time=$(echo "$line" | awk '{print $7}')
    name=$(echo "$line" | awk '{$1=$2=$3=$4=$5=$6=$7=""; print substr($0,8)}' | sed 's/^ *//')
    printf "%s %s  %5s  %s  %-8s %s\n" "$date" "$time" "$size" "$perms" "$owner" "$name"
done

echo ""
echo "Total items: $(ls -1 "$TARGET" | wc -l)"
echo "Subdirs: $(ls -ld "$TARGET"/*/ 2>/dev/null | wc -l)"
echo "Files: $(find "$TARGET" -maxdepth 1 -type f | wc -l)"
