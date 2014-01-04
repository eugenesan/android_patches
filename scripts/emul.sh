#!/bin/sh

TARGET="out/target/product/generic"; out/host/linux-x86/bin/emulator \
    -skin WVGA800 -scale 0.7 -memory 512 -partition-size 1024 \
    -sysdir ${TARGET}/ \
    -kernel prebuilt/android-arm/kernel/kernel-qemu \
    -system ${TARGET}/system.img \
    -ramdisk ${TARGET}/ramdisk.img \
    -data ${TARGET}/userdata.img \
    -sdcard sdcard.img \
    -skindir sdk/emulator/skins
