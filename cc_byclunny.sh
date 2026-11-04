#!/usr/bin/env bash

# ============================================================
#              CHANGE CURSOR FOR SOBER — BY CLUNNY
# ============================================================
#
# Copyright (c) 2026 clunny. All rights reserved.
#
# Created and developed by clunny.
# GitHub: https://github.com/oclunny/sober-roblox-cursors
#
# This script is proprietary software.
#
# Permission is granted to download and run this script for
# personal, non-commercial use only.
#
# WITHOUT PRIOR WRITTEN PERMISSION FROM THE AUTHOR, YOU MAY NOT:
#
# - Copy or redistribute this script.
# - Modify, remix, or create derivative works.
# - Reupload or republish this script elsewhere.
# - Claim ownership or authorship of this project.
# - Remove or alter copyright and attribution notices.
# - Sell or commercially exploit this script.
#
# All rights not expressly granted are reserved by the author.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
#
# ============================================================

set -euo pipefail

# Change Cursor for Sober — by clunny

# Only the three arrow/hand texture paths verified on Sober are modified.
# No root privileges or APK modifications required.
SOBER="${SOBER_DIR:-$HOME/.var/app/org.vinegarhq.Sober/data/sober}"
OVERLAY="$SOBER/asset_overlay/content/textures"
DOWNLOADS="${CURSOR_DOWNLOADS:-$HOME/Downloads}"
BACKUPS="$SOBER/cursor-changer-backups"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C=$'\033[1;35m'; G=$'\033[1;32m'; Y=$'\033[1;33m'; R=$'\033[1;31m'; Z=$'\033[0m'
else C=''; G=''; Y=''; R=''; Z=''; fi
info() { printf '%s[i]%s %s\n' "$C" "$Z" "$*"; }
ok() { printf '%s[+]%s %s\n' "$G" "$Z" "$*"; }
warn() { printf '%s[!]%s %s\n' "$Y" "$Z" "$*"; }
die() { printf '%s[x]%s %s\n' "$R" "$Z" "$*" >&2; exit 1; }
header() { printf '\n%s=== %s ===%s\n' "$C" "$1" "$Z"; }
ask() {
  local answer
  while true; do
    read -r -p "$1 [y/n]: " answer || return 1
    case "$answer" in y|Y|yes|YES) return 0;; n|N|no|NO) return 1;; *) warn 'Answer y or n.';; esac
  done
}
choose() {
  local answer
  while true; do
    read -r -p "$1 [0-$2]: " answer || return 1
    if [[ "$answer" =~ ^[0-9]+$ ]] && (( ${#answer} <= 6 )) && (( 10#$answer <= $2 )); then
      REPLY=$((10#$answer)); return 0
    fi
    warn "Choose a number between 0 and $2."
  done
}
targets=(
  'ArrowCursor.png'
  'Cursors/KeyboardMouse/ArrowCursor.png'
  'Cursors/KeyboardMouse/ArrowFarCursor.png'
)
# Root ArrowCursor and KeyboardMouse/ArrowFarCursor: normal cursor.
# KeyboardMouse/ArrowCursor: hand / interact cursor.
require_tools() {
  local missing=() cmd
  for cmd in find sort cp mv mktemp file date; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  ((${#missing[@]} == 0)) || die "Missing commands: ${missing[*]}"
  [[ -d "$SOBER" ]] || die "Sober data not found: $SOBER. Launch Sober once first."
}
ensure_stopped() {
  if command -v pgrep >/dev/null 2>&1 && pgrep -x sober >/dev/null 2>&1; then
    die 'Close Sober completely, then try again. No changes were made.'
  fi
}
valid_png() {
  [[ -f "$1" && -r "$1" ]] || return 1
  # Check actual PNG signature; file extension alone is not enough.
  [[ "$(LC_ALL=C file -b --mime-type -- "$1")" == 'image/png' ]]
}
snapshot() {
  mkdir -p "$BACKUPS"
  local dest
  dest="$(mktemp -d "$BACKUPS/backup-$(date +%Y%m%d-%H%M%S)-XXXXXXXX")"
  # Full texture-overlay snapshot preserves unrelated custom assets on restore.
  if [[ -d "$OVERLAY" ]]; then
    mkdir "$dest/textures"
    if ! cp -a "$OVERLAY/." "$dest/textures/"; then
      rm -rf -- "$dest"; die 'Backup failed; nothing changed.'
    fi
  else
    : > "$dest/overlay-was-absent"
  fi
  ok "Backup created: $dest"
}
apply_changes() {
  # $1-$3: file to install at each known target; empty means restore default.
  ensure_stopped
  local stage old i src
  mkdir -p "$(dirname "$OVERLAY")"
  stage="$(mktemp -d "$SOBER/.cursor-stage-XXXXXXXX")"
  if [[ -d "$OVERLAY" ]]; then
    if ! cp -a "$OVERLAY/." "$stage/"; then
      rm -rf -- "$stage"; die 'Unable to stage existing overlay.'
    fi
  fi
  for i in 0 1 2; do
    case "$i" in 0) src="$1";; 1) src="$2";; 2) src="$3";; esac
    if [[ -n "$src" ]]; then
      mkdir -p "$stage/$(dirname "${targets[i]}")"
      if ! cp -- "$src" "$stage/${targets[i]}"; then
        rm -rf -- "$stage"; die 'Could not stage cursor PNG.'
      fi
    else
      rm -f -- "$stage/${targets[i]}"
    fi
  done
  snapshot
  old="$(mktemp -d "$SOBER/.cursor-old-XXXXXXXX")"
  if [[ -d "$OVERLAY" ]]; then
    if ! mv -- "$OVERLAY" "$old/textures"; then
      rm -rf -- "$stage" "$old"; die 'Unable to move existing overlay.'
    fi
  fi
  if ! mv -- "$stage" "$OVERLAY"; then
    [[ ! -d "$old/textures" ]] || mv -- "$old/textures" "$OVERLAY"
    rm -rf -- "$stage" "$old"
    die 'Install failed; previous overlay restored if possible.'
  fi
  rm -rf -- "$old"
  ok 'Applied successfully. Restart Sober to see the result.'
}
select_png() {
  local files=() i choice
  [[ -d "$DOWNLOADS" ]] || { warn "Downloads directory not found: $DOWNLOADS"; return; }
  mapfile -d '' -t files < <(find "$DOWNLOADS" -type f -iname '*.png' -print0 | sort -z)
  ((${#files[@]})) || { warn 'No PNGs found in Downloads.'; return; }
  header 'ONE PNG — BOTH CURSORS'
  for i in "${!files[@]}"; do printf '  [%d] %s\n' "$((i+1))" "${files[i]#"$DOWNLOADS"/}"; done
  printf '  [0] Back\n'
  choose 'Select PNG' "${#files[@]}" || return
  choice="$REPLY"; ((choice)) || return
  local src="${files[choice-1]}"
  valid_png "$src" || { warn 'This is not a readable PNG.'; return; }
  ask "Install $(basename "$src") for normal and interact cursors?" || return
  apply_changes "$src" "$src" "$src"
}
select_pack() {
  local folders=() i choice folder
  [[ -d "$DOWNLOADS" ]] || { warn "Downloads directory not found: $DOWNLOADS"; return; }
  mapfile -d '' -t folders < <(find "$DOWNLOADS" -type d -print0 | sort -z)
  header 'CURSOR PACK'
  info 'ArrowCursor.png    — Hand / Interact'
  info 'ArrowFarCursor.png — Normal Cursor'
  info 'Missing images keep the current cursor (no silent resets).'
  for i in "${!folders[@]}"; do printf '  [%d] %s\n' "$((i+1))" "${folders[i]#"$DOWNLOADS"/}"; done
  printf '  [0] Back\n'
  choose 'Select pack folder' "${#folders[@]}" || return
  choice="$REPLY"; ((choice)) || return
  folder="${folders[choice-1]}"
  local sources=("" "" "")
  local count=0 hand="$folder/ArrowCursor.png" normal="$folder/ArrowFarCursor.png"
  if [[ -f "$hand" ]]; then
    valid_png "$hand" || { warn 'Invalid PNG: ArrowCursor.png'; return; }
    sources[1]="$hand"
    info 'Found: ArrowCursor.png (Hand / Interact)'
    ((count+=1))
  else
    info 'Missing: ArrowCursor.png (keep current)'
  fi
  if [[ -f "$normal" ]]; then
    valid_png "$normal" || { warn 'Invalid PNG: ArrowFarCursor.png'; return; }
    sources[0]="$normal"
    sources[2]="$normal"
    info 'Found: ArrowFarCursor.png (Normal Cursor)'
    ((count+=1))
  else
    info 'Missing: ArrowFarCursor.png (keep current)'
  fi
  ((count)) || { warn 'No recognized PNGs in that folder.'; return; }
  # Keep existing overrides for unspecified slots, without needing temporary copies.
  local temp
  temp="$(mktemp -d "$SOBER/.cursor-input-XXXXXXXX")"
  for i in 0 1 2; do
    if [[ -z "${sources[i]}" && -f "$OVERLAY/${targets[i]}" ]]; then
      cp -- "$OVERLAY/${targets[i]}" "$temp/$i.png"
      sources[i]="$temp/$i.png"
    fi
  done
  if ask 'Install this pack? An automatic backup will be created'; then
    apply_changes "${sources[0]}" "${sources[1]}" "${sources[2]}"
  fi
  rm -rf -- "$temp"
}
restore() {
  local dirs=() i choice src stage old
  [[ -d "$BACKUPS" ]] || { warn 'No v2.2 backups found.'; return; }
  mapfile -d '' -t dirs < <(find "$BACKUPS" -mindepth 1 -maxdepth 1 -type d -name 'backup-*' -print0 | sort -zr)
  ((${#dirs[@]})) || { warn 'No v2.2 backups found.'; return; }
  header 'RESTORE BACKUP'
  for i in "${!dirs[@]}"; do printf '  [%d] %s\n' "$((i+1))" "${dirs[i]##*/}"; done
  printf '  [0] Back\n'
  choose 'Select backup' "${#dirs[@]}" || return
  choice="$REPLY"; ((choice)) || return
  src="${dirs[choice-1]}"
  ask "Restore ${src##*/}? This replaces the current texture overlay" || return
  ensure_stopped
  stage="$(mktemp -d "$SOBER/.cursor-restore-XXXXXXXX")"
  if [[ -d "$src/textures" ]]; then
    if ! cp -a "$src/textures/." "$stage/"; then
      rm -rf -- "$stage"; die 'Could not stage backup.'
    fi
  elif [[ ! -f "$src/overlay-was-absent" ]]; then
    rm -rf -- "$stage"; die 'Backup is incomplete.'
  fi
  snapshot
  old="$(mktemp -d "$SOBER/.cursor-old-XXXXXXXX")"
  if [[ -d "$OVERLAY" ]]; then
    mv -- "$OVERLAY" "$old/textures" || die 'Cannot move current overlay.'
  fi
  if [[ -d "$src/textures" ]]; then
    if ! mv -- "$stage" "$OVERLAY"; then
      [[ ! -d "$old/textures" ]] || mv -- "$old/textures" "$OVERLAY"
      die 'Restore failed.'
    fi
  else
    rm -rf -- "$stage"
  fi
  rm -rf -- "$old"
  ok 'Backup restored. Restart Sober.'
}
reset_cursors() {
  ask 'Restore normal and interact cursors to Roblox defaults?' || return
  apply_changes '' '' ''
}
main() {
  require_tools
  while true; do
    header 'CHANGE CURSOR FOR SOBER — BY CLUNNY'
    printf '  [1] One PNG for both cursors\n'
    printf '  [2] Install cursor pack\n'
    printf '  [3] Restore backup\n'
    printf '  [4] Reset cursors to Roblox defaults\n'
    printf '  [0] Exit\n'
    choose 'Your choice' 4 || exit 0
    case "$REPLY" in
      0) exit 0;;
      1) select_png;;
      2) select_pack;;
      3) restore;;
      4) reset_cursors;;
    esac
  done
}
main "$@"
# ============================================================
# CHANGE CURSOR FOR SOBER — BY CLUNNY
#
# Copyright (c) 2026 clunny. All rights reserved.
#
# Unauthorized copying, modification, redistribution,
# republication, or commercial use is prohibited without
# prior written permission from the author.
#
# Official repository:
# https://github.com/oclunny/sober-roblox-cursors
# ============================================================