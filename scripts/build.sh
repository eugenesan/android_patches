#!/bin/bash

# wget --continue --header "Cookie: gpw_e24=h" http://download.oracle.com/otn-pub/java/jdk/6u38-b05/jdk-6u38-linux-x64.bin -O /tmp/jdk-6u38-linux-x64.bin
# chmod +x /tmp/jdk-6u38-linux-x64.bin
# mkdir -p /usr/lib/jvm/
# cd /usr/lib/jvm/
# /tmp/jdk-6u38-linux-x64.bin
# cd jdk1.6.0_38
# update-alternatives --install /usr/bin/java java $(pwd)/bin/java 1
# update-alternatives --install /usr/bin/javac javac $(pwd)/bin/javac 1
# update-alternatives --install /usr/bin/javaws javaws $(pwd)/bin/javaws 1
# update-alternatives --config java
# update-alternatives --config javac
# update-alternatives --config javaws
# cd -; cd -

#aptitude --without-recommends install default-jdk eclipse smartgit
#ln -s /usr/lib/jni/libswt-* ~/.swt/lib/linux/x86_64/

#export PATH=/opt/jdk/bin:/opt/jdk/jre/bin:$PATH
#export PATH=/usr/lib/jvm/java-6-oracle/bin:/usr/lib/jvm/java-6-oracle/jre/bin:$PATH
#export PATH=/usr/lib/jvm/java-6-oracle/bin:$PATH

# get current path
DIR=`pwd`

# Colorize and add text parameters
txtbld=$(tput bold)             # bold
txtrst=$(tput sgr0)             # reset
red=$(tput setaf 1)             # red
grn=$(tput setaf 2)             # green
blu=$(tput setaf 4)             # blue
cya=$(tput setaf 6)             # cyan
bldred=${txtbld}$(tput setaf 1) # bold red
bldgrn=${txtbld}$(tput setaf 2) # bold green
bldblu=${txtbld}$(tput setaf 4) # bold blue
bldcya=${txtbld}$(tput setaf 6) # bold cyan

THREADS="16"
DEVICE="$1"
EXTRAS="$2"

# get current version
if [ -r vendor/pa/config/pa_common.mk ]; then
	MAJOR=$(cat $DIR/vendor/pa/config/pa_common.mk | grep 'PA_VERSION_MAJOR = *' | sed  's/PA_VERSION_MAJOR = //g')
	MINOR=$(cat $DIR/vendor/pa/config/pa_common.mk | grep 'PA_VERSION_MINOR = *' | sed  's/PA_VERSION_MINOR = //g')
	MAINTENANCE=$(cat $DIR/vendor/pa/config/pa_common.mk | grep 'PA_VERSION_MAINTENANCE = *' | sed  's/PA_VERSION_MAINTENANCE = //g')
	VERSION=pa-$MAJOR.$MINOR$MAINTENANCE
	VENDOR="pa"
elif [ -r vendor/cm/config/common.mk ]; then
	MAJOR=$(cat $DIR/vendor/cm/config/common.mk | grep 'PRODUCT_VERSION_MAJOR = *' | sed  's/PRODUCT_VERSION_MAJOR = //g')
	MINOR=$(cat $DIR/vendor/cm/config/common.mk | grep 'PRODUCT_VERSION_MINOR = *' | sed  's/PRODUCT_VERSION_MINOR = //g')
	MAINTENANCE=$(cat $DIR/vendor/cm/config/common.mk | grep 'PRODUCT_VERSION_MAINTENANCE = *' | sed  's/PRODUCT_VERSION_MAINTENANCE = //g')
	VERSION=cm-$MAJOR.$MINOR$MAINTENANCE
	VENDOR="cm"
else
	VENDOR="aosp-v0.0"
fi

# if we have not extras, reduce parameter index by 1
if [ "$EXTRAS" == "true" ] || [ "$EXTRAS" == "false" ]; then
	SYNC="$2"
	UPLOAD="$3"
else
	SYNC="$3"
	UPLOAD="$4"
fi

# get time of startup
res1=$(date +%s.%N)

