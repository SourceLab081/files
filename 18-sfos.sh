export dirHome=`pwd`
#sudo apt install -y git-core zip
#wget https://github.com/SourceLab081/sfbootstrap/archive/refs/heads/master.zip
#unzip master.zip
#cd sfbootstrap-master
#git clone https://github.com/SourceLab081/sfbootstrap
#cd sfbootstrap
echo "run the command"
curl -LO https://proot.gitlab.io/proot/bin/proot
chmod +x ./proot
./proot --version
set -x
sudo apt-get update && sudo apt-get -y install libpam-pwquality
echo $HOME
export curDir=`pwd`

cat << 'EOF' > proot.sh
#!/bin/bash
PROOT_BIN="$curDir/proot"
  "$PROOT_BIN" \
    -0 \
   -r $1 \
  -b /proc:/proc \
  -b /sys:/sys \
  -b /dev:/dev \
  -b /dev/pts:/dev/pts \
  -b /tmp \
  -b /run \
  /usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin \
  /bin/bash $2
EOF
cat proot.sh
chmod +x proot.sh

cat << 'EOF' > ~/.hadk.env
export ANDROID_ROOT="$curDir/hadk"
export VENDOR="xiaomi"
export DEVICE="fog"
export PORT_ARCH="aarch64"
EOF

cat << 'EOF' > ~/.mersdk.profile
function hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; } hadk
EOF

cat << 'EOF' >~/.mersdkubu.profile
function hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; }
export PS1="HABUILD_SDK [\${DEVICE}] $PS1"
hadk
EOF

cat << 'EOF' > sdk_p.sh
#/usr/sbin/useradd -m -u 1000 admin
su admin
sudo zypper ref
sudo zypper in android-tools-hadk kmod createrepo_c nano
source ~/.hadk.env
echo "Menjalankan script HADK..."
mb2 --version
rpm --version
pwd
sdk-assistant create SailfishOS-latest https://releases.sailfishos.org/sdk/targets/Sailfish_OS-latest-Sailfish_SDK_Tooling-i486.tar.7z
sdk-assistant create $VENDOR-$DEVICE-$PORT_ARCH https://releases.sailfishos.org/sdk/targets/Sailfish_OS-latest-Sailfish_SDK_Target-aarch64.tar.7z
. init_ub.sh
EOF

cat << 'EOF' > init_ub.sh
#TARBALL=ubuntu-focal-20210531-android-rootfs.tar.bz2
#curl -O https://releases.sailfishos.org/ubu/$TARBALL
UBUNTU_CHROOT=$PLATFORM_SDK_ROOT/sdks/ubuntu
sudo mkdir -p $UBUNTU_CHROOT
sudo tar --numeric-owner -xjf $TARBALL -C $UBUNTU_CHROOT
#ubu-chroot -r $PLATFORM_SDK_ROOT/sdks/ubuntu
source ~/.hadk.env
#export dir=sailfishos/sdks/ubuntu
sudo cp sdk_ub.sh $UBUNTU_CHROOT
sudo chroot  $UBUNTU_CHROOT /usr/sbin/useradd -m -u 1000 admin;cat /etc/issue;
sudo chroot $UBUNTU_CHROOT /bin/bash -c "chage -M 999999 $(id -nu 1000)"
sudo mount -t proc none $UBUNTU_CHROOT/proc;
sudo mount --rbind /sys $UBUNTU_CHROOT/sys;
sudo mount --rbind /dev $UBUNTU_CHROOT/dev;
sudo chroot  $UBUNTU_CHROOT /usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin /bin/bash sdk_ub.sh
#. proot.sh $UBUNTU_CHROOT sdk_ub.sh
cd $ANDROID_ROOT
rpm/dhd/helpers/build_packages.sh --droid-hal
rpm/dhd/helpers/build_packages.sh --configs
rpm/dhd/helpers/build_packages.sh --mw
rpm/dhd/helpers/build_packages.sh --mw=https://github.com/SailfishOS-vayu/parse-android-dynparts
rpm/dhd/helpers/build_packages.sh --mw=https://github.com/SailfishOS-vayu/pulseaudio-modules-droid
rpm/dhd/helpers/build_packages.sh --gg
rpm/dhd/helpers/build_packages.sh --version
export RELEASE=5.0.0.62
-- you extra name flashable

export EXTRA_NAME=-kernelpanix
rpm/dhd/helpers/build_packages.sh --mic
EOF

cat << 'EOF' > sdk_ub.sh
su admin
sudo apt-get update
sudo apt install cpio bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libncurses5 libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python-is-python3 -yq
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > repo
sudo mv repo /usr/bin/
sudo chmod a+x /usr/bin/repo
git config --global user.email "tester@localhost"
git config --global user.name "Tester"
git config --global color.ui true
git config --global http.postBuffer 524288000  # Tingkatkan buffer menjadi 500 MB
git config --global http.lowSpeedLimit 0       # Nonaktifkan batas kecepatan minimum
git config --global http.lowSpeedTime 999999   # Tingkatkan waktu low speed

sudo mkdir -p $ANDROID_ROOT
sudo chown -R admin $ANDROID_ROOT
cd $ANDROID_ROOT
repo init -u https://github.com/SailfishOS-msmnile/manifest.git -b hybris-18.1
rm -rf .repo/local_manifests && git clone https://github.com/SourceLab081/local_manifests --depth 1 -b hybris-18.1 .repo/local_manifests
repo sync --fetch-submodules -j$(nproc --all)
./hybris-patches/apply-patches.sh --mb
source build/envsetup.sh
#export USE_CCACHE=1
breakfast $DEVICE
make -j$(nproc --all) hybris-hal droidmedia
EOF

mkdir sailfishos
export PLATFORM_SDK_ROOT=$curDir/sailfishos
curl -k -O https://releases.sailfishos.org/sdk/installers/latest/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2
TARBALL=ubuntu-focal-20210531-android-rootfs.tar.bz2
curl -O https://releases.sailfishos.org/ubu/$TARBALL

sudo mkdir -p $PLATFORM_SDK_ROOT/sdks/sfossdk
sudo tar --numeric-owner -p -xjf Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 -C $PLATFORM_SDK_ROOT/sdks/sfossdk
echo "export PLATFORM_SDK_ROOT=$PLATFORM_SDK_ROOT" >> ~/.bashrc
#echo 'alias sfossdk=$PLATFORM_SDK_ROOT/sdks/sfossdk/sdk-chroot' >> ~/.bashrc; exec bash
echo 'alias sfossdk=$curDir/proot.sh' >> ~/.bashrc; 
echo 'PS1="PlatformSDK $PS1"' >> ~/.mersdk.profile
echo '[ -d /etc/bash_completion.d ] && for i in /etc/bash_completion.d/*;do . $i;done' >> ~/.mersdk.profile
export dir=$PLATFORM_SDK_ROOT/sdks/sfossdk
sudo cp sdk_p.sh $dir
echo "test chroot first"
sudo chroot  $dir /usr/sbin/useradd -m -u 1000 admin;
sudo chroot $UBUNTU_CHROOT /bin/bash -c "chage -M 999999 $(id -nu 1000)"
sudo mount -t proc none $dir/proc
sudo mount --rbind /sys $dir/sys
sudo mount --rbind /dev $dir/dev
sudo chroot  $dir /usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin /bin/bash sdk_p.sh
#. proot.sh  $dir sdk_p.sh 

#./sfbootstrap.sh init xiaomi-fog
#./sfbootstrap.sh status
#ls -al
#./sfbootstrap.sh proot setup
