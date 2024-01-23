# ArchDave Installer Script

This is a completely automated installation script that installs and configures a fully functional Arch Linux installation containing a desktop environment, all the required packages (graphics drivers, network, Bluetooth, audio, printers, etc.), along with all my preferred applications and utilities I use on a daily basis.\
You are also able to choose to install Arch on a disk or partition and choose from a variety of different desktop environments, keyboard layouts, etc.


---
## Download Arch ISO

Download the Arch ISO from <https://archlinux.org/download/> and put it on a USB drive with [Etcher](https://www.balena.io/etcher/), [Rufus](https://rufus.ie/en/), or [Ventoy](https://www.ventoy.net/en/index.html)

## Boot Arch ISO

From the initial prompt, type the following commands after waiting a few seconds (as explained [here](#error-keyring-is-not-writable)):

```bash
pacman -Sy git
git clone https://github.com/d4ve10/ArchDave
cd ArchDave
./archdave.sh
```

## Configuration
If you only want to configure things like the keyboard layout or use my configurations for grub, zsh, KDE Desktop and so on, you can do so by running the following commands:\
_Note:_ You can also run most of these options on any other distribution other than Arch.

```bash
git clone https://github.com/d4ve10/ArchDave
cd ArchDave
./configure.sh
```


---
## Troubleshooting

### **error: keyring is not writable**
If you get this error when installing git:
```
downloading required keys...
error: keyring is not writable
error: required key missing from keyring
error: failed to commit transaction (unexpected error)
Errors occurred, no packages were upgraded.
```
Reboot the ISO and wait at least 15 seconds before installing git. \
When starting the Arch ISO, it will update the keyring and trust database in the background. \
You can run `journalctl -f` and wait until it says something like **next trustdb check due at 2022-05-6** and **Finished Initializes Pacman keyring**.

### **error: target not found: xxx**
If this error happens during the installation, just remove the corresponding package from the `packages/pacman.txt` file. This package probably got removed or renamed from the repository.
Feel free to create an issue or pull request if that happens.

### **Script failing constantly**
If the script fails multiple times, try to remove `install.conf` and run the script again.

### **Timezone won't get detected**
Make sure the domains `ipapi.co` and `ifconfig.co` don't get blocked by your firewall.

### **No WiFi**
You can check if WiFi is blocked by running `rfkill list`.
If it says **Soft blocked: yes**, then run `rfkill unblock wifi`

After unblocking the WiFi, you can connect to it. Go through these 5 steps:

1. Run `iwctl`

2. Run `device list`, and find your device name.

3. Run `station [device name] scan`

4. Run `station [device name] get-networks`

5. Find your network, and run `station [device name] connect [network name]`, enter your password and run `exit`. You can test if you have internet connection by running `ping google.com`


---
## Credits
- Forked from ChrisTitusTech
- Original packages script was a post install cleanup script called ArchMatic located here:\
https://github.com/rickellis/ArchMatic \
https://github.com/rickellis/Arch-Linux-Install-Guide
