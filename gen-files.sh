#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
target_file="$script_dir/lib/src/icons.g.dart"
files_dir="$script_dir/.dart_tool/lucide-font"

for cmd in pup jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "'$cmd' is required but not installed." >&2
    exit 1
  fi
done

# check if files_dir exists
if [ ! -d "$files_dir" ]; then
    echo "Directory '$files_dir' does not exist. Please run 'download-lucide.sh <version>' first." >&2
    exit 1
fi

function genClassHeader() {
  local class_name="$1"
  echo "// GENERATED CODE - DO NOT MODIFY BY HAND"
  echo "import 'package:flutter/widgets.dart';"
  echo "class $class_name {"
  echo "  const $class_name._();"
}

function genIconMethod() {
  local icon_name="$1"
  local icon_id="$2"
  echo "  /// $icon_name"
  echo "static const IconData $icon_name = IconData($icon_id, fontfamily: 'LucideIcons', fontPackage: 'cliq_icons');"
}

# remove target file
if [ -f "$target_file" ]; then
  rm "$target_file"
fi

# create target file
mkdir -p "$(dirname "$target_file")"

genClassHeader "LucideIcons" >> "$target_file"

pup '.unicode-icon json{}' < $files_dir/unicode.html | jq -c '.[]' | while read -r block; do
  icon_name=$(echo "$block" | jq -r '.. | objects | select(.tag=="h4") | .text')

  icon_id=$(echo "$block" | jq -r '
    .. | objects 
    | select(.tag=="span" and (.class // "" | test("(^| )unicode( |$)"))) 
    | .text
  ')

  if [ -z "$icon_name" ] || [ -z "$icon_id" ]; then
      echo "Skipping invalid icon: $icon_name with ID: $icon_id" >&2
      continue
  fi
  icon_name=$(echo "$icon_name" | awk -F- '{
    printf "%s", $1;
    for (i=2; i<=NF; i++) {
      printf toupper(substr($i,1,1)) substr($i,2);
    }
    printf "\n"
  }')
  icon_id=${icon_id//&amp;/}
  icon_id=${icon_id//[&#;]/}
  genIconMethod "$icon_name" "$icon_id" >> "$target_file"
done

echo "}" >> "$target_file"

if command -v dart >/dev/null 2>&1; then
  dart format "$target_file"
else
  echo "Dart is not installed, skipping formatting." >&2
fi

