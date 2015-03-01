# Live System helpers

Scripts and configs to allow creation and use of live system.

## Creation Script
Shell functions in `mklive.sh` are used to create a squashfs image
and prepare USB media for live system booting.

To show available operations call script without arguments.

### Image Creation
The `create` operation takes a system root directory and an
arbitrary output directory to write a squashfs image (`filesystem.squashfs`),
additional package info to.

The `/boot/grub` directory and initrd images are exclude from squashfs image to save space.
The default kernel (`vmlinuz`) and initrd (`initrd.img`) are
copied to the output directory.

Cleanup and package functions are designed for Debian/Ubuntu type systems.

Required packages:
- `squashfs-tools`: creating compressed image file
- `dpkg`: installed packages listing

### Live USB Creation
Use `install` operation to copy live data to stick and writing prepared
[GRUB2](https://www.gnu.org/software/grub/) boot code.

Try to hide live system directory via FAT file system flags.

### Disk Image mounting
A shortcut to mount the first partition of a disk image at sector 2048
is provided by the `mount` operation.

### Live Data directory update
By calling `update` on a directory containing a complete `deb`-based distribution
the script uses `chroot` to load and apply updates to the system in this directory.

The combination of `mount` and `update` can be used to avoid starting a VM instance
to apply updates to a system image.

### USB repartitioning
Create a single new partition spanning the whole disk by calling
`new` on a USB flash device (WARNING: check for correct target device!)

### Partition relabel
A disk label can be changed by the scripts `label` operation.


## GRUB configuration
Example configuration and creation/install instructions for
boot loader can be found in `grub.cfg`.

A minimal module set (working for my `grub2` version!) is listed in `grub_minimal.txt`.
These files must be present on live media in the directory supplied
on `core.img` creation.


## Casper Configuration
To add data to Live System ram disk the script `27livedata` searches
for archives and extracts them to a location according to their name.
This script should be copied to `/usr/share/initramfs-tools/scripts/casper-bottom`
in the live system base directory.

It additionally creates a directory `/remote` and
adds the live user to the `fuse` group.

When using a regular USB flash drive to store a live system it is useful
to have write access to its single data partition.
`casper.diff` changes mount options in `/usr/share/initramfs-tools/scripts/casper`
if live media is a FAT or NTFS partitions.
Patch must be applied before creating the initial ram disk.

Required packages:
- `casper`: Ubuntu live image runtime


## Documentation Shell Interface
To access documentation via a command line Interface
`doc.py` displays availabel elements or opens selected content.
The environment valiable `DOC_LOAD` must be set to a path style glob pattern
to match config files to load (e.g. "/doc/*/*.conf:~/.mydoc/*.conf").

The config files are in standard [desktop](http://standards.freedesktop.org/desktop-entry-spec/latest/)
entry format, localization is taken from environmen.
Only simple `CC` locale is supported.
