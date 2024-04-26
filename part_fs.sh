#!/bin/sh

PART_FS_FAT16=fat16
PART_FS_FAT32=fat32
PART_FS_EXFAT=exfat # resize not supported
PART_FS_EXT2=ext2
PART_FS_EXT3=ext3
PART_FS_EXT4=ext4
PART_FS_BTRFS=btrfs
PART_FS_NTFS=ntfs

#partprobe DRIVE
#e2fsck -fy DRIVE_PART
#parted DRIVE resizepart DRIVE_PART_INDEX 100%
#partprobe DRIVE
#resize2fs -f

function PART_FS_expand(){
	partprobe "$1"
	part_fs_expand=$(parted -m "$1" unit s print | tail -n 1)
	part_fs_expand_num=$(echo "$part_fs_expand" | cut -f 1 -d : | grep -oE [0-9]+)
	echo yes | parted "$1" ---pretend-input-tty resizepart $part_fs_expand_num 100%
	partprobe "$1"
	part_fs_expand_size=$(echo "$part_fs_expand" | cut -f 4 -d : | grep -oE [0-9]+)
	part_fs_expand_type=$(echo "$part_fs_expand" | cut -f 5 -d :)
	part_fs_expand_target="${1}p$part_fs_expand_num"
	if [ "$part_fs_expand_type" = "$PART_FS_FAT16" ] || [ "$part_fs_expand_type" = "$PART_FS_FAT32" ]; then
		fatresize -s "$part_fs_expand_size" "$part_fs_expand_target"
	elif [ "$part_fs_expand_type" = "$PART_FS_EXT2" ] || [ "$part_fs_expand_type" = "$PART_FS_EXT3" ] || [ "$part_fs_expand_type" = "$PART_FS_EXT4" ]; then
		e2fsck -fp "$part_fs_expand_target"
		resize2fs "$part_fs_expand_target"
	elif [ "$part_fs_expand_type" = "$PART_FS_BTRFS" ]; then
		part_fs_expand_tmp=$(mktemp -d)
		mount "$part_fs_expand_target" "$part_fs_expand_tmp"
		btrfs fi resize max "$part_fs_expand_tmp"
		umount "$part_fs_expand_tmp"
		rmdir "$part_fs_expand_tmp"
	elif [ "$part_fs_expand_type" = "$PART_FS_NTFS" ]; then
		ntfsfix "$part_fs_expand_target"
		ntfsresize -x "$part_fs_expand_target"
	else
		echo "$PART_FS_PREFIX expanding $part_fs_expand_type is not supported." >&2
		return 1
	fi
	parted "$1" unit s print
}
