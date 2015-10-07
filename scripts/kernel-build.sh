#!/bin/bash

: ${ANDROID_TREE:="/media/eugenesan/in80gb/android/cm"}
: ${VENDOR:="lge"}
: ${DEVICE:="hammerhead"}
: ${GCC:="prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"}
: ${THREADS:="$(($(cat /proc/cpuinfo | grep "^processor" | wc -l) / 4 * 3))"}

[ -n "${1}" ] || echo "Use ${0} [hammerhead_defconfig] or ${0} [zImage-dtb]"
CCACHE_DIR=${ANDROID_TREE}/../ccache make ARCH=arm CROSS_COMPILE="ccache ${ANDROID_TREE}/${GCC}" -C ${ANDROID_TREE}/kernel/${VENDOR}/${DEVICE} O=${ANDROID_TREE}/../out/kernel/ -j${THREADS} ${@}
