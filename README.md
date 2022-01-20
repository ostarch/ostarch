# ArchDave Installer Script

This README contains the steps I do to install and configure a fully-functional Arch Linux installation containing a desktop environment, all the support packages (network, bluetooth, audio, printers, etc.), along with all my preferred applications and utilities. The shell scripts in this repo allow the entire process to be automated.)

---
## Download Arch ISO

Download ArchISO from <https://archlinux.org/download/> and put on a USB drive with [Etcher](https://www.balena.io/etcher/), [Ventoy](https://www.ventoy.net/en/index.html), or [Rufus](https://rufus.ie/en/)

## Boot Arch ISO

From initial Prompt type the following commands:

```bash
pacman -Sy git
git clone https://github.com/d4ve10/ArchDave
cd ArchDave
./archdave.sh
```

## After The First Boot

Unfortunately after the first boot, the timezone resets and the KDE theme isn't loaded properly.
To fix this, just run the following commands after you logged in to KDE.

```bash
cd ~/ArchDave
./4-post-startup.sh
```

### System Description
This is completely automated arch install of the KDE desktop environment on arch using all the packages I use on a daily basis. 

## Troubleshooting

__[Arch Linux Installation Guide](https://github.com/rickellis/Arch-Linux-Install-Guide)__

### No Wifi

You can check if the WiFi is blocked by running `rfkill list`.
If it says **Soft blocked: yes**, then run `rfkill unblock wifi`

After unblocking the WiFi, you can connect to it. Go through these 5 steps:

1. Run `iwctl`

2. Run `device list`, and find your device name.

3. Run `station [device name] scan`

4. Run `station [device name] get-networks`

5. Find your network, and run `station [device name] connect [network name]`, enter your password and run `exit`. You can test if you have internet connection by running `ping google.com`. 

## Credits
- Forked from ChrisTitusTech
- Original packages script was a post install cleanup script called ArchMatic located here: https://github.com/rickellis/ArchMatic
