#!/bin/sh
echo -ne '\033c\033]0;GodotAutoBattler\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/autobattler.x86_64" "$@"
