export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss

rm -rf device/xiaomi/fog
repo init --depth 1 -u https://github.com/VoltageOS/manifest.git -b 16 --git-lfs 
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 16-VoltageOS .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh
# signing key
curDir=`pwd`
#cd vendor/voltage-priv/keys
#./keys.sh
#cd $curDir
#if [ ! -d vendor/extra ]; then
#   mkdir -p vendor/extra
#   cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
#   cd ../..
#fi  

if [ ! -f script_sch2.sh ]; then
   wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
fi
. script_sch2.sh
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/build_fingerprint.txt && mv build_fingerprint.txt out/target/product/fog/
# cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir

# rm -rf out/target/product/fog/system/etc/vintf
# fix for error Problems processing genfscon rules
# https://github.com/LineageOS/android_device_qcom_sepolicy_vndr/blob/lineage-22.2-legacy-um/generic/vendor/common/init_shell.te
#fldr="device/qcom/sepolicy_vndr/legacy-um/generic/vendor/common/"
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/file.te && mv file.te $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/genfs_contexts && mv genfs_contexts $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/init_shell.te && mv init_shell.te $fldr

echo "envsetup.sh"
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true
#echo "breakfast/lunch"
#lunch yaap_fog-userdebug
#lunch aosp_fog-bp2a-userdebug
#breakfast fog eng
make installclean
echo "Breakfast + Build the code"
brunch fog eng
#echo "build the code"
#m yaap
#mka clover -j$(nproc --all)
