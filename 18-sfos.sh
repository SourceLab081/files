set -x
git clone https://github.com/SourceLab081/sfbootstrap --depth 1 -b master
cd sfbootstrap
echo "run the command"

./sfbootstrap.sh init xiaomi-fog
./sfbootstrap.sh status
./sfbootstrap.sh chroot setup
./sfbootstrap.sh sync
./sfbootstrap.sh build hal
./sfbootstrap.sh build packages
