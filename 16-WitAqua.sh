
export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"

#rm -rf kernel/xiaomi/fog
repo init --depth 1 -u https://github.com/WitAqua/manifest.git -b 16.0 --git-lfs 
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 16-WitAqua .repo/local_manifests
echo "repo sync"
#repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags 
#wget https://raw.githubusercontent.com/accupara/docker-images/master/aosp/common/resync.sh
 #. resync.sh
/opt/crave/resync.sh

# signing key
if [ ! -d vendor/extra ]; then
   mkdir -p vendor/extra
   cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
   cd ../..
fi

curDir=`pwd`
if [ ! -f external/chromium-webview/prebuilt/arm64/webview.apk ]; then
   echo "Go to process to unzip the file"
   if [ ! -f external/chromium-webview/prebuilt/prebuilt.zip ]; then
       wget https://github.com/SourceLab081/uploadz/releases/download/v0.1.8/prebuilt.zip
       mv prebuilt.zip external/chromium-webview/prebuilt/
   fi
   cd external/chromium-webview/prebuilt/;unzip -o prebuilt.zip;cd $curDir
else
   echo "webview.apk file is exist"  
fi

if [ ! -f script_sch2.sh ]; then
   wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
fi
. script_sch2.sh

#cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir

echo "envsetup.sh"
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true
#echo "breakfast/lunch"
#breakfast fog eng
#lunch aicp_fog-eng
echo "Breakfast + Build the code"
brunch fog eng
