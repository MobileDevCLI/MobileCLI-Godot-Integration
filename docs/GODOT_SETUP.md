# Godot Engine CLI Setup for MobileCLI

## Overview

MobileCLI can run Godot Engine headlessly via proot-distro + Arch Linux ARM. This enables AI-powered game development directly on your Android phone.

## Automatic Installation

Tap **Godot CLI** in the MobileCLI navigation drawer, or run:

```bash
install-godot
```

This installs:
1. **proot-distro** - Linux distribution manager for Termux
2. **Arch Linux ARM** - Full Arch Linux environment (~200MB)
3. **Godot Engine** - Game engine from Arch's official repos
4. **godot4 wrapper** - Convenience command in Termux PATH

## Manual Installation

If you prefer to install manually:

```bash
# Install proot-distro
pkg install -y proot-distro

# Install Arch Linux ARM
proot-distro install archlinux

# Update Arch and install Godot
proot-distro login archlinux -- bash -c 'pacman -Syu --noconfirm && pacman -S --noconfirm godot'

# Create wrapper command
cat > $PREFIX/bin/godot4 << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login archlinux -- godot "$@"
EOF
chmod +x $PREFIX/bin/godot4
```

## Usage

### From Termux (via wrapper)

```bash
# Check version
godot4 --version

# Run a GDScript file
godot4 --no-window --script test.gd

# Validate a project
godot4 --no-window --path ~/my-game --quit

# Export a project (requires export presets)
godot4 --no-window --path ~/my-game --export-debug "Android" output.apk
```

### From inside Arch Linux

```bash
# Enter Arch environment
proot-distro login archlinux

# Then use godot directly
godot --version
godot --no-window --script test.gd
```

## What Claude Can Do with Godot

With Godot CLI installed, Claude can:

- **Create game projects** - Generate project.godot, scenes (.tscn), and scripts (.gd)
- **Validate projects** - Run `godot4 --no-window --path <project> --quit` to check for errors
- **Run GDScript** - Execute standalone scripts for testing game logic
- **Generate assets** - Create placeholder textures, 3D models (via scripts), and audio
- **Export builds** - Package games for Android, Linux, and other platforms

## Example Project

See `godot-projects/cod-building/` for a complete example project - a CoD-style building demo with:
- Procedural building generation
- FPS controller
- Weapon system
- HUD overlay

## Architecture

```
Termux (ARM64 Android)
  └── proot-distro
       └── Arch Linux ARM
            └── Godot Engine (headless)
                 └── Your game projects
```

The `godot4` wrapper transparently routes commands through proot-distro into the Arch Linux environment, making Godot feel like a native Termux command.

## Troubleshooting

### "Arch Linux already installed"
This is normal if you've run the installer before. The existing installation is preserved.

### Godot fails to start
Make sure Arch is up to date:
```bash
proot-distro login archlinux -- pacman -Syu --noconfirm
```

### Out of storage
Arch Linux + Godot requires ~500MB. Check available space:
```bash
df -h ~
```

### Permission errors
Ensure the wrapper script is executable:
```bash
chmod +x $PREFIX/bin/godot4
```
