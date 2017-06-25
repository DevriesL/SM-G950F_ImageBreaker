#!/bin/bash

export ARCH=arm64

export PATH=/home/devries/aarch64-linux-android-4.9-kernel/bin:$PATH

export CROSS_COMPILE=aarch64-linux-android-

make exynos8895-dreamlte_eur_open_defconfig

make -j8

make dtbs

./dtbTool -o dt.img -s 2048 -d arch/arm64/boot/dts/exynos/

./mkbootfs ramdisk | lzma > ramdisk.packed

./mkbootimg \
      --kernel arch/arm64/boot/Image.gz \
      --ramdisk ramdisk.packed \
      --cmdline "" \
      --base 0x10000000 \
      --pagesize 2048 \
      --dt dt.img \
      --ramdisk_offset 0x01000000 \
      --tags_offset 0x00000100 \
      --output boot.img

tar -cvf boot.tar boot.img
