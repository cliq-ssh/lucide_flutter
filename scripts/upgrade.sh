#!/bin/bash

if [ -z "$1" ]
  then
    echo "Usage: upgrade.sh <version>" >&2
    exit 1
fi

lucide_version=$1
script_dir=$(dirname "$(readlink -f "$0")")

"$script_dir/download.sh" "$lucide_version"
"$script_dir/generate.sh"

if [ $? -ne 0 ]; then
  echo "Upgrade process failed." >&2
  exit 1
fi

echo "Upgrade to version $lucide_version completed successfully."