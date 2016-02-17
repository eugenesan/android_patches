#!/bin/bash

: ${ANDROID_TREE:="/media/eugenesan/in80gb/android/cm"}
: ${VENDOR:="lge"}
: ${DEVICE:="hammerhead"}
: ${GCC:="prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"}
: ${THREADS:="$(($(cat /proc/cpuinfo | grep "^processor" | wc -l) / 4 * 3))"}
: ${KERNEL_TREE:="$ANDROID_TREE/kernel/$VENDOR/$DEVICE"}
: ${KERNEL_OBJ:="$ANDROID_TREE/../out/target/product/$DEVICE/obj/KERNEL_OBJ"}

mkdir -p "${KERNEL_OBJ}"

[ -n "${1}" ] || echo "Use ${0} [hammerhead_defconfig] or ${0} [zImage-dtb]"
CCACHE_DIR=${ANDROID_TREE}/../ccache make ARCH=arm CROSS_COMPILE="ccache ${ANDROID_TREE}/${GCC}" -C ${KERNEL_TREE} O=${KERNEL_OBJ} -j${THREADS} ${@}
