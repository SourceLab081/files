export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss

#rm -rf device/xiaomi/fog
#rm -rf device/xiaomi/fog-kernel

repo init -u https://github.com/VoltageOS/manifest.git --depth 1 -b 17 --git-lfs
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 16-VoltageOS .repo/local_manifests

echo "repo sync"
/opt/crave/resync.sh
# signing key
export curDir=`pwd`
cd vendor/voltage-priv/keys
./keys.sh
cd $curDir

#rm -rf bionic && git clone  https://github.com/VoltageOS/bionic -b 16.2 bionic &&  cd bionic && git checkout 9bc94b544244ffab12aa05cd670a135ebdda45ab
#cd $curDir

#cd frameworks/base && git checkout ca94c181d8a23569b8157427d4740154ea529b55 
#cd $curDir
#cd packages/apps/Settings && git checkout 6205287aa09f078fba8a9f03b6fa32d4d9c1f79e
#cd $curDir
#wget https://github.com/VoltageOS/bionic/raw/0c133d2f44e0cb6244509a817fc52f7178da39d4/libc/bionic/custom_rom_hide.cpp && mv custom_rom_hide.cpp bionic/libc/bionic/
##wget https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/voltage.devices && mv voltage.devices vendor/voltage/
#cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir
#cd kernel/xiaomi/fog &&	rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy_susfs && cd $curDir
rm -rf kernel/xiaomi/fog && git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog

if [ ! -f script_sch2.sh ]; then
   wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
fi
. script_sch2.sh


# rm -rf out/target/product/fog/system/etc/vintf
# fix for error Problems processing genfscon rules
# https://github.com/LineageOS/android_device_qcom_sepolicy_vndr/blob/lineage-22.2-legacy-um/generic/vendor/common/init_shell.te
#fldr="device/qcom/sepolicy_vndr/legacy-um/generic/vendor/common/"
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/file.te && mv file.te $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/genfs_contexts && mv genfs_contexts $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/init_shell.te && mv init_shell.te $fldr
export PACKAGE_NAME="vos-17"
echo "envsetup.sh"
. build/envsetup.sh
#export ALLOW_MISSING_DEPENDENCIES=true 
#export SELINUX_IGNORE_NEVERALLOWS=true
#echo "breakfast/lunch"
#lunch yaap_fog-userdebug
#lunch aosp_fog-bp2a-userdebug
#breakfast fog eng
lunch voltage_fog-cp2a-user

make installclean
echo "Build $PACKAGE_NAME starting soong. "
START_SECONDS=$(date +%s)
(
  sleep 3000; # 50 minutes 
  #curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="crave.io build failed. soong timed out after limit. harakiri. `date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1 ;
  #curl -s -d "crave.io build failed. soong timed out after limit. harakiri. `date`. JJ_SPEC:$JJ_SPEC" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1 ;
  echo "crave.io build failed. soong timed out after limit. harakiri. `date`"
  rm -rf /tmp/src/android/vendor/lineage-priv ;
  kill -9 $$
) &
SLEEPID=$!
export GOMEMLIMIT=52GiB GOGC=20 GODEBUG="gctrace=1" GOMAXPROCS=12
#export GOMEMLIMIT=52GiB GOMAXPROCS=12
for i in 1 2 3 4 5 6 7 8; do
  NOW_SECONDS=$(date +%s)
  USED_SECONDS=$((NOW_SECONDS - START_SECONDS))
  USED_MINUTES=$((USED_SECONDS / 60))
  echo "Build $PACKAGE_NAME trying soong. try $i. $USED_MINUTES minutes."
  if [[ $USED_SECONDS -ge 2700 ]]; then # 45 minutes
    echo "Build $PACKAGE_NAME failed. soong timed out. $i - 1 tries. $USED_MINUTES minutes."
    kill -9 $SLEEPID
    exit 1
    #false  ;check_fail
  fi    
  if m nothing; then
    NOW_SECONDS=$(date +%s)
    USED_SECONDS=$((NOW_SECONDS - START_SECONDS))
    USED_MINUTES=$((USED_SECONDS / 60))
    echo "Build $PACKAGE_NAME soong success. $i tries. $USED_MINUTES minutes."
    unset GOMEMLIMIT GOMAXPROCS GOGC GODEBUG
    kill -9 $SLEEPID
    break
  fi
  if [[ $i -eq 8 ]]; then
    echo "Build $PACKAGE_NAME soong failed. $i tries. $USED_MINUTES minutes."
    kill -9 $SLEEPID
    exit 1
    #false  ;check_fail
  fi 
done
unset GOMEMLIMIT GOGC GODEBUG GOMAXPROCS
#unset GOMEMLIMIT GOMAXPROCS
mka bacon
#brunch fog
#echo "build the code"
#m yaap
#mka clover -j$(nproc --all)
