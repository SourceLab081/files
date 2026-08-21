
export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
free -h
nproc --all
repo init --depth 1 -u https://github.com/Pixelify-AOSP/platform_manifest -b 17 --git-lfs
rm -rf .repo/local_manifests && git clone  https://github.com/SourceLab081/local_manifests --depth 1 -b 17-los .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh
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
rm -rf kernel/xiaomi/fog && git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog

#export JAVA_TOOL_OPTIONS="-Xmx2112m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -XX:+UseG1GC -Dfile.encoding=UTF-8"	
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
rm -f hardware/qcom/sm7250/Android.bp hardware/qcom/sm7250/Android.mk
rm -f hardware/qcom/sdm845/Android.bp hardware/qcom/sdm845/Android.mk
rm -f hardware/qcom/sm8150/Android.bp hardware/qcom/sm8150/Android.mk

#khusus setelah ada error ldd
#rm -rf out/soong/.intermediates/bionic/

#PACKAGE_NAME=Pixelify-AOSP
echo "envsetup.sh"
. build/envsetup.sh
#export ALLOW_MISSING_DEPENDENCIES=true 
#export SELINUX_IGNORE_NEVERALLOWS=true
#echo "breakfast/lunch"
#breakfast fog eng
lunch fog-cp2a-user 
#mka bacon
mka installclean

# =======================================================
# 1. PASANG PEMBATASAN RAM SECARA KETAT (TETAP DIKAPALKAN)
# =======================================================
export GOMEMLIMIT=12GiB          # Ditunggangi agar Go/Soong tidak maruk
export GOGC=30                   # GC cukup agresif (JANGAN DI-UNSET)
export GOMAXPROCS=4              # Cukup 4 thread untuk Go agar RAM hemat

# KUNCI UTAMA: Pangkas RAM Java dari 20GB ke 6GB/8GB!
# Java di A17 tidak butuh 20GB. Memangkasnya memberi sisa ~12GB RAM murni untuk Clang!
export _JAVA_OPTIONS="-Xmx8g -XX:+UseG1GC" 

export USE_CCACHE=0
export ANDROID_RAM_OPTIMIZE_THROTTLE=true
export DISABLE_LTO=true
export USE_CLANG_LLD=true

#export NINJA_ARGS="-j8"
export SOONG_BUILD_MAX_PARALLEL_THREADS=4
# =======================================================
# 2. RUNNING 'm nothing'
# =======================================================
echo "==> Memulai m nothing..."
m nothing 
#|| exit 1

# =======================================================
# 3. TRANSISI KE BACON / BUILD UTAMA
# =======================================================
echo "==> Mempersiapkan transisi ke kompilasi utama..."

# JANGAN UNSET GOGC! Biarkan GOGC=30 agar Soong tidak makan RAM saat kompilasi C++
export GOMEMLIMIT=14GiB

# Bersihkan cache RAM OS
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1

# =======================================================
# 4. EKSEKUSI KOMPILASI UTAMA DENGAN NINJA LOAD-LIMIT
# =======================================================
# Tetap gunakan full CPU (-j$(nproc)), TAPI batasi jika beban RAM/Load melonjak
#export NINJA_ARGS="-j$(nproc)"

echo "==> Memulai kompilasi utama dengan full CPU..."
make -j$(nproc)

#make installclean
#echo "Breakfast + Build the code"
#brunch fog user
