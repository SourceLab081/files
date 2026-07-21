
export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"

##repo init --depth 1 -u https://github.com/Pixelify-AOSP/platform_manifest -b 17 --git-lfs
##rm -rf .repo/local_manifests && git clone  https://github.com/SourceLab081/local_manifests --depth 1 -b 17-los .repo/local_manifests
##echo "repo sync"
##/opt/crave/resync.sh
#wget https://raw.githubusercontent.com/accupara/docker-images/master/aosp/common/resync.sh
 #. resync.sh
# signing key
if [ ! -d vendor/extra ]; then
   mkdir -p vendor/extra
   cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
   cd ../..
fi


# wget https://github.com/SourceLab081/uploadz/releases/download/v0.1.5/280dpi && mv 280dpi vendor/aicp/charger/images/ 

curDir=`pwd`
#cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir
#cd kernel/xiaomi/fog &&	rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy_susfs && cd $curDir
##rm -rf kernel/xiaomi/fog && git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog

export JAVA_TOOL_OPTIONS="-Xmx2112m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -XX:+UseG1GC -Dfile.encoding=UTF-8"	
#export JACK_SERVER_VM_ARGUMENTS="-Xmx4g"
#export JAVA_TOOL_OPTIONS="-Xmx4g -XX:+UseG1GC -Dfile.encoding=UTF-8"
#export ANDROID_RAM_INDEX=4096

#export DISABLE_THINLTO=true

# 3. Kendalikan Parallel Jobs khusus untuk Linker C++
#export NINJA_ARGS="-j12"
#sudo fallocate -l 32G swapfile
#sudo chmod 600 swapfile
#sudo mkswap swapfile
#sudo swapon swapfile
#sudo modprobe zram
#echo 32G | sudo tee /sys/block/zram0/disksize
#sudo mkswap /dev/zram0
#sudo swapon /dev/zram0

echo "envsetup.sh"
. build/envsetup.sh
#export ALLOW_MISSING_DEPENDENCIES=true 
#export SELINUX_IGNORE_NEVERALLOWS=true
#echo "breakfast/lunch"
#breakfast fog eng
lunch fog-cp2a-user
#mka bacon
make -j14 
#make installclean
#echo "Breakfast + Build the code"
#brunch fog user
