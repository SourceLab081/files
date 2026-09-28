#ROM="ASCP"
DEV="fog"
VARIANT="user"

#echo "Variables ROM=$ROM and update=$update"
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
   
   rm -rf device/xiaomi/fog
   
   source_repo
   
   repo_sync_crave 
   
   if [ "$first" = "yes" ]; then
      repo sync -c -j$(nproc --all) --force-sync --force-remove-dirty --no-clone-bundle --no-tags
      repo_sync_crave 
   fi    
   
   if [ "$ROM" = "Shinkai" ]; then
      MK=build/make/core/Makefile
      if grep -F -B1 '# Copying baseline ramdisk' "$MK" | grep -qF 'mkdir -p $(TARGET_ROOT_OUT)'; then
         echo "The patch already exists; skipping it"
      else
         sed -i '/^\t# Copying baseline ramdisk\.\.\./i\\tmkdir -p $(TARGET_ROOT_OUT)' "$MK"
         echo "The patch has been applied"
      fi
      if grep -F -B1 'touch $(TARGET_RECOVERY_ROOT_OUT)/linkerconfig/ld.config.txt' "$MK" | grep -qF 'mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/linkerconfig'; then
         echo "The linkerconfig already exists; skipping it"
      else
         sed -i '/^\ttouch \$(TARGET_RECOVERY_ROOT_OUT)\/linkerconfig\/ld\.config\.txt/i\\tmkdir -p $(TARGET_RECOVERY_ROOT_OUT)/linkerconfig' "$MK"
         echo "The linkerconfig patch has been applied"
      fi
      pushd build/soong
      git fetch --unshallow
      git remote add fiqri https://github.com/fiqri19102002/android_build_soong.git
      git fetch fiqri
      git cherry-pick --allow-empty e16dc96626579b49c2cced67a6b09d5b3a0290fc
      git cherry-pick --allow-empty d6363a4b3c978824d06aebc9cb080202c7c86894
      popd

      if [ ! -f vendor/custom/config/common.mk ]; then
         echo "To get permission to access android_vendor_shinkai, send a private message with your GitHub username to https://t.me/khayloaf or https://t.me/Mnskkyy"
         wget -O vendor_shinkai.tar.gz.gpg https://github.com/SourceLab081/uploadz/releases/download/v0.2.5/vendor_shinkai.tar.gz.gpg
         gpg --batch --quiet --yes --passphrase "$PASS_GPG" -d vendor_shinkai.tar.gz.gpg | tar -xzf - -C vendor/
      else
         echo "file vendor/custom/config/common.mk exists."
      fi
      if [ ! -f packages/apps/LMOFreeform/build.gradle.kts ]; then
         mkdir -p packages/apps/LMOFreeform
         wget -O LMOFreeform.tar.bz2 https://github.com/SourceLab081/uploadz/releases/download/v0.2.5/LMOFreeform.tar.bz2
         tar xjf LMOFreeform.tar.bz2 -C packages/apps/LMOFreeform/   
      else
         echo "file packages/apps/LMOFreeform/build.gradle.kts exists."
      fi
   fi
   
   # Fix for the “killed” error because "memory stall" when building Soong
   wget https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go && mv main.go build/soong/cmd/soong_build/
   
   # Fixes for “killed” errors becaues "memory stall" that occur when compiling code in framework/base if the compilation process continues
   wget -O droidstubs.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/droidstubs.go && mv droidstubs.go build/soong/java/
   wget -O config.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/config.go && mv config.go build/soong/java/config/
   wget -O kotlin.go https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/kotlin.go && mv kotlin.go build/soong/java/config/
   
   cmd_before_envsetup  
fi

build_start

export UNSAFE_DISABLE_HIDDENAPI_FLAGS=true
run_build

build_finish