# get ccache size at start
#export CCACHE_DIR="/var/cache/ccache"
export CCACHE_DIR="/home/android/ccache"
CCACHE_BIN="prebuilts/misc/linux-x86/ccache/ccache"
[ ! -d "${CCACHE_DIR}" ] && mkdir -p "${CCACHE_DIR}" && sudo chmod 777 "${CCACHE_DIR}"
[ ! -L "${CCACHE_BIN}" ] && mv -f "${CCACHE_BIN}" "${CCACHE_BIN}.orig" && ln -sf /usr/bin/ccache "${CCACHE_BIN}"
export USE_CCACHE=1
export CCACHE_NLEVELS=4
export CCACHE_COMPRESS=1
export CCACHE_NOSTATS=1
#cache1=$(${CCACHE_BIN} -s | grep "^cache size" | awk '{print $3$4}')
cache1=$(du -sh ${CCACHE_DIR} | awk '{print $1}')

# we don't allow scrollback buffer
echo -e '\0033\0143'
clear

echo -e "${cya}Building ${bldcya}Android $VERSION for $DEVICE ${txtrst}";
echo -e "${bldgrn}Start time: $(date) ${txtrst}"
echo -e "${bldgrn}ccache size: ${txtrst} ${grn}${cache1}${txtrst}"

if [ -d vendor/pa ]; then
	echo -e "${cya}"
	./vendor/pa/tools/getdevicetree.py $DEVICE
	echo -e "${txtrst}"
else
	echo -e "${bldcya}Not PA tree, skipping prebuilts ${txtrst}"
fi

# decide what command to execute
case "$EXTRAS" in
threads)
	echo -e "${bldblu}Please write desired threads followed by [ENTER] ${txtrst}"
	read threads
	THREADS=$threads
	;;
clean|cclean)
	echo -e "${bldblu}Cleaning intermediates and output files ${txtrst}"
	make clean > /dev/null
	[ -d vendor/cm ] && rm -f vendor/cm/get-prebuilts.stamp
	[ $EXTRAS == cclean ] && echo "${bldblu}Cleaning ccache ${txtrst}" && prebuilts/misc/linux-x86/ccache/ccache -C -M 5G
	;;
esac

# sync with latest sources
if [ "$SYNC" == "true" ]; then
	echo -e ""
	echo -e "${bldblu}Fetching latest sources ${txtrst}"
	repo sync -j"$THREADS"
	echo -e ""
fi

if [ -d vendor/cm ]; then
	echo -e ""
	if [ ! -r vendor/cm/proprietary/get-prebuilts.stamp ]; then
		echo -e "${bldblu}Downloading prebuilts ${txtrst}"
		cd vendor/cm
		rm -f get-prebuilts.stamp
		./get-prebuilts && touch proprietary/get-prebuilts.stamp
		cd ./../..
	else
		echo -e "${bldgrn}Already downloaded prebuilts ${txtrst}"
	fi
else
	echo -e "${bldcya}Not CM tree, skipping prebuilts ${txtrst}"
fi

# setup environment
echo -e ""
echo -e "${bldblu}Setting up environment ${txtrst}"
. build/envsetup.sh

# lunch/brunch device
if [ -d vendor/pa ]; then
	echo -e ""
	echo -e "${bldblu}Lunching device [$DEVICE] ${txtrst}"
	export PREFS_FROM_SOURCE=false
	lunch "pa_$DEVICE-userdebug";

	echo -e "${bldblu}Starting compilation ${txtrst}"
	mka bacon
	echo -e ""
else
	echo -e ""
	echo -e "${bldblu}Brunching device [$DEVICE] ${txtrst}"
	brunch $DEVICE
	echo -e ""
fi

# get ccache size
#cache2=$(${CCACHE_BIN} -s | grep "^cache size" | awk '{print $3$4}')
cache2=$(du -sh ${CCACHE_DIR} | awk '{print $1}')
echo -e "${bldgrn}cccache size is ${txtrst} ${grn}${cache2}${txtrst} (was ${grn}${cache1}${txtrst})"

# finished? get elapsed time
res2=$(date +%s.%N)
echo -e "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
