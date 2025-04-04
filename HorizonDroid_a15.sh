export TZ=Asia/Jakarta 
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/HorizonDroidLab/manifest.git -b fifteen --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-HorizonDroidLab .repo/local_manifests 
echo "repo sync" 
/opt/crave/resync.sh 
echo "envsetup.sh" 
source build/envsetup.sh 
echo "breakfast or lunch" 
lunch horizon_fog-bp1a-userdebug
echo "Build the code" 
m horizon
