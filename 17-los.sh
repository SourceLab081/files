
export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
free -h
nproc --all
#sudo fallocate -l 32G swapfile
#sudo chmod 600 swapfile
#sudo mkswap swapfile
#sudo swapon swapfile
#sudo modprobe zram
#echo 32G | sudo tee /sys/block/zram0/disksize
#sudo mkswap /dev/zram0
#sudo swapon /dev/zram0
echo "update=$update"
if [ "$update" = "no" ]; then
   repo init --depth 1 -u https://github.com/Pixelify-AOSP/platform_manifest -b 17 --git-lfs
   rm -rf .repo/local_manifests && git clone  https://github.com/SourceLab081/local_manifests --depth 1 -b 17-los .repo/local_manifests
   echo "repo sync"
   /opt/crave/resync.sh
   #wget https://raw.githubusercontent.com/accupara/docker-images/master/aosp/common/resync.sh
   if [ ! -d vendor/extra ]; then
      mkdir -p vendor/extra
      cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
      cd ../..
   fi
   
   curDir=`pwd`
   #cd kernel/xiaomi/fog && rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash - && cd $curDir
   #cd kernel/xiaomi/fog &&	rm -rf KernelSU-Next && curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy_susfs && cd $curDir
   rm -rf kernel/xiaomi/fog && git clone  -b fog_new --depth 1 --recurse-submodules https://github.com/SourceLab081/greenforce kernel/xiaomi/fog

  rm -f hardware/qcom/sm7250/Android.bp hardware/qcom/sm7250/Android.mk
  rm -f hardware/qcom/sdm845/Android.bp hardware/qcom/sdm845/Android.mk
  rm -f hardware/qcom/sm8150/Android.bp hardware/qcom/sm8150/Android.mk
fi
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


# Pengatur Memori & Threading Go/Soong
#export GOMEMLIMIT=28GiB          # Memberi ruang napas untuk sistem Linux agar tidak kena memory stall
#export GOGC=30                   # Memaksa Garbage Collector Go lebih sering membuang RAM sampah
#export GOMAXPROCS=4              # Membatasi thread Go runtime saat pembacaan graph
#export SOONG_BUILD_MAX_PARALLEL_THREADS=2  # Membatasi paralisme Soong builder
#export _JAVA_OPTIONS="-Xmx8g -XX:+UseG1GC"
#export USE_CCACHE=0
export GOGC=15
export GOMAXPROCS=4
export GOMEMLIMIT=28GiB
# =======================================================
# 2. RUNNING 'm nothing'
# =======================================================
#echo "==> Memulai m nothing..."
#m nothing || m nothing || m nothing

# 3. Kembalikan variabel & jalankan kompilasi biner utama

#|| exit 1
mka installclean

# JANGAN UNSET GOGC! Biarkan GOGC=30 agar Soong tidak makan RAM saat kompilasi C++
#export GOMEMLIMIT=14GiB

# Bersihkan cache RAM OS
#sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1

# =======================================================
# 4. EKSEKUSI KOMPILASI UTAMA DENGAN NINJA LOAD-LIMIT
# =======================================================
# Tetap gunakan full CPU (-j$(nproc)), TAPI batasi jika beban RAM/Load melonjak
#export NINJA_ARGS="-j$(nproc)"

echo "==> Memulai kompilasi utama dengan full CPU..."
make -j$(nproc --all)

#make installclean
#echo "Breakfast + Build the code"
#brunch fog user
