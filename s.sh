mkdir bckp_;cd bckp_
wget https://github.com/SourceLab081/files/raw/refs/heads/main/30.0.ignore.cil && mv 30.0.ignore.cil ../system/sepolicy/private/compat/30.0/30.0.ignore.cil
wget https://github.com/SourceLab081/files/raw/refs/heads/main/31.0.ignore.cil && mv 31.0.ignore.cil ../system/sepolicy/private/compat/31.0/31.0.ignore.cil
wget https://github.com/SourceLab081/files/raw/refs/heads/main/32.0.ignore.cil && mv 32.0.ignore.cil ../system/sepolicy/private/compat/32.0/32.0.ignore.cil
cd ..
cp system/sepolicy/private/compat/30.0/30.0.ignore.cil system/sepolicy/prebuilts/api/33.0/private/compat/30.0/30.0.ignore.cil
cp system/sepolicy/private/compat/31.0/31.0.ignore.cil system/sepolicy/prebuilts/api/33.0/private/compat/31.0/31.0.ignore.cil
cp system/sepolicy/private/compat/32.0/32.0.ignore.cil system/sepolicy/prebuilts/api/33.0/private/compat/32.0/32.0.ignore.cil
