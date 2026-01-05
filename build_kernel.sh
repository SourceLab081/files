#!/bin/bash
#
# Compile script for vauxite Kernel or others
# Copyright (C) 2020-2021 Adithya R.
# modified by @teleg3_7 for use in circleci or others

sudo apt update && sudo apt install -y libc++-dev build-essential git bc kmod cpio flex cpio libncurses5-dev bison libssl-dev libelf-dev curl zip unzip wget

# These variables are set outside the file so that there is no need to change this file.
# kernel_src="--depth=1 -b fog-new https://github.com/SourceLab081/greenforce"
# config="vendor/fog-perf_defconfig"
# variant="greenforce"

SECONDS=0 # builtin bash timer
ZIPNAME="Kernel-$variant-$(date '+%Y%m%d-%H%M')-fog.zip"
LOGTXT="Log-Kernel-$variant-$(date '+%Y%m%d-%H%M')-fog.txt"
CONFTXT="Config-Kernel-$variant-$(date '+%Y%m%d-%H%M')-fog.txt"

AK3_DIR="$(pwd)/folds/AnyKernel3"
DEFCONFIG=$config
curDir=`pwd`

#export KBUILD_BUILD_USER=nobody
#export KBUILD_BUILD_HOST=android-build

mkdir -p $(pwd)/folds

git clone $kernel_src kernel_src
wget https://github.com/SourceLab081/files/raw/refs/heads/main/telegramUploader.sh && chmod +x telegramUploader.sh
git clone --depth=1 -b master https://github.com/SourceLab081/AnyKernel3 "$AK3_DIR";
if [ "$eva" = "yes" ]; then
    cd $(pwd)/folds
    wget https://github.com/mvaisakh/gcc-build/releases/download/04012026/eva-gcc-arm-04012026.xz
    wget https://github.com/mvaisakh/gcc-build/releases/download/04012026/eva-gcc-arm64-04012026.xz    
	tar -xf eva-gcc-arm-04012026.xz
	tar -xf eva-gcc-arm64-04012026.xz
	export PATH="$(pwd)/folds/gcc-arm64/bin:$(pwd)/folds/gcc-arm/bin:$PATH"
	export SUBARCH="arm64" \
                CROSS_COMPILE="aarch64-elf-" \
  #CROSS_COMPILE_ARM32="arm-eabi-" \
  CC="aarch64-elf-gcc" \
  AR="aarch64-elf-ar" \
  AS="aarch64-elf-as" \
  NM="aarch64-elf-nm" \
  LD="aarch64-elf-ld" \
  STRIP="aarch64-elf-strip" \
  OBJCOPY="aarch64-elf-objcopy" \
  OBJDUMP="aarch64-elf-objdump" \
  OBJSIZE="aarch64-elf-size" \
  READELF="aarch64-elf-readelf" \
  HOSTCC="aarch64-elf-gcc" \
  HOSTCXX="aarch64-elf-g++" \
  HOSTAR="aarch64-elf-ar"
	cd $curDir
else
    TC_DIR="$(pwd)/folds/clang-r450784e"
    git clone --depth=1 -b 14 https://gitlab.com/ThankYouMario/android_prebuilts_clang-standalone "$TC_DIR" 
    export PATH="$TC_DIR/bin:$PATH"
fi
mkdir -p kernel_src/out

cd kernel_src

export ARCH=arm64
export LLVM=1
export LLVM_IAS=1

if [ "$KSU_NEXT" = "yes" ]; then
    #wget https://github.com/SourceLab081/files/raw/refs/heads/main/patch_ksu.sh
	#. patch_ksu.sh
	echo "CONFIG_KSU=y" >> arch/arm64/configs/$DEFCONFIG
	#rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - 
	#curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s stable
	rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy
	#wget https://github.com/SourceLab081/files/raw/refs/heads/main/fix_ksuNext.sh
    #. fix_ksuNext.sh
	ZIPNAME="Kernel-$variant-$(date '+%Y%m%d-%H%M')-fog-KSU-NEXT.zip"
	LOGTXT="Log_Kernel-$variant-$(date '+%Y%m%d-%H%M')-fog-KSU-NEXT.txt"
    CONFTXT="Config-Kernel-$variant-$(date '+%Y%m%d-%H%M')-fog-KSU-NEXT.txt"
fi

make O=out $DEFCONFIG
make O=out olddefconfig KCONFIG_NONINTERACTIVE=y < /dev/null

wget https://github.com/SourceLab081/files/raw/refs/heads/main/uploadToGithub.sh

echo -e "\nStarting compilation...\n"

make -j$(nproc --all) O=out  Image.gz dtb.img dtbo.img 2> >(tee $LOGTXT >&2) || . uploadToGithub.sh $LOGTXT; ../telegramUploader.sh $LOGTXT

ls -al out/.config

kernel="out/arch/arm64/boot/Image.gz"
dtb="out/arch/arm64/boot/dtb.img"
dtbo="out/arch/arm64/boot/dtbo.img"

if [ -f "$kernel" ]; then
    echo  "\nCompilation success"
	cp $kernel $dtb $dtbo $AK3_DIR
	cd $AK3_DIR && zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
	cd $curDir
	echo  "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
    echo "upload to github"
	cp  kernel_src/out/.config $CONFTXT
	. kernel_src/uploadToGithub.sh folds/$ZIPNAME
	# . kernel/uploadToGithub.sh $CONFTXT 
	echo "upload to telegram"
	./telegramUploader.sh  folds/$ZIPNAME
	./telegramUploader.sh  $CONFTXT
else
	echo  "\nCompilation failed!"
fi
