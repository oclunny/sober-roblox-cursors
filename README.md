# Sober Roblox Cursor Override

Replace Roblox's in-game cursor with a custom `.png` image when using [Sober](https://sober.vinegarhq.org/) on Linux.

This works by creating an asset overlay instead of modifying the Roblox APK directly.

## Features

- Replace default Roblox mouse cursors and shift-lock icons with your own custom image
- Works with `.png` files (including custom crosshairs)
- Finds cursor images anywhere in `~/Downloads`, including subfolders
- Replaces primary and fallback mouse cursor texture paths
- Offers to back up your current textures before changing anything, and to restore that backup later
- Checks for required tools on first run and offers to install anything missing for you
- Easy to change to another cursor later
- No APK repacking required

## Requirements

- Linux
- [Sober](https://flathub.org/en/apps/org.vinegarhq.Sober/), installed and launched at least once
- `unzip`
- `sed`
- A `.png` image to use as your cursor (recommended size: `64x64` or `32x32` with a transparent background)

```I will also leave a + cursor made by me in the repository.```

You don't need to install these yourself—see [Dependency Check](#dependency-check) below. `find` is also used, but it's a core system tool that's virtually always already present.

> **Important:** Make sure your cursor image is saved as a transparent PNG. By default, Roblox uses the top-left corner (`0, 0`) of the image as the click hotspot.

## How It Works

Roblox stores its cursor textures inside the APK under:

```text
assets/content/textures/Cursors/
assets/content/textures/
```
Rather than editing the APK itself, this script:

1. Extracts baseline cursor textures from `base.apk` into Sober's asset overlay folder to build the original directory structure.
2. Copies your chosen `.png` image into the overlay across standard active mouse and shift-lock cursor paths (such as `ArrowCursor.png`, `ArrowFarCursor.png`, and `MouseLockedCursor.png`).
3. Because Sober reads the asset overlay on top of the real APK, none of this touches the original Roblox files it can be undone at any time by clearing the overlay or restoring a backup.

### Usage

Clone the repo and run the script:

```Bash
git clone [https://github.com/oclunny/sober-roblox-cursors.git](https://github.com/oclunny/sober-roblox-cursors.git)
cd sober-roblox-cursors
chmod +x change-cursor-byclunny.sh
./change-cursor-byclunny.sh
```

### Dependency Check

On startup, the script checks for unzip, sed, and find. If everything's already installed, it just confirms that and moves on. If anything's missing, it will:

- List what's missing
- Ask **"Install the missing packages now? [Y/n]"**
- If you say yes, it detects your package manager (`apt`, `dnf`, `pacman`, `zypper`, or `apk`) and installs the right packages for your distro, using sudo if needed
- If you say no, it skips installation and continues straight on to the cursor changing steps (a later step may fail and tell you which tool it needed)

### Choosing a Cursor
Put your `.png` file anywhere inside `~/Downloads` including subfolders then run the script and choose option `[1]`. It will list every `.png` image it finds, with its path relative to `~/Downloads`. Pick a number, confirm, and it does the rest.

You'll be asked if you want to back up your current cursor textures first—recommended, especially the first time.

### Restoring a Backup

Run the script again and choose option `[2]` to see a list of previous backups (newest first) and restore one.

### Cleaning Up

Once you're done, the script offers to delete the cloned repo folder for you, since it's no longer needed after the cursor has been installed. This is optional—say no to keep it around in case you want to change cursors again later.

### Notes
- Some Roblox experiences load custom scripts or GUI elements for mouse icons, so those may not follow the replacement.
- The image file doesn't need to stay in `~/Downloads` after installation it's already been copied into the Sober overlay by that point.

---

Created with ❤️ by clunny
