#!/bin/bash -e

LOC="$(cd `dirname $0`; pwd)"
REPO="$(pwd)"

#repo init -u git://github.com/ParanoidAndroid/android.git -b jellybean
#cp ${LOC}/local_manifest.xml /.repo/
#repo sync -j32
# for c in `grep "From " *.patch | awk '{print $2}'`; do grep $c *.patch | awk '{print $2" "$1}' | cut -d':' -f1; done > hybrid-packages_apps_settings.txt

# repo start <branch_name> <folder>
# repo upload <folder>
# repo abandon <branchname>

# manual upload to gerrit
# git push ssh://eugenesan@review.paranoid-rom.com:29418/ParanoidAndroid/manifest HEAD:refs/for/jellybean

# OpenPdroid
# Build
cd ${REPO}/build; git am ${LOC}/openpdroid-1.51-the-better-privacy-protection-build.patch
#cd ${REPO}/build; git fetch http://eugenesan@review.cyanogenmod.com/CyanogenMod/android_build refs/changes/56/25056/1 && git cherry-pick FETCH_HEAD
# Base
cd ${REPO}/frameworks/base; git am ${LOC}/openpdroid-1.51-the-better-privacy-protection-frameworks_base.patch
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/57/25057/1 && git cherry-pick FETCH_HEAD
# Telephony
cd ${REPO}/frameworks/opt/telephony; git am ${LOC}/openpdroid-1.51-the-better-privacy-protection-frameworks_opt_telephony.patch
#cd ${REPO}/frameworks/opt/telephony; git fetch http://eugenesan@review.cyanogenmod.com/CyanogenMod/android_vendor_cm refs/changes/59/25059/1 && git cherry-pick FETCH_HEAD
# LibCore
cd ${REPO}/libcore; git am ${LOC}/openpdroid-1.51-the-better-privacy-protection-libcore.patch
#cd ${REPO}/libcore; git fetch http://eugenesan@review.cyanogenmod.com/CyanogenMod/android_libcore refs/changes/58/25058/1 && git cherry-pick FETCH_HEAD
# MMS
cd ${REPO}/packages/apps/Mms; git am ${LOC}/openpdroid-1.51-the-better-privacy-protection-packages_apps_mms.patch
#cd ${REPO}/packages/apps/Mms; git fetch http://eugenesan@review.cyanogenmod.com/CyanogenMod/android_vendor_cm refs/changes/59/25059/1 && git cherry-pick FETCH_HEAD

# Optional Enc Pass Sync
# Base
cd ${REPO}/frameworks/base; git am ${LOC}/optional-encryption-password-sync-frameworks_base-aosp.patch
#cd ${REPO}/frameworks/base; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_frameworks_base refs/changes/41/3441/1 && git cherry-pick FETCH_HEAD
# Settings
cd ${REPO}/packages/apps/Settings; git am ${LOC}/optional-encryption-password-sync-packages_apps_sesttings-aosp.patch
#cd ${REPO}/packages/apps/Settings; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_packages_apps_Settings refs/changes/42/3442/1 && git cherry-pick FETCH_HEAD

# Add/Remove custom apps
cd ${REPO}/vendor/pa; git am ${LOC}/add-remove-custom-apps-vendor_pa-aospa.patch

