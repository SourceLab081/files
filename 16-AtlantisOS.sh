export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss

#rm -rf device/xiaomi/fog
repo init --depth 1 -u https://github.com/AtlantisOS/manifest -b 16 --git-lfs 
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 16-AtlantisOS .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh

curDir=`pwd`

# signing key
if [ ! -d vendor/extra ]; then
   mkdir -p vendor/extra
   cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
   cd ../..
fi  

if [ ! -f script_sch2.sh ]; then
   wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
fi
. script_sch2.sh


cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir


echo "envsetup.sh"
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true
echo "breakfast/lunch"
lunch atlantis_fog-bp2a-eng
#make installclean
echo "build the code"
m atlantis
#mka clover -j$(nproc --all)
