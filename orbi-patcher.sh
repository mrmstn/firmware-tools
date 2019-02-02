#!/bin/bash
set +e

readonly U_IMAGE_CLEAN="clean_uImage.bin"
readonly U_IMAGE_SIZE="3932160"
readonly IMG_PATH="."
readonly ALIGNED_IMG_SQUASHFS="root_cc.squashfs"

readonly HW_ID_RBR20="29765641+0+256+512+2x2+2x2+2x2"
readonly HW_ID_RBS20="29765641+0+128+512+2x2+2x2+2x2"

vars_rbs20(){
    BOARD="RBS20"
    VERSION="2.2.1.210"
    HW_ID="${HW_ID_RBS20}"
    SQUASHFS_BS="128k"
}
vars_rbr20(){
    BOARD="RBR20"
    VERSION="2.2.1.210"
    HW_ID="${HW_ID_RBR20}"
    SQUASHFS_BS="2k"
}

squashfs(){
    local rootfs_root="${1}"
    mksquashfs $rootfs_root \
		root.squashfs \
		-nopad \
		-noappend \
		-root-owned \
		-comp xz \
		-Xpreset 9 \
		-Xe \
		-Xlc 0 \
		-Xlp 2 \
		-Xpb 2 \
		-Xbcj arm \
		-b 256k \
		-no-xattrs \
		-p '/dev d 755 0 0' \
		-p '/dev/console c 600 0 0 5 1' \
    -processors 1

    padjffs2 "root.squashfs" 4 8 16 64 128 256
}

squashfs_align(){
    local squash_fs="${ALIGNED_IMG_SQUASHFS}"
    dd if="root.squashfs" of=${squash_fs} bs=${SQUASHFS_BS} conv=sync
}

clean_uimage(){
    tail -c +129 uImage.bin > clean_uImage.bin
    #dd skip=128 bs=4k if=${IMG_PATH}/uImage.bin of=${IMG_PATH}/clean_uImage.bin
    truncate -s -64 clean_uImage.bin
}

append_entrypoint_to_uimage(){
    mkimage -A arm \
		-O linux \
		-T kernel \
		-C lzma \
		-a 0x40908000 \
		-e 0x40908000 \
		-n 'ARM OpenWrt Linux-3.14.77' \
		-d ${IMG_PATH}/${ALIGNED_IMG_SQUASHFS} \
    ${IMG_PATH}/${ALIGNED_IMG_SQUASHFS}.uImage

    orbi ${IMG_PATH}/${ALIGNED_IMG_SQUASHFS}.uImage ${IMG_PATH}/${ALIGNED_IMG_SQUASHFS}.tmp
    dd if=${IMG_PATH}/${ALIGNED_IMG_SQUASHFS}.tmp bs=64 count=1 >> ${IMG_PATH}/${U_IMAGE_CLEAN}
}

build_final_image(){
    (
        dd if=${IMG_PATH}/${U_IMAGE_CLEAN} bs="${U_IMAGE_SIZE}" conv=sync; \
	dd if=${IMG_PATH}/${ALIGNED_IMG_SQUASHFS} bs=64k; \
    ) > ${IMG_PATH}/oneimage_cc.img.final

    mkdniimg -B "${BOARD}" -v "${VERSION}" -r "" -H "${HW_ID}" -i ${IMG_PATH}/oneimage_cc.img.final -o ${IMG_PATH}/"${BOARD}"-V"${VERSION}"""_new.img
}

extract(){
    local rom_file="${1}"
    openwrt-repack "${rom_file}" -U
}

read_hw_id(){
    readonly detected_hw_id=$(cat ./squashfs-root/hw_id)
    if [[ "${HW_ID_RBR20}" == "${detected_hw_id}" ]]; then
        vars_rbr20
    elif [[ "${HW_ID_RBS20}" == "${detected_hw_id}" ]]; then
        vars_rbs20
    else
        exit 1
    fi
}

copy_files(){
    cp -rv ./files/* "./squashfs-root"
}

main(){
    local rom_file="${1}"
    extract "${rom_file}"
    read_hw_id
    clean_uimage
    copy_files
    squashfs "./squashfs-root"
    squashfs_align
    append_entrypoint_to_uimage
    build_final_image
}

main "${@}"
