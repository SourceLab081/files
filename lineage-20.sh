export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
repo init --depth 1 -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b lineage-20.0 .repo/local_manifests 
echo "repo sync" 
#/opt/crave/resync.sh 
echo "envsetup.sh" 
source build/envsetup.sh 
#export SELINUX_IGNORE_NEVERALLOWS=true
#export ALLOW_MISSING_DEPENDENCIES=true
breakfast fog eng
echo "Start the build" 
make installclean
brunch fog eng
