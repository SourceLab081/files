export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/VoltageOS/manifest.git -b 15-qpr2 --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-VoltageOS .repo/local_manifests 
echo "repo sync" 
/opt/crave/resync.sh 
## signing key
mkdir -p vendor/extra
cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
cd ../..
echo "envsetup.sh" 
source build/envsetup.sh 
export SELINUX_IGNORE_NEVERALLOWS=true
#export ALLOW_MISSING_DEPENDENCIES=true
echo "breakfast and build" 
brunch fog
