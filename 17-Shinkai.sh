ROM="RisingOS"
DEV="fog"
VARIANT="user"

source_repo() {
   repo init --depth=1 -u https://github.com/ShinkaiProject/shinkai_manifest.git -b heptakaideka --git-lfs  
   rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 17-Shinkai .repo/local_manifests
}

run_build() {
   breakfast "$DEV" "$VARIANT"
   make installclean
   
   if mka shinkai; then
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
