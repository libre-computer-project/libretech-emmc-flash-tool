#!/bin/sh

IMAGE_FORMAT_PREFIX="IMAGE_FOMAT:"

IMAGE_FORMAT_RAW="raw"
IMAGE_FORMAT_RAW_MIME="application/octet-stream"
IMAGE_FORMAT_RAW_CMD="cat"

IMAGE_FORMAT_XZ="xz"
IMAGE_FORMAT_XZ_MIME="application/x-xz"
IMAGE_FORMAT_XZ_CMD="xz -cdk"

IMAGE_FORMAT_GZIP="gzip"
IMAGE_FORMAT_GZIP_MIME="application/gzip"
IMAGE_FORMAT_GZIP_CMD="gzip -cdk"

IMAGE_FORMAT_ZIP="zip"
IMAGE_FORMAT_ZIP_MIME="application/zip"
IMAGE_FORMAT_ZIP_CMD="unzip -p"

IMAGE_FORMAT_LZ4="lz4"
IMAGE_FORMAT_LZ4_MIME="application/x-lz4"
IMAGE_FORMAT_LZ4_CMD="lz4 -cdk"

IMAGE_FORMAT_ZSTD="zstd"
IMAGE_FORMAT_ZSTD_MIME="application/zstd"
IMAGE_FORMAT_ZSTD_CMD="zstd -cdk"

function IMAGE_FORMAT_detect(){
	image_format_detect=$(file -b --mime-type "$1")
	if [ "$image_format_detect" = "$IMAGE_FORMAT_RAW_MIME" ]; then
		echo $IMAGE_FORMAT_RAW
	elif [ "$image_format_detect" = "$IMAGE_FORMAT_XZ_MIME" ]; then
		echo $IMAGE_FORMAT_XZ
	elif [ "$image_format_detect" = "$IMAGE_FORMAT_GZIP_MIME" ]; then
		echo $IMAGE_FORMAT_GZIP
	elif [ "$image_format_detect" = "$IMAGE_FORMAT_ZIP_MIME" ]; then
		echo $IMAGE_FORMAT_ZIP
	elif [ "$image_format_detect" = "$IMAGE_FORMAT_LZ4_MIME" ]; then
		echo $IMAGE_FORMAT_LZ4
	elif [ "$image_format_detect" = "$IMAGE_FORMAT_ZSTD_MIME" ]; then
		echo $IMAGE_FORMAT_ZSTD
	else
		echo "$IMAGE_FORMAT_PREFIX detect $image_format_detect is not supported." >&2
		return 1
	fi
}

function IMAGE_FORMAT_getDecCMD(){
	if [ "$1" = "$IMAGE_FORMAT_RAW" ]; then
		echo "$IMAGE_FORMAT_RAW_CMD"
	elif [ "$1" = "$IMAGE_FORMAT_XZ" ]; then
		echo "$IMAGE_FORMAT_XZ_CMD"
	elif [ "$1" = "$IMAGE_FORMAT_GZIP" ]; then
		echo "$IMAGE_FORMAT_GZIP_CMD"
	elif [ "$1" = "$IMAGE_FORMAT_ZIP" ]; then
		echo "$IMAGE_FORMAT_ZIP_CMD"
	elif [ "$1" = "$IMAGE_FORMAT_LZ4" ]; then
		echo "$IMAGE_FORMAT_LZ4_CMD"
	elif [ "$1" = "$IMAGE_FORMAT_ZSTD" ]; then
		echo "$IMAGE_FORMAT_ZSTD_CMD"
	else
		echo "$IMAGE_FORMAT_PREFIX cmddec $1 is not supported." >&2
		return 1
	fi
}
