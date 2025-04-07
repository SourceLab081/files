export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
repo init --depth 1 -u https://github.com/Komodo-OS/manifest -b 15 --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-Komodo .repo/local_manifests 
echo "repo sync" 
/opt/crave/resync.sh 
echo "envsetup.sh" 
source build/envsetup.sh 
echo "breakfast or lunch" 
lunch komodo_fog-ap4a-userdebug
echo "Build the code" 
#make installclean
mka komodo 
