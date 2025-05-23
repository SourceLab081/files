export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/CipherOS/android_manifest.git -b fifteen --git-lfs
rm -rf .repo/local_manifests && git clone  https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-CipherOS .repo/local_manifests 
echo "repo sync" 
/opt/crave/resync.sh 
 # signing key
 mkdir -p vendor/extra
 cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
 cd ../..
echo "envsetup.sh"
source build/envsetup.sh
#export ALLOW_MISSING_DEPENDENCIES=true 
#export SELINUX_IGNORE_NEVERALLOWS=true
echo "breakfast/lunch"
lunch cipher_fog-ap3a-userdebug
echo "Build the code"
make installclean
mka bacon -j$(nproc --all)
