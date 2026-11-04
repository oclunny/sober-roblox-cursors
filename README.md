# Sober Roblox Cursor Changer

Customize Roblox's **normal cursor** and **hand/interact cursor** when playing through [Sober](https://sober.vinegarhq.org/) on Linux.

Created with ❤️ by **clunny**.

This tool uses Sober's **asset overlay** instead of modifying Roblox's APK.

## Features

- **One PNG for both cursors** — quickly apply a single image to the normal and interact cursors.
- **Cursor packs** — use separate PNGs for each cursor type.
- **Automatic backups** before changes.
- **Restore backups** from the script's menu.
- **Reset cursors** to Roblox defaults.
- Searches `~/Downloads` and its subfolders for PNG images.
- Checks PNG file types and keeps the original APK untouched.
- Runs without administrator privileges.

> **Supported:** Normal cursor and hand/interact cursor. **I-beam (text selection) and Shift Lock are not supported** in this release.

## Requirements

- Linux
- [Sober](https://flathub.org/apps/org.vinegarhq.Sober), installed and launched at least once
- Bash and common command-line tools (`find`, `sort`, `cp`, `mv`, `mktemp`, `file`, `date`)
- A `.png` cursor image (a transparent background is recommended)

## Installation

Open a terminal:

```bash
git clone https://github.com/oclunny/sober-roblox-cursors.git
cd sober-roblox-cursors
chmod +x cc_byclunny.sh
./cc_byclunny.sh
```

> Make sure Sober is **closed** before installing or restoring cursors.

## Menu

```text
=== CHANGE CURSOR FOR SOBER — BY CLUNNY ===

  [1] One PNG for both cursors
  [2] Install cursor pack
  [3] Restore backup
  [4] Reset cursors to Roblox defaults
  [0] Exit
```

### Option 1 — One PNG for both cursors

Place your PNG anywhere in `~/Downloads`, including subfolders. Select **1**, choose the image, and confirm. The script installs it for both the normal and hand/interact cursors.

### Option 2 — Install a cursor pack

Create a folder inside `~/Downloads` with these filenames:

| Filename | Cursor |
| --- | --- |
| `ArrowCursor.png` | Hand / Interact |
| `ArrowFarCursor.png` | Normal / Default |

Select **2** and choose the folder. The script applies the available cursor images. Missing images are left unchanged.

### Option 3 — Restore backup

Select **3** to restore a backup created by the current script. Backups preserve the previous texture overlay so you can undo changes.

### Option 4 — Reset cursors

Select **4** to remove the supported cursor overrides and let Roblox use its default cursor textures.

## How it works

Sober supports custom assets through its `asset_overlay` directory. The script writes cursor PNGs under:

```text
~/.var/app/org.vinegarhq.Sober/data/sober/asset_overlay/content/textures/
```

It does **not** modify `base.apk` or repack Roblox files. Some experiences may use their own cursor images and ignore these overrides.

## Notes

- The source PNG can be removed from `~/Downloads` after installation.
- For best results, use a transparent PNG with suitable dimensions (for example, 64×64 pixels).
- If a cursor does not update immediately, close and restart Sober.
- Older backup formats may not appear in the current script's restore menu.
- The script changes cursor textures only; it does not change Sober's graphics settings.

## Copyright and permissions

**Copyright © 2026 clunny. All rights reserved.**

This project is provided for **personal, non-commercial use**. You may download and run the script for that purpose.

Copying, modifying, redistributing, republishing, rebranding, creating derivative works, or using the script commercially requires prior written permission from clunny, except where applicable law permits otherwise.

The software is provided **“as is,” without warranty of any kind**.

Official repository: https://github.com/oclunny/sober-roblox-cursors

---

Made with ❤️ by **clunny**
