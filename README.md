# Live System helpers

Scripts and configs to allow creation and use of live system.

## Creation Script
Shell funtions in `mklive.sh` are used to build a live image
and create bootable USB media.

Call script without arguments to show available entrypoint options.

### Image Creation
The `create` operation takes a system root directory and an
arbitrary output directory to write a squashfs image (`filesystem.squashfs`),
additional package info and copy current kernel (`vmlinuz`) and initrd (`initrd.img`) to.

The `/boot/grub` directory and initrd images are exclude from squashfs image to save space.

Cleanup and package functions are designed for Debian/Ubuntu type systems.

Required packages:
- `squashfs-tools`: creating compressed image file
- `dpkg`: installed packages listing

### Live USB Creation
Use `install` operation to copy live data to stick and writing prepared GRUB2 boot code.

Try to hide live system directory via FAT file system flags.


## GRUB configuration
Example configuration and creation/install instructions for
boot loader can be found in `grub.cfg`.

A minimal module set (working for my system!) for `grub2` is listed in `grub_minimal.txt`.


## Casper Configuration
To add data to Live System Ramdisk the script `27livedata` searches
for archives and extracts them to a location according to their name.
This script should be copied to `/usr/share/initramfs-tools/scripts/casper-bottom`
of live system base.

It additionally creates a direectory `/remote` and adds live user to `fuse`
group for later use of `sshfs`.

When using a regular data Stick to store a live system it is useful
to wave write access to the single live media partition.
With `casper.diff` an addition to `/usr/share/initramfs-tools/scripts/casper`
can be applied before creatin an initial ramdisk to change
FAT and NTFS live volume mount options.

Required packages:
- `casper`: Ubuntu live image runtime


## Documentation Shell Interface
To access documentation via a command line Interface
`doc.py` searches config files according to environment and
displays availabel elements or their content.
