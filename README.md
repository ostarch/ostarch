# This Script is in (WIP) stage
### About this Script:
- Will do some basic setups upto **Pacstrap** in simple steps, by choosing between options:
- will cover:
	- Generating Mirrorlist
	- Partition Disk:
		- btrfs, Luks encryption, SubVols, etc.
	- Mount Partitions 
	- And Pacstrap
### How to run:
- Boot into live mode:
- `pacman -Sy git`
- `git clone https://www.github.com/ostarch/ostarch`
- `cd ostarch/`
- `./ostarch.sh`