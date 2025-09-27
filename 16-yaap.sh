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

# disable fsgen
cd build/soong && curl https://gist.githubusercontent.com/bagaskara815/2f26516ef378fe8eae9803749e331a09/raw/fsgen.patch >> fsgen.patch && git am fsgen.patch && rm fsgen.patch && cd ../../

# remove other power
#rm -f vendor/qcom/opensource/power/power.xml
curDir=`pwd`
cd vendor/qcom/opensource/power/ && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/power.xml
cd $curDir
rm -f out/target/product/fog//vendor/etc/vintf/manifest/power.xml
#rm -f /tmp/src/android/out/soong/.temp/target_filesb4_jkj_q/VENDOR/etc/vintf/manifest/power.xml
rm -f /tmp/src/android/out/soong/.temp/target_files69gkeh3f/VENDOR/etc/vintf/manifest/power.xml

# fixed redundant variable
if [ ! -f script_sch2.sh ]; then
   wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
fi
. script_sch2.sh

# new : this is not solution for fixed Dex2oat failed to compile a boot image in this case , but the solution is drop telephony hal
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/Android_.bp && mv Android_.bp art/build/Android.bp
# rm -rf out/target/product/fog/system/etc/vintf
# fix for error Problems processing genfscon rules
# https://github.com/LineageOS/android_device_qcom_sepolicy_vndr/blob/lineage-22.2-legacy-um/generic/vendor/common/init_shell.te
#fldr="device/qcom/sepolicy_vndr/legacy-um/generic/vendor/common/"
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/file.te && mv file.te $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/genfs_contexts && mv genfs_contexts $fldr
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/init_shell.te && mv init_shell.te $fldr
# add KernelSU-Next
curDir=`pwd`
#cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir

echo "envsetup.sh"
. build/envsetup.sh
#export YAAP_BUILDTYPE=COMMUNITY
export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true
echo "breakfast/lunch"
lunch yaap_fog-bp2a-eng
#lunch aosp_fog-bp2a-userdebug
make installclean
#lunch aicp_fog-eng
#echo "Breakfast + Build the code"
#brunch fog userdebug
echo "build the code"
TARGET_BUILD_GAPPS=true m yaap
#mka clover -j$(nproc --all)
