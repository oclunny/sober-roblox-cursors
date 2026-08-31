#!/usr/bin/env bash
set -euo pipefail

# Roblox Cursor Changer for Sober
# Linux / Sober (VinegarHQ)
#
# What it does:
# 1. Looks for PNG image files anywhere in ~/Downloads (including subfolders).
# 2. Lets you choose a cursor image interactively.
# 3. Backs up the existing Sober texture overlay (optional).
# 4. Extracts default cursors from base.apk.
# 5. Replaces standard mouse cursors with your chosen image.
# 6. Offers to delete this cloned repo folder once you're done.
#
# Run from a terminal, right after cloning oclunny/sober-roblox-cursors:
#    chmod +x change-cursor-byclunny.sh
#    ./change-cursor-byclunny.sh

SOBER="$HOME/.var/app/org.vinegarhq.Sober/data/sober"
OVERLAY="$SOBER/asset_overlay"
APK="$SOBER/packages/x86_64/com.roblox.client/base.apk"
DOWNLOADS="$HOME/Downloads"

# Folder this script lives in (i.e. the cloned repo), used later for the
# optional cleanup step.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Basic dependency check, with an offer to auto-install anything missing
# ---------------------------------------------------------------------------

declare -A PKG_APT=( [unzip]="unzip" [sed]="sed" )
declare -A PKG_DNF=( [unzip]="unzip" [sed]="sed" )
declare -A PKG_PACMAN=( [unzip]="unzip" [sed]="sed" )
declare -A PKG_ZYPPER=( [unzip]="unzip" [sed]="sed" )
declare -A PKG_APK=( [unzip]="unzip" [sed]="sed" )

MISSING=()
command -v unzip >/dev/null 2>&1 || MISSING+=("unzip")
command -v sed   >/dev/null 2>&1 || MISSING+=("sed")
command -v find  >/dev/null 2>&1 || MISSING+=("find")

echo "Checking required tools (unzip, sed, find)..."

