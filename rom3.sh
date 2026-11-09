#!/bin/bash
#ROM="ASCP"
if [[ -z "$ROM" ]]; then
   update=$1
   ROM=$2
   circleci=$3
fi

DEV="fog"
VARIANT="user"
Fix_Killed_AtSoong="no"
Fix_Killed_AtCompiling="no"
usingPixelSepolicy="no"
#echo "Variables ROM=$ROM and update=$update"
#if [ ! -f general.sh ]; then
   #curl -LO https://github.com/SourceLab081/files/raw/refs/heads/main/general2.sh
#fi
#curl -fL --retry 5 -o general2.sh "https://github.com/SourceLab081/files/raw/refs/heads/main/general2.sh"
wget -O general2.sh https://github.com/SourceLab081/files/raw/refs/heads/main/general2.sh
. general2.sh

job_start

#temporary no
if [[ "$first" = "yes" || "$update" = "yes" ]]; then
   

   #rm -rf kernel/xiaomi/fog
   #rm -rf device/xiaomi/fog vendor/xiaomi/fog
   if [ "$circleci" = "yes" ]; then
      df -h
      Fix_Killed_AtSoong="yes"
      Fix_Killed_AtCompiling="yes"
      # 1. Tentukan direktori kerja utama AOSP dan direktori target di /var/lib/docker
AOSP_ROOT="$(pwd)"
DOCKER_STORAGE="/var/lib/docker/aosp_offload"

echo "=== Mengalokasikan folder ke /var/lib/docker ==="
sudo mkdir -p "$DOCKER_STORAGE/out"
sudo mkdir -p "$DOCKER_STORAGE/prebuilts"
sudo mkdir -p "$DOCKER_STORAGE/vendor"

sudo chown circleci:circleci "$DOCKER_STORAGE/prebuilts"
sudo chown circleci:circleci "$DOCKER_STORAGE/vendor"
sudo chown circleci:circleci "$DOCKER_STORAGE/out"
# 2. Set variabel lingkungan AOSP native untuk memindahkan folder out/
export OUT_DIR="$DOCKER_STORAGE/out"
mkdir -p "$AOSP_ROOT/prebuilts"
mkdir -p "$AOSP_ROOT/vendor"
# 3. Buat symlink untuk folder prebuilts dan vendor sebelum repo sync
sudo mount --bind "$DOCKER_STORAGE/prebuilts" "$AOSP_ROOT/prebuilts"
sudo mount --bind "$DOCKER_STORAGE/vendor" "$AOSP_ROOT/vendor"

echo "=== Verifikasi Symlink ==="
ls -la "$AOSP_ROOT/prebuilts" "$AOSP_ROOT/vendor"
df -h / /var/lib/docker
   fi
   
   source_repo
   
   repo_sync_crave 

   cmd_before_envsetup 

   for_PenguinOS2
   for_PenguinOS    
   for_HertzifyOS
   for_shinkai
   
   #df -h 
   if [ "$Fix_Killed_AtSoong" = "yes" ]; then
      # Fix for the "killed" error because "memory stall" when building Soong
      #wget https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go && mv main.go build/soong/cmd/soong_build/
      curl_cp "https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go" "main.go" "build/soong/cmd/soong_build/"
   fi 

   if [ "$Fix_Killed_AtCompiling" = "yes" ]; then
       # Fixes for "killed" errors becaues "memory stall" that occur when compiling code in framework/base if the compilation process continues 
       curl_cp "https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/droidstubs.go" "droidstubs.go" "build/soong/java/"
       curl_cp "https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/config.go" "config.go" "build/soong/java/config/"
       curl_cp "https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/kotlin.go" "kotlin.go" "build/soong/java/config/"
   fi
    
fi

if [[ "$ROM" = "PenguinOS" || "$ROM" = "PenguinOS_Next" || "$ROM" = "AOSPA" ]]; then
   #If you want to view the rom-build.sh file ,  according to https://github.com/Project-PenguinOS/manifest ,
   #go to https://github.com/Project-PenguinOS/android_vendor_aospa/blob/celerity/build.sh
   #export TARGET_DISABLES_GMS=true
   #export TARGET_USES_NQ_NFC=false
   #export TARGET_USES_ST_NFC=false
   if [ "$circleci" = "yes" ]; then
      df -h 
      VARIANT=userdebug
      source build/envsetup.sh
      # Set batas memori Go (Soong) ke 4GB agar aman di RAM 8GB
      export GOMEMLIMIT=4GiB
      export GOGC=20

      # Batasi thread Soong & Linker ke 2 job saja
      #export SOONG_UI_NUM_JOBS=2
      #export SOONG_MAX_LINK_JOBS=1

      # Batasi Java / Metalava
       export _JAVA_OPTIONS="-Xmx3g"
       #export SOONG_UI_NUM_JOBS=4
       #export SOONG_MAX_LINK_JOBS=1
       
       lunch aospa_$DEV-cp2a-$VARIANT
       df -h /var/lib/docker
       m -j4 bacon
   else
      ./rom-build.sh $DEV
   fi
else
   build_start
   run_build
fi

build_finish
