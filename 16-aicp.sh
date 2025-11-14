
export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/AICP/platform_manifest.git -b w16.0 --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 16-aicp .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh

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
#echo "breakfast/lunch"
#breakfast fog eng
#lunch aicp_fog-eng
echo "Breakfast + Build the code"
brunch fog eng
