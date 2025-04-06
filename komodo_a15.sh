export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/Komodo-OS/manifest -b 15 --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-Komodo .repo/local_manifests 
echo "repo sync" 
/opt/crave/resync.sh 
# signing key
mkdir -p vendor/extra
cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
cd ../..
# not using new hardware/xiaomi/aidl/sensors 
wget https://github.com/SourceLab081/uploadz/releases/download/v0.1.3/sens.zip
wget https://github.com/SourceLab081/uploadz/releases/download/v0.1.3/sensors.sh
. sensors.sh
echo "envsetup.sh" 
source build/envsetup.sh 
echo "breakfast or lunch" 
lunch komodo_fog-ap4a-userdebug
echo "Build the code" 
#make installclean
mka komodo 
