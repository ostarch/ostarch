
# ostarch Installer Script
# 😊) Key Features
- Completely Automated Installation Script.
- Simplified Partitioning.
- Installs and Configures a Fully Functional Arch Linux.
- Options to Install Desktop Environment.
- Necessary Packages Pre-Installed (graphics drivers, network, Bluetooth, audio, printers, etc.)
- Simple to Modify for Personal Requirements.

# 1) Download Arch ISO
## (A) Make USB Ready
- Download the Arch ISO from <https://archlinux.org/download/>
- Put it on a USB drive with [Etcher](https://www.balena.io/etcher/), [Rufus](https://rufus.ie/en/), or [Ventoy](https://www.ventoy.net/en/index.html)

## (B) Boot Into Arch ISO
From the initial prompt, type the following commands after waiting a few seconds (as explained in 3(A) below:

```bash
pacman -Sy git
git clone https://github.com/ostarch/ostarch
cd ostarch
./ostarch.sh
```


# 2) Configuration
- If you only want to configure things like the keyboard layout or use ArchDave's configurations for grub, zsh, KDE Desktop and so on, you can do so by running the following commands:
- Note: You can also run most of these options on any other distribution other than Arch.
```bash
git clone https://github.com/d4ve10/ArchDave
cd ArchDave
./configure.sh
```

# 3) Troubleshooting

## (A) **error: keyring is not writable**
- If you get this error when installing git:
```
downloading required keys...
error: keyring is not writable
error: required key missing from keyring
error: failed to commit transaction (unexpected error)
Errors occurred, no packages were upgraded.
```
- Reboot the ISO and wait at least **15 seconds** before installing git.
- When starting the Arch ISO, it will update the keyring and trust database in the background.
- You can run `journalctl -f` and wait until it says something like **next trustdb check due at YYYY-MM-DD** and **Finished Initializes Pacman keyring**.

## (B) **error: target not found: xxx**
- If this error happens during the installation, just remove the corresponding package from the `packages/pacman.txt` file. This package probably got removed or renamed from the repository.
- Feel free to create an issue or pull request if that happens.

## (C) **Script failing constantly**
- If the script fails multiple times, try to remove `install.conf` and run the script again.

## (D) **Timezone won't get detected**
- Make sure the domains `ipapi.co` and `ifconfig.co` don't get blocked by your firewall.

## (E) **No WiFi**
- You can check if WiFi is blocked by running `rfkill list`
- If it says **Soft blocked: yes**, then run `rfkill unblock wifi`
- After unblocking the WiFi, you can connect to it. Go through these steps:
	- Run `iwctl`
	- Run `device list`, and find your device name.
	- Run `station [device name] scan`
	- Run `station [device name] get-networks`
	- Find your network and
	- Run `station [device name] connect [network name]`
	- Enter your password and
	- Run `exit`
	- Run `ping -c 3 google.com` to Check you are connected to Internet.

# 4) Credits
- Forked from [ArchDave](https://github.com/d4ve10/ArchDave)
- Which itself is a fork of [ArchTitus](https://github.com/ChrisTitusTech/ArchTitus)