if [ ! -r ${REPO}/vendor/pa/prebuilt/common/apk/get-prebuilts.stamp ]; then
	echo -e "Downloading prebuilts"
	rm -f ${REPO}/vendor/pa/prebuilt/common/get-prebuilts.stamp

	set -e
	# Get Market Enabler (Source: https://code.google.com/p/market-enabler/downloads/list)
	curl -L -o ${REPO}/vendor/pa/prebuilt/common/apk/MarketEnabler.apk -O -L "http://market-enabler.googlecode.com/files/MarketEnabler_v3113.apk"

	# Get Adobe Flash Player (Source: http://helpx.adobe.com/flash-player/kb/archived-flash-player-versions.html)
	curl -L -o ${REPO}/vendor/pa/prebuilt/common/apk/AdobeFlashPlayer.apk -O -L "http://download.macromedia.com/pub/flashplayer/installers/archive/android/11.1.115.34/install_flash_player_ics.apk"

	# Get Pdroid manager (http://forum.xda-developers.com/showthread.php?p=34190204)
	curl -L -o ${REPO}/vendor/pa/prebuilt/common/apk/Pdroid.apk -O -L "http://forum.xda-developers.com/attachment.php?attachmentid=1638382&d=1357994614"

	# Get Android Terminal Emulator (we use a prebuilt so it can update from the Market)
	curl -L -o ${REPO}/vendor/pa/prebuilt/common/apk/Term.apk -O -L "http://jackpal.github.com/Android-Terminal-Emulator/downloads/Term.apk"
	unzip -o -d ${REPO}/vendor/pa/prebuilt/common ${REPO}/vendor/pa/prebuilt/common/apk/Term.apk lib/armeabi/libjackpal-androidterm4.so
	set +e

	touch ${REPO}/vendor/pa/prebuilt/common/apk/get-prebuilts.stamp
else
	echo -e "Already downloaded prebuilts"
fi

# Update build and CM components
cd ${REPO}/vendor/pa; git am ${LOC}/sync-build-numbers-and-cm-components-vendor_pa.patch
#cd ${REPO}/vendor/pa; git am ${LOC}/make-prefs-build-default-but-optional-vendor_pa.patch
cd ${REPO}/vendor/pa; git am ${LOC}/unify-products-and-packages-vendor_pa.patch
#cd ${REPO}/vendor/pa; git am ${LOC}/use-paranoid-mako-kernel-with-gcc-4.7-fix-vendor_pa.patch

# Reverse SysBar
cd ${REPO}/frameworks/base; git am ${LOC}/sysbar_reverse-1.0-frameworks_base-aospa.patch

# Correct mako settings
cd ${REPO}/device/lge/mako; git am ${LOC}/update-board-config-device_lge_mako.patch

# Fix touchscreen
#cd ${REPO}/kernel/lge/mako; git revert --no-edit 2f2979bed80125daa9bd6e3adc1d4ac11fdd8ca7

# Fix bionic build
#cd ${REPO}/bionic; git revert --no-edit d81069592243d744aaefd238db7f77a6c1f3e398

# Fix mako kernel with gcc 4.7
#cd ${REPO}/kernel/lge/mako; git am ${LOC}/fix-mako-kernel-compile-with-gcc-4.7.patch
#cd ${REPO}/build; git am ${LOC}/allow-mako-kernel-build-with-4.7-build.patch

# Increasing ring
#cd ${REPO}/frameworks/base; git am ${LOC}/increasing-ring-volume-frameworks_base-aosp.patch
##cd ${REPO}/frameworks/base; git fetch http://gerrit.sudoservers.com/AOKP/frameworks_base refs/changes/76/4476/8 && git cherry-pick FETCH_HEAD
#cd ${REPO}/packages/apps/Phone; git am ${LOC}/increasing-ring-volume-packages_apps_phone-aosp.patch
##cd ${REPO}/packages/apps/Phone; git fetch http://gerrit.sudoservers.com/AOKP/packages_apps_Phone refs/changes/74/4474/9 && git cherry-pick FETCH_HEAD
#cd ${REPO}/packages/apps/Settings; git am ${LOC}/increasing-ring-volume-packages_apps_settings-aosp.patch
##cd ${REPO}/packages/apps/Settings; git fetch http://gerrit.sudoservers.com/AOKP/packages_apps_Settings refs/changes/96/4896/2 && git cherry-pick FETCH_HEAD

