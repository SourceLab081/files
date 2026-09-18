ROM="ASCP"
DEV="fog"
VARIANT="user"
local_manifest=" https://github.com/SourceLab081/local_manifests"

case $ROM in

  Shinkai)
    echo "Shinkai"
    repo_url="https://github.com/ShinkaiProject/shinkai_manifest.git"
    repo_branch="heptakaideka"
    manifest_branch="17-Shinkai"
    l_cmd="breakfast "$DEV" "$VARIANT""
    BUILD_CMD="mka shinkai"
    ;;

  ASCP)
    echo "ASCP"
    repo_url="https://github.com/Pixelify-AOSP/platform_manifest"
    repo_branch="17"
    manifest_branch="17-los"
    l_cmd="lunch $DEV-cp2a-$VARIANT"
    BUILD_CMD="mka bacon"
    ;;

  VoltageOS)
    echo "VoltageOS"
    repo_url="https://github.com/VoltageOS/manifest.git"
    repo_branch="17"
    manifest_branch="17-VoltageOS"
    l_cmd=""
    BUILD_CMD="brunch fog"
    ;;

  *)
    echo "unknown"
    ;;
esac

source_repo() {
   repo init --depth=1 -u "$repo_url" -b "$repo_branch" --git-lfs  
   rm -rf .repo/local_manifests && git clone --depth 1  "$local_manifest" -b "$manifest_branch" .repo/local_manifests
}

run_build() {
   if [ -n "$l_cmd" ]; then
    $l_cmd
   fi
   
   make installclean
   
   if $BUILD_CMD; then
      BUILD_SUCCESS=1
   else
      BUILD_SUCCESS=0
   fi
}

if [ ! -f general.sh ]; then
   wget -O general.sh https://github.com/SourceLab081/files/raw/refs/heads/main/general.sh
fi

. general.sh

job_start

#temporary no
if [[ "$first" = "yes" || "$update" = "yes" ]]; then
   
   if [ "$first" = "apply" ]; then
      #COZ error redeclaration and unresolved on folder   frameworks/base/
      rm -rf frameworks/base
   fi
     
   source_repo
   
   repo_sync_crave 
   
   repo_sync_crave 
   # Fix for the “memory stall” error when building Soong
   wget https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go && mv main.go build/soong/cmd/soong_build/
   
   # Fixes for errors that occur when compiling code in framework/base if the compilation process continues
   #wget -O droidstubs.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/droidstubs.go && mv droidstubs.go build/soong/java/
   #wget -O config.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/config.go && mv config.go build/soong/java/config/
   #wget -O kotlin.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/kotlin.go && mv kotlin.go build/soong/java/config/
   
   # Hapus hanya cache hasil output metalava/stubs
   #rm -rf out/target/common/obj/JAVA_LIBRARIES/*_intermediates/
   #rm -rf out/soong/.minibp*
   # Hapus manifest Ninja agar aturan dari config.go diperbarui tanpa menghapus hasil compile yang lama
   #rm -f out/soong/build.ninja
   cmd_before_envsetup  
fi

build_start

run_build

build_finish
