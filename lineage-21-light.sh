export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
repo init --depth 1 -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b lineage-21-light .repo/local_manifests 
echo "repo sync" 
/opt/crave/resync.sh 
#signing keys
export subject='/C=ID/ST=DKI Jakarta/L=Jakarta/O=Android/OU=Android/CN=rom/emailAddress=craveio0explore@gmail.com'
mkdir ~/.android-certs
for cert in bluetooth cyngn-app media networkstack nfc platform releasekey sdk_sandbox shared testcert testkey verity; do \
    yes "" | ./development/tools/make_key  ~/.android-certs/$cert "$subject"; \
done
echo "envsetup.sh" 
source build/envsetup.sh 
bash lineage_build_unified/buildbot_unified.sh treble 64VN 64VS 64GN
#export SELINUX_IGNORE_NEVERALLOWS=true
#export ALLOW_MISSING_DEPENDENCIES=true
echo "breakfast or lunch" 
breakfast fog
echo "Start the build" 
croot
brunch fog