# Quite hours
#cd ${REPO}/frameworks/base; git am ${LOC}/quiet-hours-frameworks_base.patch
##cd ${REPO}/frameworks/base; git fetch http://gerrit.sudoservers.com/AOKP/frameworks_base refs/changes/55/2055/2 && git cherry-pick FETCH_HEAD
#cd ${REPO}/packages/apps/Phone; git am ${LOC}/quiet-hours-packages_apps_phone.patch
##cd ${REPO}/packages/apps/Phone; git fetch http://gerrit.sudoservers.com/AOKP/packages_apps_Phone refs/changes/57/2057/1 && git cherry-pick FETCH_HEAD 
#cd ${REPO}/packages/apps/Settings; git am ${LOC}/quiet-hours-packages_apps_settings.patch
##cd ${REPO}/packages/apps/Settings; git fetch http://gerrit.sudoservers.com/AOKP/packages_apps_Settings refs/changes/56/2056/3 && git cherry-pick FETCH_HEAD

# SoundRecorder
cd ${REPO}/packages/apps/SoundRecorder; git am ${LOC}/restore-soundrecorder-interface-packages_apps_soundrecorder.patch
#cd ${REPO}/packages/apps/SoundRecorder; git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_SoundRecorder refs/changes/10/25010/1 && git cherry-pick FETCH_HEAD

cd ${REPO}

#sed -i "s/true/false/" vendor/pa/products/pa_*.mk
#sed -i "s/ParanoidWallpapers/Trebuchet/" vendor/pa/config/pa_common.mk

exit 0

# --------------------------------- Trash ---------------------------------

# Dalvik optimzations
cd ${REPO}/dalvik; git fetch http://review.cyanogenmod.org/CyanogenMod/android_dalvik refs/changes/38/26538/1 && git cherry-pick FETCH_HEAD
cd ${REPO}/dalvik; git am ${LOC}/remove-duplicated-call-to-dvmJitCalleeSave-dalvik.patch

# Hybrid mode
cd ${REPO}/frameworks/base; grep -v "^#" ${LOC}/hybrid-frameworks_base.txt | awk '{print $1}' | while read c; do git cherry-pick $c; done
cd ${REPO}/packages/apps/Settings; grep -v "^#" ${LOC}/hybrid-packages_apps_settings.txt | awk '{print $1}' | while read c; do git cherry-pick $c; done
cd ${REPO}/vendor/cm; git am ${LOC}/hybrid-vendor_cm.patch
#cd ${REPO}/frameworks/base; git am ${LOC}/hybrid-engine-frameworks_base-v0.3.patch
#cd ${REPO}/packages/apps/Settings; git am ${LOC}/hybrid-engine-packages_apps_settings-v0.2.patch

# Doclava fixes
#cd ${REPO}/external/doclava; git am ${LOC}/let-me-compile-external_doclava.patch
cd ${REPO}/external/doclava; grep -v "^#" ${LOC}/hybrid-external_doclava.txt | awk '{print $1}' | while read c; do git cherry-pick $c; done

# Fix Ghost Ring
#cd ${REPO}/packages/apps/Phone; git am ${LOC}/fix-occasional-ring-volume-reset-packages_apps_phone-cm10.1.patch
#cd ${REPO}/packages/apps/Phone; git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Phone refs/changes/60/29360/2 && git cherry-pick FETCH_HEAD


# Build optimizations
#cd ${REPO}/build; git am ${LOC}/use-gcc-4.7-build.patch

# Return TabletUI
#cd ${REPO}/frameworks/base; git am ${LOC}/revert-switch-to-split-status-nav-bars-on-all-device-framework_base.patch

# Force Phablet mode
#cd ${REPO}/frameworks/base; git am ${LOC}/force-phablet-mode-frameworks_base.patch

# Qemu fixes
#cd ${REPO}/external/qemu; git am ${LOC}/default-density-external_qemu.patch

# SystemCore fixes
#cd ${REPO}/system/core; git am ${LOC}/allow-using-data-local.prop-system_core.patch

# CM10 rebase
#cd ${REPO}/frameworks/base; git fetch cm; git merge --no-edit --ff cm/jellybean
#cd ${REPO}/packages/apps/Settings; git fetch cm; git merge --no-edit --ff cm/jellybean
#cd ${REPO}/system/cere; git fetch cm; git merge --no-edit --ff cm/jellybean


