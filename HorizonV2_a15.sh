export TZ=Asia/Jakarta 
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/HorizonV2/android.git -b lineage-22.2 --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-HorizonV2 .repo/local_manifests 
echo "repo sync" 
/opt/crave/resync.sh 
## signing key
mkdir -p vendor/extra
cd vendor/extra && wget https://github.com/SourceLab081/uploadz/releases/download/v0.0.8/sign.zip && unzip sign.zip && rm sign.zip
cd ../..
echo "envsetup.sh" 
source build/envsetup.sh 
echo "breakfast or lunch" 
lunch lineage_fog-bp1a-userdebug
echo "Build the code" 
make installclean
mka horizon
