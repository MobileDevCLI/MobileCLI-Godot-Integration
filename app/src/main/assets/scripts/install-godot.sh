#!/data/data/com.termux/files/usr/bin/bash
echo "=== Godot CLI Installer for MobileCLI ==="
echo ""
echo "Step 1: Installing proot-distro..."
pkg install -y proot-distro

echo ""
echo "Step 2: Installing Arch Linux ARM..."
proot-distro install archlinux 2>/dev/null || echo "Arch Linux already installed"

echo ""
echo "Step 3: Updating Arch and installing Godot..."
proot-distro login archlinux -- bash -c 'pacman -Syu --noconfirm && pacman -S --noconfirm godot'

echo ""
echo "Step 4: Creating godot wrapper command..."
cat > $PREFIX/bin/godot4 << 'WRAPPER'
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login archlinux -- godot "$@"
WRAPPER
chmod +x $PREFIX/bin/godot4

echo ""
echo "=== Godot CLI Installed! ==="
echo ""
echo "Usage:"
echo "  godot4 --version              # Check version"
echo "  godot4 --no-window --script test.gd  # Run a script"
echo "  godot4 --no-window --path ~/my-game --quit  # Validate project"
echo "  proot-distro login archlinux   # Enter full Arch environment"
echo ""
echo "The 'godot4' command wraps Godot inside Arch Linux ARM."
echo "Claude can now create and validate Godot projects!"
