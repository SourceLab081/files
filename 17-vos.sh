export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss

echo "memory:"
free -h
echo "cores:"
nproc --all

#rm -rf device/xiaomi/fog
#rm -rf device/xiaomi/fog-kernel
#export update="no"
#touch rm_soong
echo "update=$update"

if [ "$update" = "yes" ]; then
   repo init -u https://github.com/VoltageOS/manifest.git --depth 1 -b 17 --git-lfs
   rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 17-VoltageOS .repo/local_manifests

   echo "repo sync"
   /opt/crave/resync.sh
   # signing key
   export curDir=`pwd`
   cd vendor/voltage-priv/keys
   ./keys.sh
   cd $curDir
   
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
   if [ ! -f kernel/xiaomi/fog/arch/arm64/configs/vendor/fog-perf_defconfig ]; then
       git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog
   fi
   
   if [ ! -f script_sch2.sh ]; then
      wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
   fi
   . script_sch2.sh
fi

#cat /proc/meminfo
export PACKAGE_NAME="voltage"
#coz error in soong process
rm -rf out/soong/.bootstrap \
       out/soong/.minibp \
       out/soong/.intermediates/bionic/ \
       out/soong/build.*.ninja \
       out/soong/soong.*.variables \
       out/.module_paths/


# rm -rf out/target/product/fog/system/etc/vintf
# fix for error Problems processing genfscon rules
# https://github.com/LineageOS/android_device_qcom_sepolicy_vndr/blob/lineage-22.2-legacy-um/generic/vendor/common/init_shell.te
#fldr="device/qcom/sepolicy_vndr/legacy-um/generic/vendor/common/"
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/file.te && mv file.te $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/genfs_contexts && mv genfs_contexts $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/init_shell.te && mv init_shell.te $fldr
echo "envsetup.sh"

. build/envsetup.sh
#export ALLOW_MISSING_DEPENDENCIES=true 
#export SELINUX_IGNORE_NEVERALLOWS=true
#echo "breakfast/lunch"
#lunch yaap_fog-userdebug
#lunch aosp_fog-bp2a-userdebug
#breakfast fog eng

lunch voltage_fog-cp2a-user
mka installclean

echo "Build $PACKAGE_NAME starting soong."

# 1. PASANG PEMBATASAN RAM SECARA KETAT & PERMANEN (TIDAK DI-UNSET)
export GOMEMLIMIT=32GiB          
export GOGC=30                   
export GOMAXPROCS=4              
export SOONG_BUILD_MAX_PARALLEL_THREADS=4

export _JAVA_OPTIONS="-Xmx8g -XX:+UseG1GC" # Rem untuk Java
export USE_CCACHE=0
export ANDROID_RAM_OPTIMIZE_THROTTLE=true
export DISABLE_LTO=true
export USE_CLANG_LLD=true

#m nothing

# JANGAN UNSET GOGC! Biarkan GOGC=20 agar Soong tidak makan RAM saat kompilasi C++
#export GOMEMLIMIT=14GiB
 

# 3. EKSEKUSI KOMPILASI UTAMA
echo "Starting main compilation (mka bacon)..."
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS=false mka bacon -j$(nproc --all)

#echo success > result.txt
#brunch fog
#echo "build the code"
#m yaap
#mka clover -j$(nproc --all)
