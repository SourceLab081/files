repo init --depth 1 -u https://github.com/AICP/platform_manifest.git -b v15.0 --git-lfs
rm -rf .repo/local_manifests && git clone https://gitlab.com/sourceslab062/local_manifests --depth 1 -b 15-aicp .repo/local_manifests
echo "repo sync"
/opt/crave/resync.sh
echo "envsetup.sh"
. build/envsetup.sh
#echo "breakfast/lunch"
#breakfast fog eng
#lunch aicp_fog-eng
echo "Breakfast + Build the code"
brunch fog eng
