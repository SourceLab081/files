#!/bin/bash
#
# Compile script for vauxite Kernel and others
# Copyright (C) 2020-2021 Adithya R.
# modified by @teleg3_7

sudo apt update && sudo apt install -y libc++-dev build-essential git bc kmod cpio flex cpio libncurses5-dev bison libssl-dev libelf-dev curl zip unzip

kernel_src="--depth=1 -b fog-new https://github.com/SourceLab081/greenforce"
config="vendor/fog-hybris_defconfig"
variant="hybris_gf"

SECONDS=0 # builtin bash timer
ZIPNAME="Kernel-$variant-$(date '+%Y%m%d-%H%M')-fog.zip"
TC_DIR="$(pwd)/folds/clang-r450784e"
AK3_DIR="$(pwd)/folds/AnyKernel3"
DEFCONFIG=$config
curDir=`pwd`

export PATH="$TC_DIR/bin:$PATH"
#export KBUILD_BUILD_USER=nobody
#export KBUILD_BUILD_HOST=android-build

mkdir -p $(pwd)/folds

git clone $kernel_src kernel
wget https://github.com/SourceLab081/files/raw/refs/heads/main/telegramUploader.sh && chmod +x telegramUploader.sh
git clone --depth=1 -b 14 https://gitlab.com/ThankYouMario/android_prebuilts_clang-standalone "$TC_DIR"
git clone --depth=1 -b master https://github.com/CHRISL7/AnyKernel3 "$AK3_DIR";

mkdir -p kernel/out

cd kernel

export ARCH=arm64
export LLVM=1
export LLVM_IAS=1

if [ "$KSU_NEXT" = "yes" ]; then
    wget https://github.com/SourceLab081/files/raw/refs/heads/main/patch_ksu.sh
	. patch_ksu.sh
	echo "CONFIG_KSU=y" >> arch/arm64/configs/$DEFCONFIG
	rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - 
fi

make O=out $DEFCONFIG
make O=out olddefconfig KCONFIG_NONINTERACTIVE=y < /dev/null

echo -e "\nStarting compilation...\n"

make -j$(nproc --all) O=out  Image.gz dtb.img dtbo.img 2> >(tee log.txt >&2) ||  ./telegramUploader.sh log.txt

kernel="out/arch/arm64/boot/Image.gz"
dtb="out/arch/arm64/boot/dtb.img"
dtbo="out/arch/arm64/boot/dtbo.img"

if [ -f "$kernel" ]; then
    echo  "\nCompilation success"
	cp $kernel $dtb $dtbo $AK3_DIR
	cd $AK3_DIR && zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
	cd $curDir
	echo  "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
         ./telegramUploader.sh  folds/$ZIPNAME 
else
	echo  "\nCompilation failed!"
fi
