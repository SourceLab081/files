#ROM="ASCP"
DEV="fog"
VARIANT="user"
Fix_Killed_AtSoong="yes"
Fix_Killed_AtCompiling="yes"

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
   
   source_repo
   
   repo_sync_crave 
   
   if [ "$first" = "yes" ]; then
      repo sync -c -j$(nproc --all) --force-sync --force-remove-dirty --no-clone-bundle --no-tags
      repo_sync_crave 
   fi    
   
   if [ "$ROM" = "HertzifyOS" ]; then
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
   fi 
   
   for_shinkai
   
   df -h 
   if [ "$Fix_Killed_AtSoong" = "yes" ]; then
      # Fix for the “killed” error because "memory stall" when building Soong
      #wget https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go && mv main.go build/soong/cmd/soong_build/
      curl_cp "https://github.com/yaap-17-stone/build_soong/raw/f9c27b0b9298f6eeee9a850346e0a646c3eaeb87/cmd/soong_build/main.go" "main.go" "build/soong/cmd/soong_build/"
   fi 

   if [ "$Fix_Killed_AtCompiling" = "yes" ]; then
       # Fixes for “killed” errors becaues "memory stall" that occur when compiling code in framework/base if the compilation process continues 
       curl_cp "https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/droidstubs.go" "droidstubs.go" "build/soong/java/"
       curl_cp "https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/config.go" "config.go" "build/soong/java/config/"
       curl_cp "https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/kotlin.go" "kotlin.go" "build/soong/java/config/"
   fi
   
   cmd_before_envsetup  
fi

build_start

if [ "$ROM" = "Shinkai" ]; then
   export UNSAFE_DISABLE_HIDDENAPI_FLAGS=true
fi

run_build

build_finish
