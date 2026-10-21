#ROM="ASCP"
DEV="fog"
VARIANT="user"
Fix_Killed_AtSoong="no"
Fix_Killed_AtCompiling="no"
usingPixelSepolicy="no"
#echo "Variables ROM=$ROM and update=$update"
#if [ ! -f general.sh ]; then
   curl -LO https://github.com/SourceLab081/files/raw/refs/heads/main/general2.sh
#fi

. general2.sh

job_start

#temporary no
if [[ "$first" = "yes" || "$update" = "yes" ]]; then
   

   #rm -rf kernel/xiaomi/fog
   #rm -rf device/xiaomi/fog vendor/xiaomi/fog
      
   source_repo
   
   repo_sync_crave 

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
   
   cmd_before_envsetup  
fi

if [[ "$ROM" = "PenguinOS" || "$ROM" = "PenguinOS_Next" ]]; then
   #If you want to view the rom-build.sh file ,  according to https://github.com/Project-PenguinOS/manifest ,
   #go to https://github.com/Project-PenguinOS/android_vendor_aospa/blob/celerity/build.sh
   export TARGET_DISABLES_GMS=true
   #export TARGET_USES_NQ_NFC=false
   #export TARGET_USES_ST_NFC=false
   ./rom-build.sh $DEV   
else
   build_start
   run_build
fi

build_finish
