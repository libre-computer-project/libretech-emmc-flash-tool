#!/bin/sh

set -e

MAIN_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

MAIN_PREFIX="MAIN:"

. $MAIN_DIR/config.sh
. $MAIN_DIR/image_format.sh
. $MAIN_DIR/part_fs.sh
. $MAIN_DIR/left.sh

if [ -f "${0/.sh/.debug/}" ]; then
	set -x
fi

function main_wait(){
	image_part_found=0
	while true; do
		if [ -b "$IMAGE_TARGET" ]; then
			break
		fi
		echo "$MAIN_PREFIX waiting for target device enumeration"
		sleep 1
	done

	while true; do
		for image_part in $IMAGE_PART_TARGETS; do
			if [ -b $image_part ]; then
				image_part_found=1
				break
			fi
		done
		if [ $image_part_found -eq 1 ]; then
			break
		fi
		echo "$MAIN_PREFIX waiting for source device enumeration"
		sleep 1
	done
}

function main_trap(){
	trap 'echo "UNEXPECTED EXIT" >&2; trap - EXIT;  while true; do sleep 3600; done; exit' EXIT
}

function main(){
	main_wait
	for image_part in $IMAGE_PART_TARGETS; do
		if [ -b "$image_part" ]; then
			LEFT_run "$image_part"
			break
		fi
	done
}

main
