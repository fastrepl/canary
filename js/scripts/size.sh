#!/bin/bash

get_file_size() {
    curl -sL "$1" | wc -c | awk '{print int($1/1024)}'
}

urls=(
    "https://widget.kapa.ai/kapa-widget.bundle.js"
    "https://unpkg.com/@inkeep/widgets-embed@latest/dist/embed.js"
    "https://unpkg.com/@mendable/search@latest/dist/umd/mendable-bundle.min.js"
)

for url in "${urls[@]}"; do
    size=$(get_file_size "$url")
    echo "$url => ${size}KB"
done
