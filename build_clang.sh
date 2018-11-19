#!/bin/bash
KERNEL_DIR="/mnt/Building/renderzenith_josh"
KBUILD_OUTPUT="$KERNEL_DIR/out"
ZIP_DIR="/mnt/Building/AnyKernel2-render"
MODULES_DIR="$ZIP_DIR/ramdisk/renderzenith/modules"
#CLANG_TC="/mnt/Building/infected-clang-8.x/bin/clang"
GCC_TC="/mnt/Building/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu/bin/aarch64-linux-gnu-"
export USE_CCACHE=1
make O=$KBUILD_OUTPUT clean
make O=$KBUILD_OUTPUT mrproper
make O=$KBUILD_OUTPUT ARCH=arm64 oneplus5_defconfig
export VARIANT="OP5T-OOS-O-EAS"
export HASH=`git rev-parse --short=8 HEAD`
export KERNEL_ZIP="RZ-$VARIANT-$(date +%y%m%d)-$HASH"
export LOCALVERSION=~`echo $KERNEL_ZIP`
export CLANG_PATH=/mnt/Building/infected-clang-8.x/bin/clang
export KBUILD_BUILD_USER=infected_
export KBUILD_BUILD_HOST=infected-labs
export KBUILD_COMPILER_STRING=$($CLANG_PATH --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
ccache make -j$(nproc --all) O=$KBUILD_OUTPUT \
                      ARCH=arm64 \
                      CC=$CLANG_PATH \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=$GCC_TC
find $KBUILD_OUTPUT -name '*.ko' -exec cp -v {} $MODULES_DIR \;
${GCC_TC}strip --strip-unneeded $MODULES_DIR/*.ko
find $MODULES_DIR -name '*.ko' -exec $KBUILD_OUTPUT/scripts/sign-file sha512 $KBUILD_OUTPUT/certs/signing_key.pem $KBUILD_OUTPUT/certs/signing_key.x509 {} \;
cd $KBUILD_OUTPUT/arch/arm64/boot
cp -v Image.gz-dtb /mnt/Building/AnyKernel2-render/zImage                     
cd /mnt/Building/AnyKernel2-render
zip -r9 RZ-$VARIANT-$(date +%y%m%d)-$HASH.zip *
mv -v RZ-$VARIANT-$(date +%y%m%d)-$HASH.zip /mnt/Building/Out_Zips
echo -e "${green}"
echo "-------------------"
echo "Build Completed"
echo "-------------------"
echo -e "${restore}"
