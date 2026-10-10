#ROM="ASCP"
DEV="fog"
VARIANT="userdebug"
Fix_Killed_AtSoong="yes"
Fix_Killed_AtCompiling="yes"
usingPixelSepolicy="no"
#echo "Variables ROM=$ROM and update=$update"
#if [ ! -f general.sh ]; then
   curl -LO https://github.com/SourceLab081/files/raw/refs/heads/main/general.sh
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
   rm -rf packages/apps/PenguinSetupWizard  packages/apps/Updater
   
   source_repo
   
   repo_sync_crave 
   
   if [ "$first" = "yes" ]; then
      repo sync -c -j$(nproc --all) --force-sync --force-remove-dirty --no-clone-bundle --no-tags
      repo_sync_crave 
   fi
   
   if [ "$ROM" = "PenguinOS2" ]; then
      TARGET_FILE="vendor/penguin/config/penguin.mk"
      # 1. Changing PenguinSetupWizard to SetupWizard
      sed -i 's/\bPenguinSetupWizard\b/SetupWizard/g' "$TARGET_FILE"
      # 2. Delete ONLY the rows that contain only 'Updater \'
      sed -i '/^[[:space:]]*Updater[[:space:]]*\\$/d' "$TARGET_FILE"

      TARGET_FILE="device/qcom/sepolicy_vndr/SEPolicy.mk"
      TARGET_DIR="device/qcom/sepolicy_vndr"
      
      echo "Checking for $TARGET_FILE..."
      if [ -f "$TARGET_FILE" ]; then
         echo "✓ SEPolicy.mk file found. No action required."
      else
         echo "x SEPolicy.mk file NOT found!"
         # Check if the directory already exists or contains corrupted files or old .git files
         if [ -d "$TARGET_DIR" ]; then
            echo "Cleaning up the old $TARGET_DIR directory..."
            rm -rf "$TARGET_DIR"
         fi
      
         echo "Cloning the sepolicy_vndr repository..."
         git clone --depth 1 https://github.com/stx-staging/android_device_qcom_sepolicy_vndr -b cb "$TARGET_DIR"
         # Verify the cloning result
         if [ -f "$TARGET_FILE" ]; then
            echo "✓ Success! SEPolicy.mk is now available."
         else
         echo "x Failure: The repository was successfully cloned, but SEPolicy.mk is still missing."
         #exit 1
         fi
      fi
   
   fi
   
   if [ "$usingPixelSepolicy" = "yes" ]; then
      F=hardware/google/pixel-sepolicy/power-libperfmgr/hal_power_default.te
      # Hapus HANYA baris hardware Tensor-specific, bukan seluruh file
      if ! grep -q "^#.*latency_device" "$F"; then
         sed -i '/latency_device/s/^/#/' "$F"
      fi
      if ! grep -q "^#.*unix_socket_connect(hal_power_default, pps," "$F"; then
         sed -i '/unix_socket_connect(hal_power_default, pps,/s/^/#/' "$F"
      fi
      if ! grep -q "^#.*proc_vendor_sched" "$F"; then
         sed -i '/proc_vendor_sched/s/^/#/' "$F"
      fi
      if ! grep -q "^#.*thermal_link_device" "$F"; then
         sed -i '/thermal_link_device/s/^/#/' "$F"
      fi
      # Fix for error Multiple different specifications for /dev/...
      F=hardware/google/pixel-sepolicy/power-libperfmgr/file_contexts
      if ! grep -q "^#.*cpu_dma_latency" "$F"; then
         sed -i '\|/dev/cpu_dma_latency|s/^/#/' "$F"
      fi
      if ! grep -q "^#.*dev/socket/pps" "$F"; then
         sed -i '\|/dev/socket/pps|s/^/#/' "$F"
      fi
      #Temporary
      #F=build/soong/ui/build/androidmk_denylist.go
      #if ! grep -q "packages/apps/HertzifySettings/Android.mk" "$F"; then
      #   sed -i '/"bootable\/deprecated-ota\/updater\/Android.mk",/a\	"packages/apps/HertzifySettings/Android.mk",' "$F"
      #fi
      #sed -i 's/^"packages\/apps\/HertzifySettings\/Android.mk",/\t"packages\/apps\/HertzifySettings\/Android.mk",/' build/soong/ui/build/androidmk_denylist.go
   fi 
   
   for_shinkai
   
   df -h 
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
   
   cmd_before_envsetup  
fi

build_start

run_build

build_finish
