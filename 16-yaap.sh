export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
export TARGET_BOARD_PLATFORM=bengal

# rm -rf device/xiaomi/fog
repo init --depth 1 -u https://github.com/yaap/manifest.git -b sixteen --git-lfs
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 16-yaap .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh
# signing key
if [ ! -d vendor/extra ]; then
   mkdir -p vendor/extra
   cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
   cd ../..
fi  

#if [ ! -f script_sch2.sh ]; then
#   wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
#fi
#. script_sch2.sh
rm -rf kernel/xiaomi/fog
#fixed Dex2oat failed to compile a boot image 
wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/Android_.bp && mv Android_.bp art/build/Android.bp
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
echo "breakfast/lunch"
lunch yaap_fog-bp2a-userdebug
#lunch aosp_fog-bp2a-userdebug
#breakfast fog eng
#lunch aicp_fog-eng
#echo "Breakfast + Build the code"
#brunch fog userdebug
echo "build the code"
m yaap
#mka clover -j$(nproc --all)
