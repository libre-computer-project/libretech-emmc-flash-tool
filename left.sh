#!/bin/sh

LEFT_PREFIX="LEFT:"

function LEFT_run(){
	echo "$LEFT_PREFIX source mounting $1"
	if mount -o ro "$1" "$IMAGE_PART_MOUNT"; then
		trap "umount $IMAGE_PART_MOUNT" INT HUP QUIT TERM
		echo "$LEFT_PREFIX source mounted at $1"
		if [ -f "$IMAGE_PART_MOUNT_INI" ]; then
			echo "$LEFT_PREFIX custom parameters:"
			cat "$IMAGE_PART_MOUNT_INI" | sed "s/^/	/"
			. "$IMAGE_PART_MOUNT_INI"
		fi

		IMAGE_PART_MOUNT_IMG="$IMAGE_PART_MOUNT/$IMAGE_FILE"

		if [ -f "$IMAGE_PART_MOUNT_IMG" ]; then
			LEFT_flash "$IMAGE_PART_MOUNT_IMG"
		else
			echo "$LEFT_PREFIX image file not found, source umounting $1"
			umount "$IMAGE_PART_MOUNT" "$1"
			trap - INT HUP QUIT TERM
			echo "$LEFT_PREFIX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
			echo "$LEFT_PREFIX source umounted $1, image not found"
			echo "$LEFT_PREFIX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
			return 1
		fi
	else
		echo "$LEFT_PREFIX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		echo "$LEFT_PREFIX source could not be mounted $1"
		echo "$LEFT_PREFIX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		return 1
	fi
}

function LEFT_flash(){
	if [ "$IMAGE_FORMAT" = "auto" ]; then
		echo "$LEFT_PREFIX image format auto detection"
		image_format=$(IMAGE_FORMAT_detect "$1")
		image_format_cmd=$(IMAGE_FORMAT_getDecCMD "$image_format")
		echo "$LEFT_PREFIX image format is $image_format"
		echo "$LEFT_PREFIX image decompression command is $image_format_cmd"
	else
		image_format_cmd=$(IMAGE_FORMAT_getDecCMD "$IMAGE_FORMAT")
	fi

	echo "$LEFT_PREFIX image flashing start"
	$image_format_cmd "$1" | dd of="$IMAGE_TARGET" bs=1M iflag=fullblock conv=fsync &
	image_flash_pid=$!

	sleep 1

	image_flash_counter=0
	while kill -0 $image_flash_pid > /dev/null 2>&1; do
		if [ $(((image_flash_counter+=1) % IMAGE_FLASH_STATUS_PERIOD)) -eq 0 ]; then
			kill -USR1 $image_flash_pid
		fi
		sleep 1
	done

	wait $image_flash_pid

	if [ $? -eq 0 ]; then
		echo "$LEFT_PREFIX image flashing completed, source unmounting $2"
		umount "$IMAGE_PART_MOUNT"
		if [ "$IMAGE_EXPAND" -eq 1 ]; then
			echo "$LEFT_PREFIX image expand start"
			PART_FS_expand "$IMAGE_TARGET"
			echo "$LEFT_PREFIX image expand completed"
		fi
		trap - INT HUP QUIT TERM EXIT
		echo "$LEFT_PREFIX source unmounted $1, flash completed successfully"
		read -n 1 -p "Press any key to shutdown."
		poweroff
	else
		echo "$LEFT_PREFIX image flashing error $?, source unmounting $2"
		umount "$IMAGE_PART_MOUNT"
		trap - INT HUP QUIT TERM
		echo "$LEFT_PREFIX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		echo "$LEFT_PREFIX source umounted $1, flash failed"
		echo "$LEFT_PREFIX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		while true; do sleep 3600; done
		return 1	
	fi
}
