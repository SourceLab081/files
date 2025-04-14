export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
echo "start date = `date`"
#repo init --depth 1 -u https://github.com/Miku-UI/manifesto -b Vampire_v3 --git-lfs
#rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-Miku-UI .repo/local_manifests 
#echo "repo sync" 
#/opt/crave/resync.sh
#rm -rf external/bash 
echo "envsetup.sh" 
source build/envsetup.sh 
#export SELINUX_IGNORE_NEVERALLOWS=true
#export ALLOW_MISSING_DEPENDENCIES=true
echo "breakfast or lunch" 
lunch miku_fog-bp1a-userdebug
echo "Build the code" 
make diva
