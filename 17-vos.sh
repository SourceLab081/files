export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss

echo "memory:"
free -h
echo "cores:"
nproc --all

echo "update=$update"

export first="yes"
if [ -d "out" ]; then
   $first="no"    
fi

export curDir=`pwd` 

#temporary no
if [[ "$first" = "yes" || "$update" = "yes" ]]; then
   
   if [ "$first" = "yes" ]; then
      #COZ error redeclaration and unresolved on folder   frameworks/base/
      rm -rf frameworks/base
   fi
   # rm -rf device/xiaomi/fog
   
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
   
   if [ "$first" = "yes" ]; then
       # signing key
       cd vendor/voltage-priv/keys
       ./keys.sh
        cd $curDir
   fi
   
   rm -f hardware/qcom/sm7250/Android.bp hardware/qcom/sm7250/Android.mk
   rm -f hardware/qcom/sdm845/Android.bp hardware/qcom/sdm845/Android.mk
   rm -f hardware/qcom/sm8150/Android.bp hardware/qcom/sm8150/Android.mk
   
   #cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir
   #cd kernel/xiaomi/fog &&	rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy_susfs && cd $curDir
   if [ ! -f kernel/xiaomi/fog/arch/arm64/configs/vendor/fog-perf_defconfig ]; then
      #rm -rf kernel/xiaomi/fog && 
      git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog
   fi
   
   if [ ! -f script_sch2.sh ]; then
      wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
   fi
   . script_sch2.sh
fi

#cat /proc/meminfo
export PACKAGE_NAME="voltage"

#Fix for error redeclaration and unresolved maybe this is cuased by undeleted file form base rom lin 22.1 
#rm frameworks/base/packages/SystemUI/plugin_core/src/com/android/systemui/plugins/*.java
#rm -rf frameworks/base/packages/SystemUI/plugin_core/src/com/android/systemui/plugins/processor

#CONFIG_CFI_CLANG or PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false
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

