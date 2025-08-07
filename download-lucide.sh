#!/bin/bash

if [ -z "$1" ]
  then
    echo "Usage: download-lucide.sh <version>" >&2
    exit 1
fi

lucide_version=$1
archive_url=$"https://github.com/lucide-icons/lucide/releases/download/$lucide_version/lucide-font-$lucide_version.zip"
script_dir=$(dirname "$(readlink -f "$0")")
target_dir="$script_dir/.dart_tool"
assets_dir="$script_dir/assets"

if ! curl --output /dev/null --silent --head --fail "$archive_url"; then
  echo "Could not download archive from: $archive_url" >&2
  exit 1
fi

function checkIfDirIsEmpty() {
  local target_dir="$1"

  if [ -z "$target_dir" ]; then
    echo "No target directory provided." >&2
    return 1
  fi

  mkdir -p "$target_dir"
  if [ $? -ne 0 ]; then
    echo "Failed to create target directory: $target_dir" >&2
    return 1
  fi

  if [ -d "$target_dir" ] && [ "$(ls -A "$target_dir")" ]; then
    echo "'$target_dir' is not empty. Existing files will be deleted."
    read -p "Are you sure you want to continue? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Aborting." >&2
      return 1
    fi

    rm -rf "$target_dir"/*
    if [ $? -ne 0 ]; then
      echo "Failed to clear target directory: $target_dir" >&2
      return 1
    fi
  fi
}

checkIfDirIsEmpty "$target_dir/lucide-font"

echo "Downloading archive from $archive_url"
curl -L "$archive_url" --silent --fail --show-error | bsdtar -xf - -C "$target_dir"

if [ $? -ne 0 ]; then
  echo "Failed to download or extract archive." >&2
  exit 1
fi

checkIfDirIsEmpty "$assets_dir"
cp -r "$target_dir/lucide-font/"*.ttf "$assets_dir"
