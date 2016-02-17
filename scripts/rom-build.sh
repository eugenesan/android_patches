#!/bin/bash

# Android AOSP/AOSPA/CM/SLIM/OMNI build script
# Version 2.3.3

help() {
    cat <<EOB
Usage: $(basename ${0}) [device] [options]
        device:    : Specify device to be built (default is hammerhead)
        options:
        -c         : Clean output folder, log and screen (Twice to wipe ccache)
        -C         : Clean output folder, log, screen and wipe ccache
        -i         : Do not start build rather enter interactive mode with hints being printed
        -l         : Perform no logging
        -n         : Perform dummy build
        -r         : Perform an recovery build
        -s         : Perform a repo sync before build
        -x         : Clear screen and log before build
EOB
        exit 255
}

# Get current paths
DIR="$(cd `dirname $0`; pwd)"
OUT="$(readlink ${DIR}/out)"
PATH_ORIG="${PATH}"
SCRIPT="$(basename ${0})"

# Import command line parameters
[ $# -eq 0 ] && help
while getopts cCilnrsx opt; do
        case "$opt" in
                c)      CLEAN="y"          ;;
                C)      CLEAN="a"          ;;
                i)      MODE="interactive" ;;
                l)      LOG="dummy"        ;;
                n)      MODE="dummy"       ;;
                r)      MODE="recovery"    ;;
                s)      SYNC="y"           ;;
                x)      CLEAN="x"          ;;
                *)      help               ;;
        esac
done

shift `expr $OPTIND - 1`

# Set current device
DEVICE="${1}"
if [ -z "${DEVICE}" ]; then
	help
fi

# Load defaults, can be overriden by environment
: ${OUT:="$DIR/out"}
: ${USE_CCACHE:="true"}
: ${CCACHE_NOSTATS:="false"}
: ${CCACHE_DIR:="$(dirname $OUT)/ccache"}
: ${THREADS:="$(($(cat /proc/cpuinfo | grep "^processor" | wc -l) * 2 / 4 * 3 + 1))"}
: ${JSER:="7"}
: ${BUILD_TYPE:="userdebug"}
: ${RECOVERY_BUILD_TYPE:="eng"}
: ${PREFS_FROM_SOURCE:="false"}
: ${MODE:="rom"}
: ${LOG:="y"}

# Clean log if requested
if [ "${CLEAN}" == "y" ]; then
	rm ${DIR}/${SCRIPT%.*}.log
fi

# Clean scrollback buffer
if [ -n "${CLEAN}" ]; then
        echo -e '\0033\0143'
        clear
fi

# Enable logging
if [ "${LOG}" == "y" ]; then
        LOG="${SCRIPT%.*}.log"
        exec > >(tee -a ${DIR}/${LOG}) 2>&1
else
        unset LOG
fi

# Prepare output customization commands
red=$(tput setaf 1)             # red
grn=$(tput setaf 2)             # green
blu=$(tput setaf 4)             # blue
cya=$(tput setaf 6)             # cyan
bldred=${txtbld}$(tput setaf 1) # red
bldgrn=${txtbld}$(tput setaf 2) # green
bldblu=${txtbld}$(tput setaf 4) # blue
bldcya=${txtbld}$(tput setaf 6) # cyan
txtbld=$(tput bold)             # bold
txtrst=$(tput sgr0)             # reset

# If there is more than one jdk installed, use latest in series (JSER)
JC=`update-alternatives --list javac | wc -l`
if [ ${JC} -gt 1 ]; then
        JDK=$(dirname `update-alternatives --list javac | grep "\-${JSER}\-"` | tail -n1)
        JRE=$(dirname ${JDK}/../jre/bin/java)
        export PATH=${JDK}:${JRE}:${PATH_ORIG}
fi
if [ ${JC} -eq 0 ] || [ -z ${JDK} ]; then
        echo -e "${redbld}No valid Java${JSER} instalations found, exiting...${txtrst}"
        exit 1
fi
JVER=$(${JDK}/javac -version  2>&1 | head -n1 | cut -f2 -d' ')

# Get build version
if [ -r ${DIR}/vendor/pa/vendor.mk ]; then
        VENDOR="aospa"
        VENDOR_LUNCH="pa_"
        MAJOR=$(cat ${DIR}/vendor/pa/vendor.mk | grep 'ROM_VERSION_MAJOR := *' | sed  's/ROM_VERSION_MAJOR := //g')
        MINOR=$(cat ${DIR}/vendor/pa/vendor.mk | grep 'ROM_VERSION_MINOR := *' | sed  's/ROM_VERSION_MINOR := //g')
        MAINT=$(cat ${DIR}/vendor/pa/vendor.mk | grep 'ROM_VERSION_MAINTENANCE := *' | sed  's/ROM_VERSION_MAINTENANCE := //g')
