#!/usr/bin/env bash

readonly WALLPAPERS="$HOME/.local/share/wallpapers"


usage() {
cat << EOF
Set desktop wallpaper using swaybg:

  wallpaper { -h | --help | <wallpaper> }

If the <wallpaper> arg is not provided, then takes a random file from
'$WALLPAPERS'.

If the <wallpaper> is a file base name (with or without extension), uses the
corresponding file in the mentioned wallpapers dir.

Also you can specify a full path to the <wallpaper> file.
EOF
}


all_wallpapers() {
  find "$WALLPAPERS" -maxdepth 1 -type f
}


readonly arg="${1:-}"

[[ "$arg" == "-h" || "$arg" == "--help" ]] && usage && exit 1

killall swaybg
swaybg --version || exit 1

[[ -z "$arg" || ! -f "$arg" ]] \
&& [[ ! -d "$WALLPAPERS" || -z $(all_wallpapers) ]] \
  && echo >&2 "Wallpapers are not found in '$WALLPAPERS'!" \
  && exit 2

if [[ -z "$arg" ]]; then
  readonly image="$(all_wallpapers | sort -R | head -n 1)"
  echo "Random wallpaper: '$image'."
elif [[ ! -f "$arg" ]]; then
  readonly image="$(find "$WALLPAPERS" -name "$1" | head -n 1)"
  echo "Found wallpaper: '$image'."
else
  readonly image="$arg"
  echo "Arbitrary wallpaper: '$image'."
fi

[[ ! -f "$image" ]] && echo >&2 "Wallpaper '$image' is not found!" && exit 3

nohup swaybg --image "$image" >/dev/null 2>&1 &
