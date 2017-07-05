#!/bin/bash

DEVICE=$1

export ARCH=arm64

export PATH=/home/devries/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin:$PATH

export CROSS_COMPILE=aarch64-linux-gnu-

if [ "$DEVICE" = "plus" ]; then
    make exynos8895-dream2lte_eur_open_defconfig
else
    make exynos8895-dreamlte_eur_open_defconfig
fi

make -j8

rm arch/arm64/boot/dts/exynos/*.dtb

make dtbs

./dtbTool -o dt.img -s 2048 -d arch/arm64/boot/dts/exynos/

if [ "$DEVICE" = "plus" ]; then
    ./mkbootfs ramdisk_plus | lzma > ramdisk.packed
else
    ./mkbootfs ramdisk | lzma > ramdisk.packed
fi

./mkbootimg \
      --kernel arch/arm64/boot/Image \
      --ramdisk ramdisk.packed \
      --cmdline "" \
      --base 0x10000000 \
      --pagesize 2048 \
      --dt dt.img \
      --ramdisk_offset 0x01000000 \
      --tags_offset 0x00000100 \
      --output boot.img

echo SEANDROIDENFORCE >> boot.img
if [ "$DEVICE" = "plus" ]; then
    mv boot.img dream2lte.img
else
    tar -cvf boot.tar boot.img
    mv boot.img dreamlte.img
fi
