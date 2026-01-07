# how to use : . uploadToGithub.sh filename
if [ ! -f github-release ]; then
   wget https://github.com/github-release/github-release/releases/download/v0.10.0/linux-amd64-github-release.bz2
   bunzip2 linux-amd64-github-release.bz2
   mv linux-amd64-github-release github-release
   chmod +x github-release
fi
# change the tag if not for kernel
tag='v0.2.2'
./github-release upload \
    -s $SECRET_NUM \
    -u SourceLab081 \
    -r uploadz \
    -t $tag \
    -n $1 \
    -f $1