if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "All required tools are already installed. Continuing..."
    echo
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "This script needs a few command-line tools that aren't installed:"
    for tool in "${MISSING[@]}"; do
        echo "  - $tool"
    done
    echo
    read -r -p "Install the missing packages now? [Y/n]: " INSTALL_DEPS

    if [[ "$INSTALL_DEPS" =~ ^[Nn]$ ]]; then
        echo
        echo "Skipping package installation. Continuing on to the cursor script..."
        echo "(If a missing tool is actually needed, a step further down will fail"
        echo " and tell you which one.)"
    else
        SUDO=""
        if [[ "$(id -u)" -ne 0 ]]; then
            if command -v sudo >/dev/null 2>&1; then
                SUDO="sudo"
            else
                echo
                echo "ERROR: Not running as root and 'sudo' isn't available,"
                echo "so packages can't be installed automatically."
                echo "Please install the tools listed above manually, then run"
                echo "this script again."
                exit 1
            fi
        fi

        if command -v apt-get >/dev/null 2>&1; then
            PKGS=(); for t in "${MISSING[@]}"; do [[ -n "${PKG_APT[$t]:-}" ]] && PKGS+=("${PKG_APT[$t]}"); done
            echo
            echo "Detected apt (Debian/Ubuntu). Running:"
            echo "  $SUDO apt-get update -y && $SUDO apt-get install -y ${PKGS[*]}"
            $SUDO apt-get update -y
            $SUDO apt-get install -y "${PKGS[@]}"
        elif command -v dnf >/dev/null 2>&1; then
            PKGS=(); for t in "${MISSING[@]}"; do [[ -n "${PKG_DNF[$t]:-}" ]] && PKGS+=("${PKG_DNF[$t]}"); done
            echo
            echo "Detected dnf (Fedora). Running:"
            echo "  $SUDO dnf install -y ${PKGS[*]}"
            $SUDO dnf install -y "${PKGS[@]}"
        elif command -v pacman >/dev/null 2>&1; then
            PKGS=(); for t in "${MISSING[@]}"; do [[ -n "${PKG_PACMAN[$t]:-}" ]] && PKGS+=("${PKG_PACMAN[$t]}"); done
            echo
            echo "Detected pacman (Arch). Running:"
            echo "  $SUDO pacman -S --noconfirm ${PKGS[*]}"
            $SUDO pacman -S --noconfirm "${PKGS[@]}"
        elif command -v zypper >/dev/null 2>&1; then
            PKGS=(); for t in "${MISSING[@]}"; do [[ -n "${PKG_ZYPPER[$t]:-}" ]] && PKGS+=("${PKG_ZYPPER[$t]}"); done
            echo
            echo "Detected zypper (openSUSE). Running:"
            echo "  $SUDO zypper install -y ${PKGS[*]}"
            $SUDO zypper install -y "${PKGS[@]}"
        elif command -v apk >/dev/null 2>&1; then
            PKGS=(); for t in "${MISSING[@]}"; do [[ -n "${PKG_APK[$t]:-}" ]] && PKGS+=("${PKG_APK[$t]}"); done
            echo
            echo "Detected apk (Alpine). Running:"
            echo "  $SUDO apk add ${PKGS[*]}"
            $SUDO apk add "${PKGS[@]}"
        else
            echo
            echo "ERROR: Couldn't detect a supported package manager"
            echo "(apt, dnf, pacman, zypper, or apk)."
            echo
            echo "Please install these manually, then run this script again:"
            printf '  %s\n' "${MISSING[@]}"
            exit 1
        fi

        STILL_MISSING=()
        command -v unzip >/dev/null 2>&1 || STILL_MISSING+=("unzip")
        command -v sed   >/dev/null 2>&1 || STILL_MISSING+=("sed")

        if [[ ${#STILL_MISSING[@]} -gt 0 ]]; then
            echo
            echo "WARNING: Still missing after install attempt:"
            printf '  - %s\n' "${STILL_MISSING[@]}"
            echo "You may need to install these by hand before continuing."
        else
            echo
            echo "All required packages are installed."
        fi
    fi
fi

if [[ ! -f "$APK" ]]; then
    echo "ERROR: Roblox base.apk was not found:"
    echo "  $APK"
    echo
    echo "Make sure Sober/Roblox has been installed and launched at least once."
    exit 1
fi

# ---------------------------------------------------------------------------
# Helper: offer to delete this cloned repo folder
# ---------------------------------------------------------------------------

offer_repo_cleanup() {
    echo
    echo "This script lives in the cloned repo folder:"
    echo "  $SCRIPT_DIR"
    echo

    read -r -p "Delete this cloned repo folder now that you're done? [y/N]: " DELETE_REPO
    if [[ "$DELETE_REPO" =~ ^[Yy]$ ]]; then
        echo
        echo "Deleting:"
        echo "  $SCRIPT_DIR"
        cd "$HOME"
        rm -rf "$SCRIPT_DIR"
        echo "Repo folder deleted. All done!"
    else
        echo "Keeping the repo folder. You can delete it manually any time,"
        echo "or re-run this script later to change cursors again."
    fi
}

echo
echo "=========================================="
echo "     Sober Roblox Cursor Changer"
echo "=========================================="
echo
echo "What would you like to do?"
echo
echo "  [1] Install/change Roblox cursor"
echo "  [2] Restore a previous cursor backup"
echo
read -r -p "Choose an option [1-2]: " ACTION

if [[ "$ACTION" == "2" ]]; then
    echo
    echo "Available backups:"
    echo

    mapfile -t BACKUPS < <(
        find "$SOBER" -maxdepth 1 -mindepth 1 -type d -name 'cursor-backup-*' -printf '%f\n' | sort -r
    )

    if [[ ${#BACKUPS[@]} -eq 0 ]]; then
        echo "No cursor backups were found."
        exit 1
    fi

    for i in "${!BACKUPS[@]}"; do
        printf "  [%d] %s\n" "$((i + 1))" "${BACKUPS[$i]}"
    done

    echo
    read -r -p "Which backup do you want to restore? Enter its number: " RESTORE_CHOICE

    if ! [[ "$RESTORE_CHOICE" =~ ^[0-9]+$ ]] ||
       (( RESTORE_CHOICE < 1 || RESTORE_CHOICE > ${#BACKUPS[@]} )); then
        echo "Invalid choice."
        exit 1
    fi

    BACKUP="$SOBER/${BACKUPS[$((RESTORE_CHOICE - 1))]}"

    if pgrep -x sober >/dev/null 2>&1; then
        echo
        echo "Sober is running. Closing it before restoring..."
        pkill -x sober || true
        sleep 2
    fi

    echo
    echo "Restoring:"
    echo "  $BACKUP"
    echo
    echo "to:"
    echo "  $OVERLAY/content/textures"

    rm -rf "$OVERLAY/content/textures"
    mkdir -p "$OVERLAY/content/textures"
    cp -a "$BACKUP/." "$OVERLAY/content/textures/"

    echo
    echo "Restore complete!"
    echo "Start Sober normally to use the restored cursors."

    offer_repo_cleanup

    echo
    echo "Created with ❤️ by clunny"
    echo
    exit 0
fi

if [[ "$ACTION" != "1" ]]; then
    echo "Invalid choice."
    exit 1
fi

echo
echo "Cursor image files (.png) can be anywhere inside:"
echo "  $DOWNLOADS"
echo "(including subfolders, e.g. $DOWNLOADS/MyCursor/)"
echo

if [[ ! -d "$DOWNLOADS" ]]; then
    echo "ERROR: Downloads folder was not found:"
    echo "  $DOWNLOADS"
    exit 1
fi

# Find usable PNG files anywhere in Downloads, including subfolders.
mapfile -d '' CURSORS < <(
    find "$DOWNLOADS" -type f -iname '*.png' -print0 | sort -z
)

if [[ ${#CURSORS[@]} -eq 0 ]]; then
    echo "No .png images were found in Downloads or its subfolders."
    echo
    echo "Put your cursor image somewhere inside ~/Downloads and run this again."
    exit 1
fi

echo "Found these images:"
echo

for i in "${!CURSORS[@]}"; do
    REL="${CURSORS[$i]#"$DOWNLOADS"/}"
    printf "  [%d] %s\n" "$((i + 1))" "$REL"
done

echo
read -r -p "Which image do you want to use as your cursor? Enter its number: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] ||
   (( CHOICE < 1 || CHOICE > ${#CURSORS[@]} )); then
    echo "Invalid choice."
    exit 1
fi

CURSOR="${CURSORS[$((CHOICE - 1))]}"
CURSOR_NAME="$(basename "$CURSOR")"

echo
echo "Selected cursor image: $CURSOR_NAME"
echo

read -r -p "Continue and replace Roblox cursors? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Close/kill Sober if it is currently running.
if pgrep -x sober >/dev/null 2>&1; then
    echo
    echo "Sober is running. Closing it before changing the files..."
    pkill -x sober || true
    sleep 2
fi

mkdir -p "$OVERLAY/content/textures/Cursors/KeyboardMouse"

# Optionally make a timestamped backup before changing anything.
echo
read -r -p "Do you want to create a backup before installing the new cursor? [Y/n]: " DO_BACKUP

if [[ ! "$DO_BACKUP" =~ ^[Nn]$ ]]; then
    BACKUP="$SOBER/cursor-backup-$(date +%Y%m%d-%H%M%S)"

    if [[ -d "$OVERLAY/content/textures" ]] && [[ -n "$(find "$OVERLAY/content/textures" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
        echo
        echo "Backing up current texture overlay to:"
        echo "  $BACKUP"
        mkdir -p "$BACKUP"
        cp -a "$OVERLAY/content/textures/." "$BACKUP/"
        echo "Backup complete."
    else
        echo
        echo "No existing texture overlay to back up. Skipping backup."
    fi
else
    echo
    echo "Backup skipped."
fi

echo
echo "Refreshing base cursor textures from base.apk..."

# Extract baseline cursor textures from APK so standard directories exist
unzip -o -q "$APK" 'assets/content/textures/Cursors/*' -d "$SOBER/extracted_temp" 2>/dev/null || true
unzip -o -q "$APK" 'assets/content/textures/*.png' -d "$SOBER/extracted_temp" 2>/dev/null || true

if [[ -d "$SOBER/extracted_temp/assets/content/textures" ]]; then
    cp -a "$SOBER/extracted_temp/assets/content/textures/." "$OVERLAY/content/textures/"
    rm -rf "$SOBER/extracted_temp"
fi

# Target cursor file paths inside Sober
TARGET_PATHS=(
    "$OVERLAY/content/textures/Cursors/KeyboardMouse/ArrowCursor.png"
    "$OVERLAY/content/textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
    "$OVERLAY/content/textures/ArrowCursor.png"
    "$OVERLAY/content/textures/ArrowFarCursor.png"
    "$OVERLAY/content/textures/MouseLockedCursor.png"
)

echo "Replacing default Roblox cursor images with $CURSOR_NAME..."
for target in "${TARGET_PATHS[@]}"; do
    mkdir -p "$(dirname "$target")"
    cp -f "$CURSOR" "$target"
done

echo
echo "Verifying..."
echo
for target in "${TARGET_PATHS[@]}"; do
    if [[ -f "$target" ]]; then
        echo "Updated: ${target#"$OVERLAY"/}"
    fi
done

echo
echo "=========================================="
echo "Done!"
echo "=========================================="
echo
echo "Cursor image: $CURSOR_NAME"
echo "Overlay: $OVERLAY"
echo
echo "Start Sober normally and test Roblox."
echo
echo "If you want to undo this change, remove the overlay and restore"
echo "the backup shown above (or re-run this script and choose option [2])."
echo
echo "IMPORTANT:"
echo "- The image file no longer needs to stay in ~/Downloads after this,"
echo "  since it has already been copied into the Sober overlay."
echo "- Some Roblox experiences can load custom scripts for mouse icons,"
echo "  so those may not follow the replacement."

offer_repo_cleanup

echo
echo "Created with ❤️ by clunny"
echo
