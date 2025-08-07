#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
target_file="$script_dir/lib/src/icons.g.dart"
files_dir="$script_dir/.dart_tool/lucide-font"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed." >&2
  exit 1
fi

# check if files_dir exists
if [ ! -d "$files_dir" ]; then
    echo "Directory '$files_dir' does not exist. Please run 'download-lucide.sh <version>' first." >&2
    exit 1
fi

function toCamelCase() {
  echo "$1" | awk -F- '{
    printf "%s", $1;
    for (i=2; i<=NF; i++) {
      printf toupper(substr($i,1,1)) substr($i,2)
    }
    printf "\n"
  }'
}

function genClassHeader() {
  local class_name="$1"
  echo "// GENERATED CODE - DO NOT MODIFY BY HAND"
  echo "import 'package:flutter/widgets.dart';"
  echo "@staticIconProvider"
  echo "class $class_name {"
  echo "const $class_name._();"
}

function genIconMethod() {  
  local icon_name="$1"
  local icon_id="$2"

  echo "/// ## $icon_name"
  echo "/// <img src=\"https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/$icon_name.svg\" width=\"100\">"
  echo "///"
  echo "/// [View \"$icon_name\" on lucide.dev](https://lucide.dev/icons/$icon_name)"
  echo "static const IconData $(toCamelCase "$icon_name") = IconData($icon_id, fontFamily: 'LucideIcons', fontPackage: 'lucide');"
}

# remove target file
if [ -f "$target_file" ]; then
  rm "$target_file"
fi

# create target file
mkdir -p "$(dirname "$target_file")"

genClassHeader "LucideIcons" >> "$target_file"

jq -r 'to_entries[] | "\(.key) \(.value.unicode)"' $files_dir/info.json | while read -r icon_name icon_id; do
  icon_id=${icon_id//[&#;]/}
  unicode_hex=$(printf "0x%x" "$clean_unicode")

  genIconMethod "$icon_name" "$icon_id" >> "$target_file"
done

echo "}" >> "$target_file"

if command -v dart >/dev/null 2>&1; then
  dart format "$target_file"
else
  echo "Dart is not installed, skipping formatting." >&2
fi