# ReEnable filemanager
#cd ${REPO}/android; git revert --no-edit d912fe4f5e6a9ef2cf823026fde0dd9557459df6
cd ${REPO}/vendor/pa; git revert --no-edit fa5bc50fe24ed603cc0ca229be4ac65af03774f4

# Update SuperSU
#cd ${REPO}/vendor/pa; git cherry-pick 43f9ff084c99cbe2706cbdb5fc485c6597cdbaa2

# Camera storage select
#cd ${REPO}/packages/apps/Camera; git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_Camera refs/changes/48/25848/1 && git cherry-pick FETCH_HEAD
#cd ${REPO}/packages/apps/Camera; git am ${LOC}/add-option-to-select-storage-location-in-camera-packages_apps_camera.patch
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/47/25847/1 && git cherry-pick FETCH_HEAD
#cd ${REPO}/frameworks/base; git am ${LOC}/add-option-to-select-storage-location-in-camera-frameworks_base.patch

# Dandelion Sounds
#cd ${REPO}/frameworks/base; git am ${LOC}/dandelion-sounds-frameworks_base.patch

# non-cyanogenmod github accounts
#cd ${REPO}/paranoid; git am ${LOC}/allow-non-cyanogenmod-device-repos-paranoid.patch
#cd ${REPO}/paranoid; git fetch http://review.paranoid-rom.com/ParanoidAndroid/paranoid refs/changes/38/138/1 && git cherry-pick FETCH_HEAD
#cd ${REPO}/vendor/pa; git am ${LOC}/allow-non-cyanogenmod-device-repos-vendor_pa.patch
#cd ${REPO}/vendor/pa; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_vendor_pa refs/changes/39/139/1 && git cherry-pick FETCH_HEAD
#cd ${REPO}; cp -f paranoid/build.sh rom-build.sh

# p4wifi (needs xdpi to mdpi update)
#cd ${REPO}/vendor/pa; git am ${LOC}/preliminar-gtab-10.1-p4wifi-support-vendor_pa.patch
#cd ${REPO}/vendor/pa; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_vendor_pa refs/changes/40/140/1 && git cherry-pick FETCH_HEAD

# pyramid
#cd ${REPO}/vendor/pa; git am ${LOC}/vendor-add-HTC-Sensation-pyramid-vendor_pa.patch
#cd ${REPO}/vendor/pa; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_vendor_pa refs/changes/42/142/1 && git cherry-pick FETCH_HEAD

# Misc
#cd ${REPO}/frameworks/base; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_frameworks_base refs/changes/93/93/4 && git cherry-pick FETCH_HEAD

# System
#cd ${REPO}/android; git am ${LOC}/sync-with-cm10-android.patch
#cd ${REPO}/system/core; git am ${LOC}/sync-with-cm10-system_core.patch

# Fix battery percentage on tablet
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/91/25791/1 && git cherry-pick FETCH_HEAD
#cd ${REPO}/frameworks/base; git am ${LOC}/fix-battery-percentage-on-tablet-frameworks_base.patch

# tuna clean
#cd ${REPO}/vendor/pa; git am ${LOC}/remove-redundant-firmware-copy-for-tuna-devices-vendor_pa.patch
#cd ${REPO}/vendor/pa; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_vendor_pa refs/changes/41/141/2 && git cherry-pick FETCH_HEAD

# Misc cyanogemod commits
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/01/25501/10 && git cherry-pick FETCH_HEAD
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/40/25840/1 && git cherry-pick FETCH_HEAD
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/02/25502/2 && git cherry-pick FETCH_HEAD
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/57/24957/1 && git cherry-pick FETCH_HEAD
#cd ${REPO}/packages/apps/Trebuchet; git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_Trebuchet refs/changes/90/25490/1 && git cherry-pick FETCH_HEAD

