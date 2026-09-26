export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss


# -----------------------------
# Colors
# -----------------------------
RESET='\033[0m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
BOLD='\033[1m'


info() {
    echo -e "${BLUE}ℹ ${RESET}$1"
}

ok() {
    echo -e "${GREEN}✔ ${RESET}$1"
}

warn() {
    echo -e "${YELLOW}⚠ ${RESET}$1"
}

fail() {
    echo -e "${RED}✖ ${RESET}$1"
}

job_start() {
    JOB_START=$(date +%s)

    echo "memory:"
    free -h
    echo "cores:"
    nproc --all
    
    echo "update=$update"
    export first="yes"
    
    if [ -d "out" ]; then
       first="no"    
    fi
    echo "first=$first" 
    export curDir=`pwd` 
    echo "current directory=$curDir"
    
    if [[ -f ".var" ]]; then
       source ".var"
       ok ".var loaded"
    else
       warn ".var not found - continuing"
    fi
}

local_manifest="https://github.com/SourceLab081/local_manifests"

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


repo_sync_crave() {
    info "Syncing Source using resync.sh from crave.io"
    SYNC_START=$(date +%s)
    /opt/crave/resync.sh
    ok "Source sync stage finished"
    info "Sync time: $(((SYNC_END - SYNC_START) / 60)) minutes" 
}

repo_sync_custom() {
    info "Syncing Source using custom options"
    SYNC_START=$(date +%s)
    repo sync \    
        -c \
        -j$(nproc --all) \
        --force-sync \
        --force-remove-dirty \
        --no-tags \
        --no-clone-bundle \
        || {
            warn "Forced repo sync returned an error"
            warn "Continuing build anyway..."
        }
    ok "Source sync stage finished"
    info "Sync time: $(((SYNC_END - SYNC_START) / 60)) minutes" 
}

cmd_before_envsetup() { 	
   info "These commands are executed immediately after repo sync"
   
   rm -rf hardware/google/pixel/kernel_headers/Android.bp
   
   rm -f hardware/qcom/sm7250/Android.bp hardware/qcom/sm7250/Android.mk
   rm -f hardware/qcom/sdm845/Android.bp hardware/qcom/sdm845/Android.mk
   rm -f hardware/qcom/sm8150/Android.bp hardware/qcom/sm8150/Android.mk
   
   if [ ! -f kernel/xiaomi/fog/arch/arm64/configs/vendor/fog-perf_defconfig ]; then
      #rm -rf kernel/xiaomi/fog && 
      info "Clone the kernel" 
      git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog
   fi

   # signing key
   if [ ! -d vendor/extra ]; then
       mkdir -p vendor/extra
       cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
       cd ../..
   fi

   if [ ! -f script_sch2.sh ]; then
      wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
   fi
   . script_sch2.sh
}

build_start() {
   source build/envsetup.sh
   BUILD_START=$(date +%s)
   info "Build start at $BUILD_START"
}

upload_file() {
    # Get the file size in bytes
    FILE_SIZE=$(stat -c%s "$ZIP_FILE")
    
    # Size limit of 2000M in bytes (2000 * 1024 * 1024)
    MAX_SIZE=$((2000 * 1024 * 1024))
    
    echo "File size of ‘$ZIP_FILE’: $FILE_SIZE bytes"
    
    if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
       echo "The file size exceeds 2000MB. Starting the split process..."
       
       # Run the split command with a numerical suffix for easy identification
       # This command will generate files such as: filename.zip.part00, filename.zip.part01, etc.
       split -b 2000M -d -a 2 "$ZIP_FILE" "${ZIP_FILE}.part"
    
       # Detect and store the list of split files in an array
       SPLIT_FILES=("${ZIP_FILE}.part"*)
       TOTAL_FILES=${#SPLIT_FILES[@]}
    
       echo "Finished splitting the file. Total number of files created: $TOTAL_FILES"
       echo "----------------------------------------"
    
       # Loop to upload each split file
       COUNT=1
       for FILE in "${SPLIT_FILES[@]}"; do
          echo "Uploading file ($COUNT/$TOTAL_FILES): $FILE"
          . send_file.sh "$FILE" "$FILE"
          COUNT=$((COUNT + 1))
       done
    else
       echo "The file size is less than or equal to 2000MB. Uploading the file directly..."
       . send_file.sh "$ZIP_FILE" "$ZIP_FILE" 
    fi
}

Get_GHRelease() {
   if [ ! -f github-release ]; then
      wget https://github.com/github-release/github-release/releases/download/v0.10.0/linux-amd64-github-release.bz2&&bunzip2 \
      linux-amd64-github-release.bz2&&mv linux-amd64-github-release github-release && chmod +x github-release
   fi
   
   if [ ! -f send_file.sh ]; then
      echo './github-release upload \
      -s $secret_num \
      -u SourceLab081 \
      -r uploadz \
      -t $tag \
      -n $1 \
      -f $2' > send_file.sh
    fi

}

build_finish() {
    info "End process"
    BUILD_END=$(date +%s)
    BUILD_MINUTES=$(((BUILD_END - BUILD_START) / 60))

    if [[ -f ".var" ]]; then
       source ".var"
       ok ".var loaded"
       else
       warn ".var not found - continuing"
    fi

    if [[ "${BUILD_SUCCESS}" == "1" ]]; then
       ok "$ROM build successful"
       info "Build time: ${BUILD_MINUTES} minutes"
       cd out/target/product/$DEV
       Get_GHRelease
       if [[ -n "$secret_num" ]]; then
          ZIP_FILE=$(find . -maxdepth 1 -type f -name "*.zip"  ! -name "*target_files*" ! -name "*ota*" \
          -printf '%T@ %f\n' | sort -nr | head -n 1 | cut -d' ' -f2-)
       
          info "Upload $ZIP_FILE to github"
          #. send_file.sh $ZIP_FILE
          upload_file
       fi
    else
       fail "$ROM build failed"
       if [[ -n "$secret_num" ]]; then
          Get_GHRelease
          DATE_LOG=$(date +%s)
          . send_file.sh  error-"$DATE_LOG".log out/error.log
       fi
       info "Build time: ${BUILD_MINUTES} minutes"
       exit 1
    fi

    JOB_END=$(date +%s)
    TOTAL_MINUTES=$(((JOB_END - JOB_START) / 60))

    info "Job Complete"
    ok "Everything finished"

}
