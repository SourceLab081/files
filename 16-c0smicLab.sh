xport TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
#echo "start date = `date`"
repo init --depth 1 -u hhttps://github.com/c0smic-Lab/manifest.git -b 16 --git-lfs
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 16-c0smicLab .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh
# signing key
if [ ! -d vendor/extra ]; then
   mkdir -p vendor/extra
   cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
   cd ../..
fi  

#if [ ! -f script_sch.sh ]; then
#   wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch.sh
#fi
#. script_sch.sh
#rm -rf out/target/product/fog/system/etc/vintf
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
#make installclean
mka bacon -j$(nproc)
#mka clover -j$(nproc 
--all)
