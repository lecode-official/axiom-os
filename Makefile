
# The current version number of Axiom (semantic versioning)
VERSION          = 0.0.1-Pre-Alpha-1

# The assembler that we are using
ASSEMBLER        = /usr/bin/nasm

# The folder that will contain the build result
BUILDDIRECTORY   = Build

# The name of a loop device that is free (this is needed to create the disk image)
FREELOOPDEVICE   = $(shell losetup -f)

# The source files for the boot sector
BOOTSECTORSOURCE = Source/BootSector/*.asm

# Declares which of the targets are phony (targets that do not actually create a file and are thus build everytime)
.PHONY: Axiom-$(VERSION).img BuildDirectory Clean

# The default target, that builds Axiom completely
All: Axiom-$(VERSION).img

# The target that creates 
Axiom-$(VERSION).img: BootSector.bin

	# Creates a new disk image by reading 1 MiB from /dev/null (which just outputs zeros) and writing it to a file
	dd if=/dev/zero of=$(BUILDDIRECTORY)/Axiom-$(VERSION).img bs=1024 count=1024

	# Creates a loop device for the disk image
	losetup $(FREELOOPDEVICE) $(BUILDDIRECTORY)/Axiom-$(VERSION).img

	# Creates an FAT12 file system on the disk image
	mkdosfs -F 12 $(FREELOOPDEVICE)

	# Copies our custom boot sector to the disk image by first copying the FAT12 headers to the bootloader and then copying the
	# bootloader to the the disk image
	dd if=$(FREELOOPDEVICE) of=$(BUILDDIRECTORY)/BootSector.bin count=62 iflag=count_bytes conv=notrunc
	dd if=$(BUILDDIRECTORY)/BootSector.bin of=$(FREELOOPDEVICE) count=512 iflag=count_bytes conv=notrunc
	
	# Mounts the disk image, so that all the other files can be copied onto it
	mount -t msdos $(FREELOOPDEVICE) /mnt

	# Unmounts the disk image and removes the loop device, after all files have been copied to it
	umount /mnt
	losetup -d $(FREELOOPDEVICE)

	# Changes the permissions of the image file, so that the user does not need to be root in order to boot the image
	chmod 777 $(BUILDDIRECTORY)/Axiom-$(VERSION).img

# The target that assembles the boot sector
BootSector.bin: BuildDirectory $(BOOTSECTORSOURCE)

	$(ASSEMBLER) Source/BootSector/BootSector.asm -f bin -o $(BUILDDIRECTORY)/BootSector.bin

# The target that creates the folder where the result of the build is stored
BuildDirectory:

	mkdir -p $(BUILDDIRECTORY)

# The target that cleans up the environment by deleting all files generated by the build
Clean:

	rm -rf $(BUILDDIRECTORY)