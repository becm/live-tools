# Live System helpers

Scripts and configs to allow creation and use of live system.

## Creation Script
Shell functions in `mklive.sh` are used to create a squashfs image
and prepare USB media for live system booting.

To show available operations call script without arguments.

### Image Creation
The `create` operation builds a squashfs image (`filesystem.squashfs`)
and additional package info from a system root directory.

The `/boot/grub` directory and initrd images are excluded from squashfs image to save space.
The default kernel (`vmlinuz`) and initrd (`initrd.img`) are
copied to the output directory.

Cleanup and package functions are designed for Debian/Ubuntu type systems.

Required packages:
- `squashfs-tools`: creating compressed image file
- `dpkg`: listing installed packages

### Live USB Creation
Use `install` operation to copy live data to stick and writing prepared
[GRUB2](https://www.gnu.org/software/grub/) boot code.

Try to hide live system directory via FAT file system attributes.

### Disk Image mounting
A shortcut to mount the first partition of a disk image at sector 2048 (or 512 on 4k)
is provided by the `mount` operation.

### Live Data directory update
By calling `update` on a directory containing a complete `deb`-based distribution
the script uses `chroot` to load and apply updates to the system in this directory.

A combination of `mount` and `update` can be used to avoid starting a VM instance
to apply updates to a system image but both operations require
root priviledges on host machine.

### Disk partitioning
Create a single new partition spanning the whole disk by calling
`new` on a USB flash device (WARNING: check for correct target device!)

### File system relabel
A FAT (or NTFS) file system label can be changed by the scripts `label` operation.


## VM runtime support
The alias/script file `aliases.sh` may be copied into the live system base VM image
to supply a shortcut for image creation from within a running QEMU instance.


## GRUB configuration
Example configuration and creation/install instructions for
boot loader can be found in `grub.cfg`.

A minimal module set (working for my `grub2` version!) is listed in `grub_minimal.txt`.
These files must be present on live media in the directory supplied
on `core.img` creation.


## Casper Configuration
Scripts for live system modification using `casper` must be
copied to `/usr/share/initramfs-tools/scripts/casper-bottom`
in the live system base directory.

Required packages:
- `casper`: Ubuntu live image runtime

### Insert additional data
To add data to the live system ramdisk the script `27livedata` searches
for archives and extracts them to locations according to their name.

### Change system setup
The script `27livemod` can change mount flags (`live-rw`)
and add the live user to the `fuse` group (`live-fuse`).
The second option also creates the directory `/remote` to be used by
the live system user for [fuse](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) mounts.
Both options are enabled in supplied `grub.cfg`.


## Documentation Shell Interface
To access documentation via a command line Interface
`doc.py` displays availabel elements or opens selected content.
Documentation entries are loaded from files matching `DOC_LOAD`
environment variable (e.g. `"/doc/*/*.conf:~/.mydoc/*.conf"`).

The config files are in standard [desktop](http://standards.freedesktop.org/desktop-entry-spec/latest/)
entry format, localization is taken from environment.
Only simple `CC` locale is supported.
