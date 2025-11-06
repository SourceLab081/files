export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/SailfishOS-miatoll/android  -b hybris-18.1 --git-lfs --no-clone-bundle
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b hybris-18.1 .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh
# signing key
#mkdir -p vendor/extra
#cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
#cd ../..
#export SAILFISH_BUILD=1
echo "envsetup.sh"
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true
echo "breakfast/lunch"
breakfast fog userdebug
echo "start build..."
make -j$(nproc --all) hybris-hal droidmedia libui_compat_layer libsfplugin_ccodec
