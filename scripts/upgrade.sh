#!/bin/bash

if [ -z "$1" ]
  then
    echo "Usage: upgrade.sh <version>" >&2
    exit 1
fi

lucide_version=$1
script_dir=$(dirname "$(readlink -f "$0")")
changelog_file="$script_dir/../CHANGELOG.md"

"$script_dir/download.sh" "$lucide_version"
"$script_dir/generate.sh"

# prepend changelog entry
{
  echo "## $lucide_version"
  echo "- Upgraded Lucide icons to version $lucide_version (see full changelog at https://github.com/lucide-icons/lucide/releases/tag/$lucide_version)"
  echo ""
  cat "$changelog_file"
} > "$changelog_file.tmp" && mv "$changelog_file.tmp" "$changelog_file"

# set version in pubspec.yaml
sed -i -E "s/^version: .*/version: $lucide_version/" "$script_dir/../pubspec.yaml"

# set version in README.md
sed -i -E "s/v[0-9]+\.[0-9]+\.[0-9]+/v${lucide_version}/g" "$script_dir/../README.md"


if [ $? -ne 0 ]; then
  echo "Upgrade process failed." >&2
  exit 1
fi

echo "Upgrade to version $lucide_version completed successfully."