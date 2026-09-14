export ROM="rising"
export DEV="fog"

if [ ! -f general.sh ]; then
   wget -O general.sh https://github.com/SourceLab081/files/raw/refs/heads/main/general.sh
fi

. general.sh

job_start

#temporary no
if [[ "$first" = "yes" || "$update" = "yes" ]]; then
   
   if [ "$first" = "yes" ]; then
      #COZ error redeclaration and unresolved on folder   frameworks/base/
      rm -rf frameworks/base
   fi

   echo "Fix for error already defined in RisingOS"
   rm -rf packages/overlays/Lineage
   rm -rf hardware/qcom-caf/msm8998
   #rm -rf hardware/qcom-caf/sdm845
   rm -rf packages/apps/Trebuchet
   rm -rf packages/apps/Nfc
   rm -rf external/rust/crates
   rm -rf external/rust/android-crates-io

   repo init --depth=1 -u https://github.com/RisingOS-Revived/android.git -b seventeen --git-lfs  
   rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 17-rising .repo/local_manifests
   
   repo_sync_crave 
   
   # Fix for the “memory stall” error when building Soong
   wget https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go && mv main.go build/soong/cmd/soong_build/
   
   # Fixes for errors that occur when compiling code in framework/base if the compilation process continues
   #wget -O droidstubs.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/droidstubs.go && mv droidstubs.go build/soong/java/
   #wget -O config.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/config.go && mv config.go build/soong/java/config/
   #wget -O kotlin.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/kotlin.go && mv kotlin.go build/soong/java/config/
   
   echo "Fix for smth already defined"
   mkdir bckp
   if [ -d "system/core/trusty/storage/interface" ]; then
      echo "Folder system/core/trusty/storage/interface exists."
      mv system/core/trusty/storage/interface bckp/
   else
      echo "Folder system/core/trusty/storage/interface does not exist."
   fi
  
   if [ -d "system/extras/memory_replay" ]; then
      echo "Folder system/extras/memory_replay exists."
      mv system/extras/memory_replay bckp/
   else
      echo "Folder system/extras/memory_replay does not exist."
   fi

   cmd_before_envsetup  
fi

# Hapus hanya cache hasil output metalava/stubs
#rm -rf out/target/common/obj/JAVA_LIBRARIES/*_intermediates/
#rm -rf out/soong/.minibp*
# Hapus manifest Ninja agar aturan dari config.go diperbarui tanpa menghapus hasil compile yang lama
#rm -f out/soong/build.ninja

build_start

riseup fog user
make installclean
gk -f #(to regenerate replace old keys, rise sb automatically generate keys for full build signing if no keys exists)

if rise sb; then
    BUILD_SUCCESS=1
else
    BUILD_SUCCESS=0
fi

build_finish
