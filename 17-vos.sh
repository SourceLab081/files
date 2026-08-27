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
#coz error berfore soong process
#rm -rf out/soong/.bootstrap out/soong/build.*.ninja out/soong/soong.environment.*


# rm -rf out/target/product/fog/system/etc/vintf
# fix for error Problems processing genfscon rules
# https://github.com/LineageOS/android_device_qcom_sepolicy_vndr/blob/lineage-22.2-legacy-um/generic/vendor/common/init_shell.te
#fldr="device/qcom/sepolicy_vndr/legacy-um/generic/vendor/common/"
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/file.te && mv file.te $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/genfs_contexts && mv genfs_contexts $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/init_shell.te && mv init_shell.te $fldr
# 1. PASANG PEMBATASAN RAM SECARA KETAT & PERMANEN (TIDAK DI-UNSET)
# 1. BERSIHKAN CACHE SOONG SECARA TOTAL (Hasil kompilasi C++ di out/target/ TETAP UTUH!)
#rm -rf out/soong

# 2. KONFIGURASI RAM & MATIKAN INCREMENTAL SOONG
#export SOONG_INCREMENTAL_ANALYSIS=false

# =======================================================
# 1. GO RUNTIME & SOONG CONFIGURATION (40 GB LIMIT)
# =======================================================
# Following the commit logic in main.go (40 GB RAM & 25% GC)
export GOMEMLIMIT=40GiB
export GOGC=25

# Prevent sudden RAM spikes during Soong analysis
export GOMAXPROCS=4
export SOONG_BUILD_MAX_PARALLEL_THREADS=2

# =======================================================
# 2. JAVA / KOTLINC MEMORY LIMIT CONFIGURATION
# =======================================================
# Lock the Java Heap so it does not exceed 16 GB
export _JAVA_OPTIONS="-Xms4g -Xmx16g -XX:+UseG1GC"

# =======================================================
# 3. DISABLE EXCESSIVE RAM LOAD OPTIONS (UNSET)
# =======================================================
unset SOONG_SPLIT_ALL_VARIANTS
unset SOONG_ENFORCE_NO_REANALYSIS
#2. LOAD ENVIRONMENT & LUNCH VOLTAGEOS
echo "LOAD ENVIRONMENT envsetup.sh"
source build/envsetup.sh

# Ganti 'fog' dengan codename device kamu jika berbeda
#lunch voltage_fog-cp2a-user   # Atau: lunch lineage_fog-ap3a-userdebug / lunch voltage_fog-userdebug

# 3. FASE PEMANASAN SOONG (Toleransi Error Pertama VoltageOS)
#echo "=== Phase 1: Membangun Soong Build Graph (VoltageOS Fix) ==="
#m nothing || m nothing

# 4. KOMPILASI UTAMA
echo "=== Memulai Kompilasi Biner Utama ==="
#mka bacon -j$(nproc --all) 
brunch fog
#export ANDROID_RAM_OPTIMIZE_THROTTLE=true

#coz continue build
#rm -rf out/soong/.intermediates/device/xiaomi/fog/rro_overlays/FogFrameworksOverlayCommon/
# Hapus file state/cache Ninja & Soong yang setengah jadi
#rm -f out/.ninja_deps out/.ninja_log out/soong/build.ninja


#export ALLOW_MISSING_DEPENDENCIES=true 
#export SELINUX_IGNORE_NEVERALLOWS=true
#echo "breakfast/lunch"
#lunch yaap_fog-userdebug
#lunch aosp_fog-bp2a-userdebug
#breakfast fog eng

#lunch voltage_fog-cp2a-user

#brunch fog
#echo success > result.txt
#brunch fog
#echo "build the code"
#m yaap
#mka clover -j$(nproc --all)
