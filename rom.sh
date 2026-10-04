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
