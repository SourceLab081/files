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
   
   if [ "$first" = "yes" ]; then
      #COZ error redeclaration and unresolved on folder   frameworks/base/
      #rm -rf frameworks/base
      rm -rf device/qcom/sepolicy_vndr
   fi
   
   if [ "$ROM" = "PenguinOS" ]; then
      #3. Fix for error error: system/libhidl/vintfdata/Android.bp:47:1 . But in PenguinOS from Commit c10c4a5 manifest: Unfork system/libhidl
      #So this error is caused by the presence of the system/libhidl folder from the LOS 23.2 base repository, which must be deleted
      rm -rf system/libhidl
   fi
   
   #rm -rf kernel/xiaomi/fog
   #rm -rf device/xiaomi/fog vendor/xiaomi/fog
      
   source_repo
   
   repo_sync_crave 
   
   if [ "$first" = "yes" ]; then
      repo sync -c -j$(nproc --all) --force-sync --force-remove-dirty --no-clone-bundle --no-tags
      repo_sync_crave 
   fi

   if [ "$ROM" = "PenguinOS" ]; then
      #1. Fix for error: device/qcom/sepolicy_vndr/SEPolicy.mk: No such file or directory
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
         git clone --depth 1 https://github.com/AOSPA/android_device_qcom_sepolicy_vndr -b calcite "$TARGET_DIR"
         # Verify the cloning result
         if [ -f "$TARGET_FILE" ]; then
            echo "✓ Success! SEPolicy.mk is now available."
         else
            echo "x Failure: The repository was successfully cloned, but SEPolicy.mk is still missing."
         fi
      fi

      #2. Fix for error "libqti-perfd-client_system" depends on undefined module "vendor.qti.hardware.perf@2.2" and ..."vendor.qti.hardware.perf@2.3"
      SRC=bckp_/android_vendor_aospa-calcite/interfaces/qcom
      DST=vendor/aospa/interfaces/qcom
      
      if [ ! -f "$DST/perf/2.3/Android.bp" ]; then
         mkdir bckp_
         curl -LO https://github.com/AOSPA/android_vendor_aospa/archive/refs/heads/calcite.zip
         unzip calcite.zip -d bckp_/
         cp -a "$SRC/perf" "$DST/"
         if ! grep -Fq 'ca3830177c6813da7219ffa8fd4bf2ffc161f9d10bcbb08b334a93838974f852 vendor.qti.hardware.perf@2.3::IPerf' "$DST/current.txt"; then
            cat >> "$DST/current.txt" <<'EOF'

## perf
3b62e5f205de632f6c1d6b46d01a2945b5a855ec4a98247515ce8d14b51a4fa5 vendor.qti.hardware.perf@1.0::IPerf
517008020b188864935535fa5c9ab30c686d01a4e7559659658d61b78fcd7cd1 vendor.qti.hardware.perf@2.0::IPerf
429bbf6c78faecc882e6d39ea05329be9519b3ae547448ec3cc5c2393b918740 vendor.qti.hardware.perf@2.1::IPerf
d5308ed1c730c17c0ae57de676255eb68f48846b5e976fccc1b046755e015a2e vendor.qti.hardware.perf@2.1::IPerfCallback
dd76694de5ef346703b450dc96e6c96e274caacb52fba60ad52cb69352467040 vendor.qti.hardware.perf@2.2::IPerf
ca3830177c6813da7219ffa8fd4bf2ffc161f9d10bcbb08b334a93838974f852 vendor.qti.hardware.perf@2.3::IPerf
EOF
         fi
         rm -rf bckp_/android_vendor_aospa-calcite calcite.zip
      else 
         echo "✓ $DST/perf/2.3/Android.bp file found. No action required."
      fi
      
   fi
   
   for_HertzifyOS
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

if [ "$ROM" = "PenguinOS" ]; then
   #If you want to view the rom-build.sh file ,  according to https://github.com/Project-PenguinOS/manifest ,
   #go to https://github.com/Project-PenguinOS/android_vendor_aospa/blob/celerity/build.sh
   export TARGET_DISABLES_GMS=true
   export TARGET_USES_NQ_NFC=false
   export TARGET_USES_ST_NFC=false
   ./rom-build.sh $DEV   
else
   build_start
   run_build
fi

build_finish
