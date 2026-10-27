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

curl_cp() {
    #echo "Url address        : $1"
    #echo "File               : $2"
    #echo "Destination folder : $3"
    curl -fLO "$1" && cp "$2" "$3" 
    rm "$2"
}

job_start() {
    JOB_START=$(date +%s)

    ok "memory:"
    free -h
    ok "cores:"
    nproc --all
    ok "cpu:" 
    cat /proc/cpuinfo
    
    echo "update=$update"
    first="yes"
    
    if [ -d "out" ]; then
       first="no"    
    fi
    echo "first=$first" 
    curDir=`pwd` 
    info "current directory=$curDir"
    
    if [[ -f ".var" ]]; then
       source ".var"
       ok ".var loaded"
    else
       warn ".var not found - continuing"
    fi
}

local_manifest="https://github.com/SourceLab081/local_manifests"

case $ROM in
  
  AOSPA)
    echo "Paranoid Android AOSPA"
    kernel_aospa="yes"
    repo_url="https://github.com/AOSPA/manifest"
    repo_branch="calcite"
    manifest_branch="17-AOSPA"
    l_cmd=""
    BUILD_CMD="brunch penguin_$DEV-cp2a-$VARIANT"
    ;;
    
  RisingOS)
    echo "RisingOS"
    repo_url="https://github.com/RisingOS-Revived/android.git"
    repo_branch="seventeen"
    manifest_branch="17-rising"
    l_cmd="riseup $DEV $VARIANT"
    BUILD_CMD="rise b"
    ;;
    
  PenguinOS)
    echo "Project-PenguinOS"
    kernel_aospa="yes"
    repo_url="https://github.com/Project-PenguinOS/manifest"
    repo_branch="celerity"
    manifest_branch="17_Project-PenguinOS"
    l_cmd=""
    BUILD_CMD="brunch penguin_$DEV-cp2a-$VARIANT"
    ;;

  PenguinOS2)
    echo "PenguinOS-AOSP"
    repo_url="https://github.com/PenguinOS-AOSP/android_manifest.git"
    repo_branch="celerity"
    manifest_branch="17-PenguinOS-AOSP"
    l_cmd=""
    BUILD_CMD="brunch penguin_$DEV-cp2a-$VARIANT"
    ;;
    
  HertzifyOS)
    echo "HertzifyOS"
    repo_url="https://github.com/HertzifyOS/android_manifest.git"
    repo_branch="17"
    manifest_branch="17-HertzifyOS"
    l_cmd="lunch hertzify_$DEV-cp2a-$VARIANT"
    BUILD_CMD="mka bacon"
    ;;
  
  Shinkai)
    echo "Project Shinkai"
    #rm -rf shinkai_project_palapaos_redesignui
    #echo "tag='v0.2.5'" >> .var
    echo "BUILD_BROKEN_MISSING_REQUIRED_MODULES := true" >> device/xiaomi/fog/BoardConfig.mk
    repo_url="https://github.com/ShinkaiProject/shinkai_manifest.git"
    repo_branch="heptakaideka"
    manifest_branch="17-Shinkai"
    l_cmd="breakfast $DEV"
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

for_RisingOS() {
   if [ "$first" = "yes" ]; then
      #COZ error redeclaration and unresolved on folder   frameworks/base/
      rm -rf frameworks/base
   
      echo "Fix for error already defined in RisingOS"
      rm -rf external/python/cpython2  
      rm -rf hardware/qcom-caf/sdm845
      rm -rf packages/overlays/Lineage
      rm -rf hardware/qcom-caf/msm8998
      rm -rf packages/apps/Trebuchet
      rm -rf packages/apps/Nfc
      rm -rf external/rust/crates
      rm -rf external/rust/android-crates-io
   fi
}

