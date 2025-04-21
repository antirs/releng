#!/bin/bash

[[ $# -lt 1 ]] && { echo 'Usage: $0 <build_dir> [-u]'; exit 1; }

BUILD_DIR=$1
umount=$2

if [[ "$umount" == "-u" ]]; then
	umount -l "${BUILD_DIR}"/dev
	umount -l "${BUILD_DIR}"/sys
	umount -l "${BUILD_DIR}"/var/cache/distfiles
	umount -l "${BUILD_DIR}"/var/db/repos
	umount "${BUILD_DIR}"/proc
	umount "${BUILD_DIR}"/var/tmp/portage
else
	mount --rbind /dev "${BUILD_DIR}"/dev
	mount --rbind /sys "${BUILD_DIR}"/sys
	mount --rbind /var/cache/distfiles "${BUILD_DIR}"/var/cache/distfiles
	mount --rbind /var/db/repos "${BUILD_DIR}"/var/db/repos
	mount -t proc proc "${BUILD_DIR}"/proc
	mount -t tmpfs tmpfs "${BUILD_DIR}"/var/tmp/portage
fi
