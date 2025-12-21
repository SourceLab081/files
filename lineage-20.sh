export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
export non_hybris=yes
echo "start date = `date`" > date.txt

#rm -rf device/xiaomi/fog vendor/xiaomi/fog
repo init --depth 1 -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b lineage-20 .repo/local_manifests 
echo "repo sync" 
/opt/crave/resync.sh
sudo ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6.5 /usr/lib/x86_64-linux-gnu/libncurses.so.5 
sudo ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6.5 /usr/lib/x86_64-linux-gnu/libtinfo.so.5 
#/opt/crave/resync.sh 
# wget https://raw.githubusercontent.com/accupara/docker-images/master/aosp/common/resync.sh
# . resync.sh
curDir=`pwd`
cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir

echo "envsetup.sh" 
source build/envsetup.sh 
#export SELINUX_IGNORE_NEVERALLOWS=true
#export ALLOW_MISSING_DEPENDENCIES=true
#breakfast fog eng
echo "Start the build" 
make installclean
brunch fog eng
echo "end date = `date`" >> date.txt
