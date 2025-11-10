export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/SailfishOS-msmnile/manifest.git -b hybris-18.1 
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b hybris-18.1 .repo/local_manifests
echo "repo sync"
#/opt/crave/resync.sh
repo sync --fetch-submodules -j$(nproc --all)
# signing key
#mkdir -p vendor/extra
#cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
#cd ../..
export SAILFISH_BUILD=1
export VENDOR="xiaomi"
export DEVICE="fog"
export PORT_ARCH="aarch64"
curDir=`pwd`
export ANDROID_ROOT=`pwd`
#cd external/chromium-webview;rm Android.mk;ln -s patches/os_pickup.mk Android.mk;cd $curDir;
# echo "apply patch"
#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/chromium.zip;unzip -o chromium.zip -d external/chromium-webview/;rm chromium.zip 
. hybris-patches/apply-patches.sh  --mb
cd $ANDROID_ROOT
wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/droid-hal-device.inc;mv droid-hal-device.inc rpm/dhd/
FILE="/usr/lib/x86_64-linux-gnu/libncurses.so.5"
if [ ! -f "$FILE" ]; then
  echo "File '$FILE' does not exist."
  sudo ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6.5 /usr/lib/x86_64-linux-gnu/libncurses.so.5 
  sudo ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6.5 /usr/lib/x86_64-linux-gnu/libtinfo.so.5 
fi
#. fog-patches/fog_patches.sh
#cd $curDir

echo "envsetup.sh"
source build/envsetup.sh

export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true

echo "breakfast/lunch"
breakfast $DEVICE
echo "start compiling..."
brunch fog


make -j$(nproc --all) hybris-hal droidmedia 
# libui_compat_layer libsfplugin_ccodec