for_PenguinOS() {
   if [[ "$ROM" = "PenguinOS" || "$ROM" = "AOSPA" ]]; then
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
3b62e5f205de632f6c1d6b46d01a2945b5a855ec4a98247515ce8d14b51a4fa3 vendor.qti.hardware.perf@1.0::IPerf
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
      rm -rf vendor/qcom/opensource/commonsys/nfc
      sed -i 's/\bconstexpr\b/is_constexpr/g' kernel/xiaomi/fog/scripts/unifdef.c
      rm kernel/xiaomi/fog/include/uapi/linux/ion.h && cp -a kernel/xiaomi/fog/drivers/staging/android/uapi/ion.h kernel/xiaomi/fog/include/uapi/linux/
      rm kernel/xiaomi/fog/include/uapi/linux/msm_ion.h && cp -a kernel/xiaomi/fog/drivers/staging/android/uapi/msm_ion.h kernel/xiaomi/fog/include/uapi/linux/msm_ion.h
      #mv kernel/xiaomi/fog/Androidbp kernel/xiaomi/fog/Android.bp
      sed -i 's/(a2dp\.bt_decoder_format == AUDIO_FORMAT_AAC) ||/(a2dp.bt_decoder_format == (codec_t)AUDIO_FORMAT_AAC) ||/g' vendor/qcom/opensource/audio-hal/primary-hal/hal/audio_extn/a2dp.c
      curl -LO https://github.com/AOSPA/android_device_qcom_common/raw/62eff19733a338b4018b06381ad7c8a9edee62a4/vendor/media/include/fastcv.h
      mv fastcv.h hardware/qcom/media/mm-video-v4l2/vidc/venc/inc/
      #sepolicy
      curl -LO https://github.com/SourceLab081/uploadz/releases/download/v0.2.3/gemini-check2FolderConflictSepolicy.py
      python3 gemini-check2FolderConflictSepolicy.py
      . fix_bengal_conflicts.sh
      echo ' -> comment line 83-83 in device/qcom/sepolicy_vndr/generic/vendor/common/service_contexts'
      sed -i '83,83 { /^#/! s/^/# / }' device/qcom/sepolicy_vndr/generic/vendor/common/service_contexts
      echo ' -> comment line 76-76 in device/qcom/sepolicy_vndr/qva/vendor/common/service_contexts'
      sed -i '76,76 { /^#/! s/^/# / }' device/qcom/sepolicy_vndr/qva/vendor/common/service_contexts
      sed -i '5,5 { /^#/! s/^/# / }' device/qcom/sepolicy/generic/product/private/isolated_compute_app.te
      sed -i 's/type vendor_qms_service, service_manager_type;/type vendor_qms_service, vndservice_manager_type;/g' device/qcom/sepolicy_vndr/generic/vendor/common/service.te
            
   fi
}

for_PenguinOS2() {
  if [ "$ROM" = "PenguinOS2" ]; then
      #TARGET_FILE="vendor/penguin/config/penguin.mk"
      # 1. Changing PenguinSetupWizard to SetupWizard
      #sed -i 's/\bPenguinSetupWizard\b/SetupWizard/g' "$TARGET_FILE"
      # 2. Delete ONLY the rows that contain only 'Updater \'
      #sed -i '/^[[:space:]]*Updater[[:space:]]*\\$/d' "$TARGET_FILE"

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
         fi
      fi
      
      #Fix for error device/qcom/sepolicy_vndr/SEPolicy.mk:4: error: BOARD_SYSTEM_EXT_PREBUILT_DIR is obsolete. Use BOARD_SYSTEM_EXT_SEPOLICY_PREBUILT_DIRS instead.
      mk_file=$TARGET_FILE
      if grep -q "BOARD_SYSTEM_EXT_PREBUILT_DIR" "$mk_file" || grep -q "BOARD_PRODUCT_PREBUILT_DIR" "$mk_file"; then
         sed -i 's/BOARD_SYSTEM_EXT_PREBUILT_DIR/BOARD_SYSTEM_EXT_SEPOLICY_PREBUILT_DIRS/g' "$mk_file"
         sed -i 's/BOARD_PRODUCT_PREBUILT_DIR/BOARD_PRODUCT_SEPOLICY_PREBUILT_DIRS/g' "$mk_file"
      fi
      
      sed -i '838,861 { /^\/\//! s/^/\/\// }' hardware/lineage/compat/Android.bp
      sed -i '863,885 { /^\/\//! s/^/\/\// }' hardware/lineage/compat/Android.bp
      mv kernel/xiaomi/fog/Androidbp kernel/xiaomi/fog/Android.bp
  fi
}

