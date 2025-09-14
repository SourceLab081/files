export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss

# rm -rf device/xiaomi/fog
repo init --depth 1 -u https://git.halogenos.org/halogenOS/android_manifest.git -b XOS-16.0 --git-lfs
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 16-c0smicLab .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh
# signing key
if [ ! -d vendor/extra ]; then
   mkdir -p vendor/extra
   cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
   cd ../..
fi  
#rm -rf hardware/xiaomi/vibrator
if [ ! -f script_sch3.sh ]; then
   wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch3.sh
fi
. script_sch3.sh
echo "This is for testing only"
file0="http://ftp.debian.org/debian/pool/main/p/pillow/python3-pil_11.1.0-5+b1_amd64.deb"
file1="http://ftp.debian.org/debian/pool/main/libi/libimagequant/libimagequant0_2.18.0-1+b2_amd64.deb"
file2="http://ftp.debian.org/debian/pool/main/r/raqm/libraqm0_0.10.2-1_amd64.deb"
curDir=`pwd`
set -x
cd /var/cache/apt/archives/
sudo wget $file1
sudo dpkg -i libimagequant0_2.18.0-1+b2_amd64.deb
sudo wget $file2
sudo dpkg -i libraqm0_0.10.2-1_amd64.deb
if [ ! -f python3-pil_11.1.0-5+b1_amd64.deb ]; then
   sudo wget $file0
fi
sudo dpkg -i python3-pil_11.1.0-5+b1_amd64.deb
cd $curDir
#sudo apt --fix-broken install
#sudo apt --yes install python3-pil 
set +x
cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir

# fix for error Problems processing genfscon rules
# https://github.com/LineageOS/android_device_qcom_sepolicy_vndr/blob/lineage-22.2-legacy-um/generic/vendor/common/init_shell.te
fldr="device/qcom/sepolicy_vndr/legacy-um/generic/vendor/common/"
wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/file.te && mv file.te $fldr
wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/genfs_contexts && mv genfs_contexts $fldr
wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/init_shell.te && mv init_shell.te $fldr

echo "envsetup.sh"
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true
echo "breakfast/lunch"
lunch aosp_fog-bp2a-userdebug
#breakfast fog eng
#lunch aicp_fog-eng
#echo "Breakfast + Build the code"
#brunch fog userdebug
echo "build the code"

m bacon 
#mka clover -j$(nproc --all)
