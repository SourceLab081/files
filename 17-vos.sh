export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss

echo "memory:"
free -h
echo "cores:"
nproc --all

echo "update=$update"

#"twice" here = more than once
#export twice="no"
export twice="yes"
#temporary no
if [ "$update" = "no" ]; then
   
   if [ "$twice" = "no" ]; then
      #COZ error redeclaration and unresolved on folder   frameworks/base/
      rm -rf frameworks/base
   fi
   rm -rf device/xiaomi/fog
   
   repo init -u https://github.com/VoltageOS/manifest.git --depth 1 -b 17 --git-lfs
   rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 17-VoltageOS .repo/local_manifests

   echo "repo sync"
   /opt/crave/resync.sh

   # run this line after resync
   wget https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go && mv main.go build/soong/cmd/soong_build/

   echo "Fix for smth already defined" 
   if [ -d "system/core/trusty/storage/interface" ]; then
      echo "Folder system/core/trusty/storage/interface exists."
      rm -rf system/core/trusty/storage/interface
   else
      echo "Folder system/core/trusty/storage/interface does not exist."
   fi
  
   if [ -d "system/extras/memory_replay" ]; then
      echo "Folder system/extras/memory_replay exists."
      rm -rf system/extras/memory_replay
   else
      echo "Folder system/extras/memory_replay does not exist."
   fi
   
   export curDir=`pwd` 
   
   if [ "$twice" = "no" ]; then
       # signing key
       cd vendor/voltage-priv/keys
       ./keys.sh
        cd $curDir
   fi
   
   rm -f hardware/qcom/sm7250/Android.bp hardware/qcom/sm7250/Android.mk
   rm -f hardware/qcom/sdm845/Android.bp hardware/qcom/sdm845/Android.mk
   rm -f hardware/qcom/sm8150/Android.bp hardware/qcom/sm8150/Android.mk
   
   
   #cd frameworks/base && git checkout ca94c181d8a23569b8157427d4740154ea529b55 
   #cd $curDir
   #cd packages/apps/Settings && git checkout 6205287aa09f078fba8a9f03b6fa32d4d9c1f79e
   #cd $curDir
   #wget https://github.com/VoltageOS/bionic/raw/0c133d2f44e0cb6244509a817fc52f7178da39d4/libc/bionic/custom_rom_hide.cpp && mv custom_rom_hide.cpp bionic/libc/bionic/
   ##wget https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/voltage.devices && mv voltage.devices vendor/voltage/
   #cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir
   #cd kernel/xiaomi/fog &&	rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy_susfs && cd $curDir
   #if [ ! -f kernel/xiaomi/fog/arch/arm64/configs/vendor/fog-perf_defconfig ]; then
   rm -rf kernel/xiaomi/fog && git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog
   #fi
   
   if [ ! -f script_sch2.sh ]; then
      wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
   fi
   . script_sch2.sh
fi

#cat /proc/meminfo
export PACKAGE_NAME="voltage"
# rm -rf out/target/product/fog/system/etc/vintf
# fix for error Problems processing genfscon rules
# https://github.com/LineageOS/android_device_qcom_sepolicy_vndr/blob/lineage-22.2-legacy-um/generic/vendor/common/init_shell.te
#fldr="device/qcom/sepolicy_vndr/legacy-um/generic/vendor/common/"
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/file.te && mv file.te $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/genfs_contexts && mv genfs_contexts $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/init_shell.te && mv init_shell.te $fldr

#Fix for error redeclaration and unresolved maybe this is cuased by undeleted file form base rom lin 22.1 
#rm frameworks/base/packages/SystemUI/plugin_core/src/com/android/systemui/plugins/*.java
#rm -rf frameworks/base/packages/SystemUI/plugin_core/src/com/android/systemui/plugins/processor

#CONFIG_CFI_CLANG or PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false
# Revert android_device.go to original VoltageOS version
#wget -O android_device.go https://github.com/VoltageOS/build_soong/raw/refs/heads/17/filesystem/android_device.go && mv android_device.go build/soong/filesystem/
#export once="yes"
export once="no"
if [ "$once" = "yes" ]; then
   echo "PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false" >> device/xiaomi/fog/device.mk
fi   
#rm -rf out/target/product/fog/obj/PACKAGING/check_vintf_all_intermediates
#change
#rm -rf kernel/xiaomi/fog && git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog
#wget https://github.com/SourceLab081/device_fog/raw/refs/heads/17-vos/BoardConfig.mk && mv BoardConfig.mk device/xiaomi/fog/
#wget https://github.com/SourceLab081/device_fog/raw/refs/heads/17-vos/voltage_fog.mk && mv voltage_fog.mk device/xiaomi/fog/
#wget https://github.com/SourceLab081/device_fog/raw/refs/heads/17-vos/device.mk && mv device.mk device/xiaomi/fog/

echo "LOAD ENVIRONMENT envsetup.sh"
source build/envsetup.sh


# Eksekusi Build
echo "=== Memulai Kompilasi Biner Utama ==="
make installclean
brunch fog

