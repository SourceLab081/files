xport TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/The-Clover-Project/manifest.git -b 15-qpr2 --git-lfs
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b 15-theCloverProject .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh
# signing key
#mkdir -p vendor/extra
#cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
#cd ../..

#wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.2/script_sch2.sh
#. script_sch2.sh
mv out/target/product/fog/system/etc/vintf bckp/
echo "envsetup.sh"
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true
echo "breakfast/lunch"
lunch clover_fog-bp1a-userdebug
#breakfast fog eng
#lunch aicp_fog-eng
#echo "Breakfast + Build the code"
#brunch fog userdebug
echo "build the code"
mka clover -j$(nproc --all)