elif [ -r ${DIR}/vendor/slim/vendorsetup.sh ]; then
        VENDOR="slim"
        VENDOR_LUNCH="slim_"
        MAJOR=$(cat ${DIR}/vendor/slim/config/common.mk | grep 'PRODUCT_VERSION_MAJOR = *' | sed  's/PRODUCT_VERSION_MAJOR = //g')
        MINOR=$(cat ${DIR}/vendor/slim/config/common.mk | grep 'PRODUCT_VERSION_MINOR = *' | sed  's/PRODUCT_VERSION_MINOR = //g')
        MAINT=$(cat ${DIR}/vendor/slim/config/common.mk | grep 'PRODUCT_VERSION_MAINTENANCE = *' | sed  's/PRODUCT_VERSION_MAINTENANCE = //g')
elif [ -r ${DIR}/vendor/cm/config/common.mk ]; then
        VENDOR="cm"
        VENDOR_LUNCH=""
        MAJOR=$(cat ${DIR}/vendor/cm/config/common.mk | grep 'PRODUCT_VERSION_MAJOR = *' | sed  's/PRODUCT_VERSION_MAJOR = //g')
        MINOR=$(cat ${DIR}/vendor/cm/config/common.mk | grep 'PRODUCT_VERSION_MINOR = *' | sed  's/PRODUCT_VERSION_MINOR = //g')
        MAINT=$(cat ${DIR}/vendor/cm/config/common.mk | grep 'PRODUCT_VERSION_MAINTENANCE = *' | sed  's/PRODUCT_VERSION_MAINTENANCE = //g')
elif [ -r ${DIR}/vendor/omni/config/common.mk ]; then
        VENDOR="omni"
        VENDOR_LUNCH=""
        MAJOR=$(cat ${DIR}/build/core/version_defaults.mk | grep 'PLATFORM_VERSION := *' | awk '{print $3}' | cut -f2 -d= | cut -f1 -d.)
        MINOR=$(cat ${DIR}/build/core/version_defaults.mk | grep 'PLATFORM_VERSION := *' | awk '{print $3}' | cut -f2 -d= | cut -f2 -d.)
        MAINT=$(cat ${DIR}/build/core/version_defaults.mk | grep 'PLATFORM_VERSION := *' | awk '{print $3}' | cut -f2 -d= | cut -f3 -d.)
elif [ -r ${DIR}/build/core/version_defaults.mk ]; then
        VENDOR="aosp"
        VENDOR_LUNCH="aosp_"
        MAJOR=$(cat ${DIR}/build/core/version_defaults.mk | grep 'PLATFORM_VERSION := *' | awk '{print $3}' | cut -f2 -d= | cut -f1 -d.)
        MINOR=$(cat ${DIR}/build/core/version_defaults.mk | grep 'PLATFORM_VERSION := *' | awk '{print $3}' | cut -f2 -d= | cut -f2 -d.)
        MAINT=$(cat ${DIR}/build/core/version_defaults.mk | grep 'PLATFORM_VERSION := *' | awk '{print $3}' | cut -f2 -d= | cut -f3 -d.)
else
        echo -e "${redbld}Invalid android tree, exiting...${txtrst}"
        exit 1
fi
VERSION=${VENDOR}-${MAJOR}.${MINOR}$([ -n "${MAINT}" ] && echo .)${MAINT}

# Get start time
res1=$(date +%s.%N)

# Prepare ccache and get it's initial size for reference
if [ "${USE_CCACHE}" == "true" ]; then
        # Prefer system ccache with compression
        CCACHE="$(which ccache)"
        if [ -n "${CCACHE}" ]; then
                export CCACHE_COMPRESS="1"
                echo -e "${bldblu}Using system ccache with compression enabled [${CCACHE}]${txtrst}"
        elif [ -r "${DIR}/prebuilts/misc/linux-x86/ccache/ccache" ]; then
                CCACHE="${DIR}/prebuilts/misc/linux-x86/ccache/ccache"
                echo -e "${bldblu}Using prebuilt ccache [${CCACHE}]${txtrst}"
        else
                echo -e "${bldblu}No suitable ccache found, disabling ccache usage${txtrst}"
                unset USE_CCACHE
                unset CCACHE_DIR
                unset CCACHE_NOSTATS
                unset CCACHE
        fi

        if [ -n "${CCACHE}" ]; then
                # Prepare ccache parameter for make
                CCACHE_OPT="ccache=${CCACHE}"

                # If custom ccache folder not specified, will use default one
                #[ -n "${CCACHE_DIR}" ] || CCACHE_DIR="${HOME}/.ccache"

                # Export and prepare ccache storage
                export CCACHE_DIR
                if [ ! -d "${CCACHE_DIR}" ]; then
                        mkdir -p "${CCACHE_DIR}"
                        chmod ug+rwX "${CCACHE_DIR}"
                        ${CCACHE} -C -M 5G
                        cache1=0
                fi
        fi

        # Save ccache size before build
        if [ -z "${cache1}" ]; then
                if [ "${CCACHE_NOSTATS}" == "true" ]; then
                        cache1=$(du -sh ${CCACHE_DIR} | awk '{print $1}')
                else
                        cache1=$(${CCACHE} -s | grep "^cache size" | awk '{print $3$4}')
                fi
        fi
