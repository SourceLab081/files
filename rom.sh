#ROM="ASCP"
DEV="fog"
VARIANT="user"

echo "Variables ROM=$ROM and update=$update"
#if [ ! -f general.sh ]; then
   wget -O general.sh https://github.com/SourceLab081/files/raw/refs/heads/main/general.sh
#fi

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
   repo sync -c -j$(nproc --all) --force-sync --force-remove-dirty --no-clone-bundle --no-tags
   repo_sync_crave 

   source .var
   if [ "$ROM" = "Shinkai" ]; then
      echo "To get permission to access android_vendor_shinkai, send a private message with your GitHub username to https://t.me/khayloaf or https://t.me/Mnskkyy"
      wget -O vendor_shinkai.tar.gz.gpg https://github.com/SourceLab081/uploadz/releases/download/v0.2.5/vendor_shinkai.tar.gz.gpg
      gpg --batch --quiet --yes --passphrase "$PASS_GPG" -d vendor_shinkai.tar.gz.gpg | tar -xzf - -C vendor/
   fi
   
   # Fix for the “memory stall” error when building Soong
   wget https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go && mv main.go build/soong/cmd/soong_build/
   
   # Fixes for “memory stall” errors that occur when compiling code in framework/base if the compilation process continues
   #wget -O droidstubs.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/droidstubs.go && mv droidstubs.go build/soong/java/
   #wget -O config.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/config.go && mv config.go build/soong/java/config/
   #wget -O kotlin.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/kotlin.go && mv kotlin.go build/soong/java/config/
   
   # Hapus hanya cache hasil output metalava/stubs
   #rm -rf out/target/common/obj/JAVA_LIBRARIES/*_intermediates/
   #rm -rf out/soong/.minibp*
   # Hapus manifest Ninja agar aturan dari config.go diperbarui tanpa menghapus hasil compile yang lama
   #rm -f out/soong/build.ninja
   
   #after error : build/soong/fsgen/Android.bp:41:1: module "shinkai_fog_generated_system_other_image"
   #rm -rf out/soong/fsgen
   #rm -rf out/soong/build.shinkai_fog.ninja 
   #rm -rf out/soong/.soong.*
   
   cmd_before_envsetup  
fi

build_start

run_build

build_finish
