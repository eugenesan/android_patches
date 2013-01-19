#!/bin/bash -e

LOC="$(cd `dirname $0`; pwd)"
REPO="$(pwd)"

#repo init -u git://github.com/ParanoidAndroid/android.git -b jellybean
#cp ${LOC}/local_manifest.xml /.repo/
#repo sync -j32

# CM10 rebase
#cd ${REPO}/frameworks/base; git fetch cm; git merge --no-edit --ff cm/jellybean
#cd ${REPO}/packages/apps/Settings; git fetch cm; git merge --no-edit --ff cm/jellybean
#cd ${REPO}/system/cere; git fetch cm; git merge --no-edit --ff cm/jellybean

# Pdroid
cd ${REPO}/build; git am ${LOC}/PDroid-1.32-The-Better-Privacy-Protection-build.patch
#cd ${REPO}/build; git fetch http://eugenesan@review.cyanogenmod.com/CyanogenMod/android_build refs/changes/56/25056/1 && git cherry-pick FETCH_HEAD
#
#cd ${REPO}/frameworks/base; git am ${LOC}/PDroid-1.32-The-Better-Privacy-Protection-framework_base.patch
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/57/25057/1 && git cherry-pick FETCH_HEAD
cd ${REPO}/frameworks/base; git am ${LOC}/PDroid-1.32-The-Better-Privacy-Protection-framework_base-pa.patch
#cd ${REPO}/frameworks/base; git am ${LOC}/PDroid-1.32-The-Better-Privacy-Protection-framework_base-remove-rils.patch
#cd ${REPO}/frameworks/base; git reset --hard
#rm ${REPO}/frameworks/base/telephony/java/com/android/internal/telephony/{HTC,LGE,Moto,Semc,Smdk,Sony}*RIL*
#
cd ${REPO}/libcore; git am ${LOC}/PDroid-1.32-The-Better-Privacy-Protection-libcore.patch
#cd ${REPO}/libcore; git fetch http://eugenesan@review.cyanogenmod.com/CyanogenMod/android_libcore refs/changes/58/25058/1 && git cherry-pick FETCH_HEAD
#
cd ${REPO}/vendor/cm; git am ${LOC}/PDroid-1.32-The-Better-Privacy-Protection-vendor_cm.patch
#cd ${REPO}/vendor/cm; git fetch http://eugenesan@review.cyanogenmod.com/CyanogenMod/android_vendor_cm refs/changes/59/25059/1 && git cherry-pick FETCH_HEAD

# Reverse SysBar
cd ${REPO}/frameworks/base; git am ${LOC}/sysbar_reverse-1.0-frameworks_base.patch

# Eugene San Tweaks
cd ${REPO}/vendor/pa; git am ${LOC}/remove-redundant-firmware-copy-for-tuna-devices-vendor_pa-cm.patch
cd ${REPO}/vendor/pa; git am ${LOC}/eugenesan-enable-pa_prefs-and-disable-pa_wallpapers-vendor_pa.patch
cd ${REPO}/vendor/cm; git am ${LOC}/eugenesan-add-custom-apps-vendor_cm.patch

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

cd ${REPO}

exit 0

# SoundRecorder
#cd ${REPO}/packages/apps/SoundRecorder; git am ${LOC}/restore-soundrecorder-interface-packages_apps_soundrecorder.patch
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_SoundRecorder refs/changes/10/25010/1 && git cherry-pick FETCH_HEAD

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

# Fix Ghost Ring
#cd ${REPO}/packages/apps/Phone; git am ${LOC}/fix-occasional-ring-volume-reset.patch
#cd ${REPO}/packages/apps/Phone; git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_Phone refs/changes/28/24128/1 && git cherry-pick FETCH_HEAD
#cd ${REPO}/packages/apps/Phone; git am ${LOC}/fix-occasional-ring-volume-reset-take2.patch
#cd ${REPO}/packages/apps/Phone; git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_Phone refs/changes/43/24143/1 && git cherry-pick FETCH_HEAD

# Optional Enc Pass Sync
#cd ${REPO}/frameworks/base; git am ${LOC}/optional-encryption-password-sync-frameworks_base.patch
#cd ${REPO}/frameworks/base; git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/34/24134/3 && git cherry-pick FETCH_HEAD
#cd ${REPO}/frameworks/base; git am ${LOC}/optional-encryption-password-sync-frameworks_base-pa.patch
#cd ${REPO}/frameworks/base; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_frameworks_base refs/changes/48/48/4 && git cherry-pick FETCH_HEAD
#
#cd ${REPO}/packages/apps/Settings; git am ${LOC}/optional-encryption-password-sync-packages_apps_sesttings.patch
#cd ${REPO}/packages/apps/Settings; git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_Settings refs/changes/35/24135/2 && git cherry-pick FETCH_HEAD
#cd ${REPO}/packages/apps/Settings; git am ${LOC}/optional-encryption-password-sync-packages_apps_sesttings-pa.patch
#cd ${REPO}/packages/apps/Settings; git fetch http://review.paranoid-rom.com/ParanoidAndroid/android_frameworks_base refs/changes/48/48/4 && git cherry-pick FETCH_HEAD

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