else
        # Clean environment if ccache is not enabled
        unset USE_CCACHE
        unset CCACHE_OPT
        unset CCACHE_DIR
        unset CCACHE_NOSTATS
        unset CCACHE
fi

echo -e "${cya}Building ${MODE} ${bldcya}Android ${VERSION} for ${DEVICE} using Java-${JVER} with ${THREADS} threads"
echo -e "${bldgrn}Start time: $(date) ${txtrst}"

# Print ccache stats
[ -n "${USE_CCACHE}" ] && export USE_CCACHE && echo -e "${cya}Building using CCACHE${txtrst}"
[ -n "${CCACHE_DIR}" ] && export CCACHE_DIR && echo -e "${bldgrn}CCACHE: location = [${txtrst}${grn}${CCACHE_DIR}${bldgrn}], size = [${txtrst}${grn}${cache1}${bldgrn}]${txtrst}"

# Decide what command to execute
case "${CLEAN}" in
        y|a)
                echo -e "${bldblu}Cleaning intermediates and output files${txtrst}"
                export CLEAN_BUILD="true"
                [ -d "${DIR}/out" ] && rm -Rf ${DIR}/out/*
                # Clean ccache if we have to
                if [ -n "${CCACHE_DIR}" ] && [ ${CLEAN} == "a" ]; then
                        echo "${bldblu}Cleaning ccache${txtrst}"
                        ${CCACHE} -C -M 5G
                fi
        ;;
esac

echo -e ""

# Fetch latest sources
case "${SYNC}" in
        y)
        echo -e "\n${bldblu}Fetching latest sources${txtrst}"
        repo sync -j"${THREADS}"
        ;;
esac

if [ -r vendor/cm/get-prebuilts ]; then
        if [ -r vendor/cm/proprietary/.get-prebuilts ]; then
                echo -e "${bldgrn}Already downloaded prebuilts${txtrst}"
        else
                echo -e "${bldblu}Downloading prebuilts${txtrst}"
                pushd vendor/cm > /dev/null
                ./get-prebuilts && touch proprietary/.get-prebuilts
                popd > /dev/null
        fi
else
        echo -e "${bldcya}No prebuilts script in this tree${txtrst}"
fi

# Decide if we enter interactive mode or default build mode
if [ "${MODE}" == "interactive" ]; then
        echo -e "\n${bldblu}Enabling interactive mode. Possible commands are:${txtrst}"

        if [ "${VENDOR}" == "cm" ]; then
                echo -e "Prepare device environment: [${bldgrn}breakfast ${VENDOR_LUNCH}${DEVICE}${txtrst}]"
                echo -e "Or for recovery: [${bldgrn}lunch ${VENDOR}_${DEVICE}-${RECOVERY_BUILD_TYPE}${txtrst}]"
        elif [ "${VENDOR}" == "omni" ]; then
                echo -e "Prepare device environment: [${bldgrn}breakfast ${DEVICE}${txtrst}]"
        else
                echo -e "Prepare device environment: [${bldgrn}lunch ${VENDOR_LUNCH}${DEVICE}-${BUILD_TYPE}${txtrst}]"
        fi

        if [ "${VENDOR}" == "aosp" ]; then
                echo -e "Build device: [${bldgrn}schedtool -B -n 1 -e ionice -n 1 make -j${THREADS} ${CCACHE_OPT} ${JAVA_VERSION}${txtrst}]"
        elif [ "${VENDOR}" == "cm" ]; then
                echo -e "Build device: [${bldgrn}brunch ${VENDOR_LUNCH}${DEVICE}${txtrst}]"
        elif [ "${VENDOR}" == "omni" ]; then
                echo -e "Build device: [${bldgrn}brunch ${DEVICE}${txtrst}]"
        else
                echo -e "Build device: [${bldgrn}mka bacon${txtrst}]"
        fi

        echo -e "Build recovery: [${bldgrn}make -j"${THREADS}" recoveryimage${txtrst}]"

        echo -e "Emulate device: [${bldgrn}vncserver :1; DISPLAY=:1 emulator&${txtrst}]"

        # Setup and enter interactive environment
        echo -e "${bldblu}Dropping to interactive shell...${txtrst}"
        bash --init-file build/envsetup.sh -i
elif [ "${MODE}" == "recovery" ]; then
        # Setup environment
        echo -e "\n${bldblu}Setting up environment${txtrst}"
        . build/envsetup.sh

        # Print java caveats
        if [ ! -r "${DIR}/out/versions_checked.mk" ] && [ -n "$(java -version 2>&1 | grep -i openjdk)" ]; then
                echo -e "\n${bldcya}Your java version still not checked and is candidate to fail, masquerading.${txtrst}"
                export JAVA_VERSION="java_version=${JVER}"
        fi

        # Ensure java is set correctly
        export PATH=${JDK}:${JRE}:${PATH_ORIG}
        export JAVA_HOME="${JDK}"
        export J2REDIR="${JRE}"

        # Preparing
        echo -e "\n${bldblu}Preparing device [${DEVICE}]${txtrst}"
        if [ "${VENDOR}" == "cm" ]; then
                lunch ${VENDOR}_${DEVICE}-${RECOVERY_BUILD_TYPE}
        elif [ "${VENDOR}" == "omni" ]; then
                breakfast ${DEVICE}
        else
                lunch ${VENDOR_LUNCH}${DEVICE}-${BUILD_TYPE}
        fi

        echo -e "${bldblu}Starting recovery compilation${txtrst}"
        make -j"${THREADS}" recoveryimage
elif [ "${MODE}" == "rom" ]; then
        # Setup environment
        echo -e "\n${bldblu}Setting up environment${txtrst}"
        . build/envsetup.sh

        # Print java caveats
        if [ ! -r "${DIR}/out/versions_checked.mk" ] && [ -n "$(java -version 2>&1 | grep -i openjdk)" ]; then
                echo -e "\n${bldcya}Your java version still not checked and is candidate to fail, masquerading.${txtrst}"
                export JAVA_VERSION="java_version=${JVER}"
        fi

        # Ensure java is set correctly
        export PATH=${JDK}:${JRE}:${PATH_ORIG}
        export JAVA_HOME="${JDK}"
        export J2REDIR="${JRE}"

        # Preparing
        echo -e "\n${bldblu}Preparing device [${DEVICE}]${txtrst}"
        export PREFS_FROM_SOURCE
        if [ "${VENDOR}" == "cm" ]; then
                breakfast "${VENDOR_LUNCH}${DEVICE}"
        elif [ "${VENDOR}" == "omni" ]; then
                breakfast "${DEVICE}"
        else
                lunch "${VENDOR_LUNCH}${DEVICE}-${BUILD_TYPE}"
        fi

        echo -e "${bldblu}Starting compilation${txtrst}"
        if [ "${VENDOR}" == "aosp" ]; then
                schedtool -B -n 1 -e ionice -n 1 make -j${THREADS} ${CCACHE_OPT} ${JAVA_VERSION}
        elif [ "${VENDOR}" == "cm" ]; then
                brunch "${VENDOR_LUNCH}${DEVICE}"
        elif [ "${VENDOR}" == "omni" ]; then
                brunch "${DEVICE}"
        else
                mka bacon
        fi
else
        # Performing dummy build
        echo -e "\n${bldblu}Skipping actual build${txtrst}"
fi

# Save build script, log and manifests
echo -e "${bldblu}Saving build script, log and manifests${txtrst}"
repo manifest -r -o ${DIR}/${SCRIPT%.*}.revs.xml
repo manifest -o ${DIR}/${SCRIPT%.*}.heads.xml
mv -vf ${SCRIPT%.*}.tar.xz .${SCRIPT%.*}.tar.xz
XZ_OPT="-9e --threads=${THREADS}" tar -C ${DIR} -cJf ${SCRIPT%.*}.tar.xz \
        ${SCRIPT%.*}.* \
        .repo/{manifests{.git/config,/default.xml},local_manifests}

cd ${DIR}; rm -vf ${SCRIPT%.*}.{*xml,log}

# Get and print increased ccache size
if [ -n "${CCACHE_DIR}" ]; then
        if [ "${CCACHE_NOSTATS}" == "true" ]; then
                cache2=$(du -sh ${CCACHE_DIR} | awk '{print $1}')
        else
                cache2=$(prebuilts/misc/linux-x86/ccache/ccache -s | grep "^cache size" | awk '{print $3$4}')
        fi
                echo -e "\n${bldgrn}ccache size is ${txtrst} ${grn}${cache2}${txtrst} (was ${grn}${cache1}${txtrst})"
fi

# Get and print elapsed time
res2=$(date +%s.%N)
echo -e "\n${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "(${res2} - ${res1}) / 60"|bc ) minutes ($(echo "${res2} - ${res1}"|bc ) seconds)${txtrst}"