for_HertzifyOS() {
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
}

for_shinkai() {
   if [ "$ROM" = "Shinkai" ]; then
      MK=build/make/target/product/media_product.mk
      if ! grep -q "^#PRODUCT_PACKAGES += \\\\$" "$MK"; then
         sed -i '0,/^PRODUCT_PACKAGES += \\$/{s/^PRODUCT_PACKAGES += \\$/#PRODUCT_PACKAGES += \\/}' "$MK"
         sed -i '0,/^    webview \\$/{s/^    webview \\$/#    webview \\/}' "$MK"
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

      git clone https://github.com/Gustyx-Power/shinkai_project_palapaos_redesignui -b palapa-triwulan --depth 1 
      cd shinkai_project_palapaos_redesignui
      chmod +x apply.sh
      ./apply.sh $curDir --ui-only
      cd $curDir
      rm -rf shinkai_project_palapaos_redesignui
   fi
}

for_shinkai2() {
   if [ "$ROM" = "Shinkai" ]; then
      MK=build/make/target/product/media_product.mk
      if ! grep -q "^#PRODUCT_PACKAGES += \\\\$" "$MK"; then
         sed -i '0,/^PRODUCT_PACKAGES += \\$/{s/^PRODUCT_PACKAGES += \\$/#PRODUCT_PACKAGES += \\/}' "$MK"
         sed -i '0,/^    webview \\$/{s/^    webview \\$/#    webview \\/}' "$MK"
      fi
      #These four fixes are the result of my request to claude.ai (free version)
      #Pesan sponsor: Claude is AI and can make mistakes. Please double-check responses.
      MK=build/make/core/Makefile
      #1. Fix to create the out/target/product/fog/root folder
      if grep -F -B1 '# Copying baseline ramdisk' "$MK" | grep -qF 'mkdir -p $(TARGET_ROOT_OUT)'; then
         echo "The patch already exists; skipping it"
      else
         sed -i '/^\t# Copying baseline ramdisk\.\.\./i\\tmkdir -p $(TARGET_ROOT_OUT)' "$MK"
         echo "The patch has been applied"
      fi
      
      #2. Fix to create the out/target/product/fog/recovery/root/linkerconfig folder
      if grep -F -B1 'touch $(TARGET_RECOVERY_ROOT_OUT)/linkerconfig/ld.config.txt' "$MK" | grep -qF 'mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/linkerconfig'; then
         echo "The linkerconfig already exists; skipping it"
      else
         sed -i '/^\ttouch \$(TARGET_RECOVERY_ROOT_OUT)\/linkerconfig\/ld\.config\.txt/i\\tmkdir -p $(TARGET_RECOVERY_ROOT_OUT)/linkerconfig' "$MK"
         echo "The linkerconfig patch has been applied"
      fi

      # 4. Fix for error: missing separator
      # 0. Remove the corrupted versions (both those without spaces and those with indentations)
      TAB=$(printf '\t')
      sed -i '/^[[:space:]]*\$(TARGET_OUT_VENDOR)\/etc\/vintf\/compatibility_matrix.xml: \$(HOST_OUT_EXECUTABLES)\/assemble_vintf/,+2d' "$MK"

       # 1. New rule for using awk (indentation-insensitive)
      if ! grep -qF '$(TARGET_OUT_VENDOR)/etc/vintf/compatibility_matrix.xml: $(HOST_OUT_EXECUTABLES)/assemble_vintf' "$MK"; then
         awk -v tab="$TAB" '
         /^check_vintf_vendor_deps := \$\(filter \$\(TARGET_OUT_VENDOR\)\/etc\/vintf\/%/ && !done {
         print "$(TARGET_OUT_VENDOR)/etc/vintf/compatibility_matrix.xml: $(HOST_OUT_EXECUTABLES)/assemble_vintf $(DEVICE_PATH)/configs/vintf/compatibility_matrix.xml"
           print tab "mkdir -p $(dir $@)"
           print tab "$(HOST_OUT_EXECUTABLES)/assemble_vintf -i $(DEVICE_PATH)/configs/vintf/compatibility_matrix.xml -o $@"
           done=1
         }
         { print }
         ' "$MK" > "$MK.tmp" && mv "$MK.tmp" "$MK"
      fi

      # 2. Prerequisite in check_vintf_vendor_log
      if ! grep -q 'check_vintf_vendor_log): \$(HOST_OUT_EXECUTABLES)/checkvintf \$(check_vintf_vendor_deps) \$(APEX_INFO_FILE) \$(TARGET_OUT_VENDOR)/etc/vintf/compatibility_matrix.xml' "$MK"; then
         sed -i '/^\$(check_vintf_vendor_log): \$(HOST_OUT_EXECUTABLES)\/checkvintf \$(check_vintf_vendor_deps) \$(APEX_INFO_FILE)/s|$| $(TARGET_OUT_VENDOR)/etc/vintf/compatibility_matrix.xml|' "$MK"
      fi

      # 3. Verification (optional, for logging)
      #grep -n -A2 'etc/vintf/compatibility_matrix.xml: \$(HOST_OUT_EXECUTABLES)/assemble_vintf' "$MK" | cat -A
     
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
}

repo_sync_crave() {
    info "Syncing Source using resync.sh from crave.io"
    SYNC_START=$(date +%s)
    
    if [ ! -f "/opt/crave/resync.sh" ]; then
       #This section is for repo syncs that are not on the foss.crave.io server
       #curl -LO https://raw.githubusercontent.com/accupara/docker-images/master/aosp/common/resync.sh
       #. resync.sh
       repo_sync_custom
    else
       /opt/crave/resync.sh
    fi
    
    ok "Source sync stage finished"
    info "Sync time: $(((SYNC_END - SYNC_START) / 60)) minutes" 
}

repo_sync_custom() {
    info "Syncing Source using custom options"
    SYNC_START=$(date +%s)
    repo sync -c -j$(nproc --all) --force-sync --force-remove-dirty --no-clone-bundle --no-tags \
     || {
            # Fix for error 429, but this was not executed on the foss.crave.io server
            repo sync -c -j4 --force-sync --optimized-fetch --no-clone-bundle --no-tags 
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
      if [ "$kernel_aospa" = "yes" ]; then
         git clone  -b fog_new_aospa --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog
      else   
         git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog
      fi 
   fi

   # signing key
   if [ "$ROM" = "VoltageOS" ]; then
      if [ "$first" = "yes" ]; then
         cd vendor/voltage-priv/keys
         ./keys.sh
         cd $curDir
      fi
   else   
      if [ ! -d vendor/extra ]; then
         mkdir -p vendor/extra
         cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
         cd ../..
      fi
   fi
   
   if [ ! -f script_sch2.sh ]; then
      wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
   fi
   . script_sch2.sh
}

build_start() {
   if [ "$ROM" = "Shinkai" ]; then
      . b*/env*
   else
      source build/envsetup.sh
   fi   
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
       if [[ -n "$PIXELDRAIN_API_KEY" ]]; then
          echo "Uploading to Pixeldrain..."
          PD_RESPONSE=$(curl -s -T "$ZIP_FILE" -u ":$PIXELDRAIN_API_KEY" https://pixeldrain.com/api/file/)
          PD_ID=$(echo "$PD_RESPONSE" | grep -oP '"id":"\K[^"]+')
          if [[ -n "$PD_ID" ]]; then
             DOWNLOAD_LINK="https://pixeldrain.com/u/$PD_ID"
             echo "Upload successful, Download Link: $DOWNLOAD_LINK"
          else
             echo "❌ Pixeldrain upload failed. API Response: $PD_RESPONSE"
          fi
       fi         
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
   #temporary rm for new version send_file.sh
   #rm send_file.sh
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
       if [[ -n "$secret_num" ]]; then
          cd out/target/product/$DEV
          Get_GHRelease
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
          DATE_LOG=$(date +"%Y%m%d_%H%M%S")
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
