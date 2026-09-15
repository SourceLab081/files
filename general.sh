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
   
   rm -f hardware/qcom/sm7250/Android.bp hardware/qcom/sm7250/Android.mk
   rm -f hardware/qcom/sdm845/Android.bp hardware/qcom/sdm845/Android.mk
   rm -f hardware/qcom/sm8150/Android.bp hardware/qcom/sm8150/Android.mk
   
   if [ ! -f kernel/xiaomi/fog/arch/arm64/configs/vendor/fog-perf_defconfig ]; then
      #rm -rf kernel/xiaomi/fog && 
      info "Clone the kernel" 
      git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog
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
          -f $1' > send_file.sh
       fi
       if [[ -n "$secret_num" ]]; then
          ZIP_FILE=$(find . -maxdepth 1 -type f -name "$ROM*.zip" \
          -printf '%T@ %f\n' | sort -nr | head -n 1 | cut -d' ' -f2-)
       
          info "Upload $ZIP_FILE to github"
          . send_file.sh $ZIP_FILE
       fi
    else
       fail "$ROM build failed"
       info "Build time: ${BUILD_MINUTES} minutes"
       exit 1
    fi

    JOB_END=$(date +%s)
    TOTAL_MINUTES=$(((JOB_END - JOB_START) / 60))

    info "Job Complete"
    ok "Everything finished"

}
