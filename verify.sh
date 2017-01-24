#!/bin/bash

# mkdir boot
# unpackbootimg -i 09-boot.img -o boot
# cd boot
# mkbootimg --kernel 09-boot.img-zImage --ramdisk 09-boot.img-ramdisk.gz --cmdline "`cat 09-boot.img-cmdline`" --base `cat 09-boot.img-base` --pagesize `cat 09-boot.img-pagesize` --dt 09-boot.img-dtb --kernel_offset `cat 09-boot.img-kerneloff` --ramdisk_offset `cat 09-boot.img-ramdiskoff` --tags_offset `cat 09-boot.img-tagsoff` --output mynew.img
# dd if=../09-boot.img of=signature.bin bs=1 count=256 skip=$(ls -la mynew.img | awk '{print $5}')
# cd ..
# binwalk -e 05-aboot.img

# extract aboot signature
# dd if=05-aboot.img of=signature.bin bs=1 count=256 skip=$(od -A d -t x4 05-aboot.img | awk --non-decimal-data '/^0000016/ { i=sprintf("%d\n","0x"$3); print (i+40)}')

# extract aboot image
# binwalk -e 05-aboot.img
# how sha256 was calculated?
# neither
# dd if=05-aboot.img of=aboot-base.img bs=1 count=$(od -A d -t x4 05-aboot.img | awk --non-decimal-data '/^0000016/ { i=sprintf("%d\n","0x"$3); print (i)}') skip=40
# nor
# dd if=05-aboot.img of=aboot-base.img bs=1 count=$(od -A d -t x4 05-aboot.img | awk --non-decimal-data '/^0000016/ { i=sprintf("%d\n","0x"$3); print (i+40)}')
# work
# openssl dgst -sha256 -sign private_key -out signature.bin aboot-base.img ?

# print cert in text mode: openssl x509 -inform der -in 1768B.crt -text -noout

NAME=$1
IMG=${NAME}/mynew.img
SIG=${NAME}/signature.bin

IMG=aboot-base.img
SIG=signature.bin

CALC_SHA256=$(sha256sum ${IMG} | awk '{print $1}')

for i in `find . -name *.crt`; do
  ORIG_SHA256=$(openssl rsautl -inkey <(openssl x509 -pubkey -noout -inform der -in ${i} 2>/dev/null) -pubin -in ${SIG} 2>/dev/null | hexdump -ve '/1 "%02x"')
  if [ "${ORIG_SHA256}" != "" ]; then
    echo "sha256 was decrypted using ${i} key - ${ORIG_SHA256}"
  fi
  if [ "${ORIG_SHA256}" = "${CALC_SHA256}" ]; then
    echo "sha256 ${ORIG_SHA256}"
    echo "$i"
  fi
done
