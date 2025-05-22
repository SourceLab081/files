export TZ=Asia/Jakarta
export BUILD_USERNAME=sourceslab062
export BUILD_HOSTNAME=foss
repo init --depth 1 -u https://github.com/GenesisOS/manifest.git -b  verve-qpr2 --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-GenesisOS2 .repo/local_manifests
echo "repo sync" 
/opt/crave/resync.sh
#signing keys
subject='/C=ID/ST="DKI Jakarta"/L=Jakarta/O=Android/OU=Android/CN=rom/emailAddress=craveio0explore@gmail.com'
for x in releasekey platform shared media networkstack verity otakey testkey sdk_sandbox bluetooth nfc; do \
    yes "" | ./development/tools/make_key vendor/genesis/signing/keys/$x "$subject"; \
done
echo "envsetup.sh"
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export SELINUX_IGNORE_NEVERALLOWS=true
echo "breakfast/lunch"
breakfast fog 
echo "Build the code"
mka genesis
