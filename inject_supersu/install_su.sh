#!/bin/sh -e

SRC=19-system.img
DST=19-system-root.img
PREFIX=/system
# http://www.supersu.com/download
# https://s3-us-west-2.amazonaws.com/supersu/download/zip/SuperSU-v2.79-201612051815.zip
SUPERSU_ZIP="SuperSU-v2.79-201612051815.zip"
# https://forum.xda-developers.com/android/software-hacking/tool-busybox-flashable-archs-t3348543
BUSYBOX_ZIP="Busybox-1.26.2-YDS-ARM.zip"
ARCH=armv7
SELINUX="-sel"
# uncomment when you don't need selinux
# SELINUX=""

if [ ! -f "${SUPERSU_ZIP}" ]; then
  echo "Please download SuperSU ZIP: ${SUPERSU_ZIP}"
  exit 1
fi

if [ ! -f "${BUSYBOX_ZIP}" ]; then
  echo "Please download Busybox ZIP: ${BUSYBOX_ZIP}"
  exit 1
fi

mkdir -p ${PREFIX}
cp -p ${SRC} ${DST}
mount -oro ${DST} ${PREFIX}

if [ -f "${PREFIX}/xbin/su" ]; then
  echo "SuperSU was already installed"
  umount ${PREFIX}
  exit 1
fi

umount ${PREFIX}
mount ${DST} ${PREFIX}

# file_owner file_mode_bits selinux_context_reference_file destination
setprop() {
  chown $1 $4
  chmod $2 $4
  if [ "${SELINUX}" != "" ]; then
    chcon -h --reference="$3" $4
  fi
}

secopy() {
  cp $4 $5
  setprop $1 $2 $3 $5
}

# unzip files from SuperSU.zip
su_unpack() {
  unzip -p ${SUPERSU_ZIP} $4 > $5
  setprop $1 $2 $3 $5
}

# unzip files from busybox.zip
bb_unpack() {
  if echo "$4" | grep -q '\.xz$'; then
    unzip -p ${BUSYBOX_ZIP} $4 | xzcat > $5
  else
    unzip -p ${BUSYBOX_ZIP} $4 > $5
  fi
  setprop $1 $2 $3 $5
}

DEFAULT_SECONTEXT_SOURCE="${PREFIX}/etc/vold.fstab"
SUGOTE_SECONTEXT_SOURCE="${PREFIX}/bin/app_process"
DEFAULT_OWNER="root.root"

# Scripts, modules and executables to disable Kyocera kernel security and set phone into download mode
secopy ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} insmod_as_wlan ${PREFIX}/xbin/insmod_as_wlan
secopy ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} disable-security.sh ${PREFIX}/xbin/disable-security.sh
secopy ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} dload-mode.sh ${PREFIX}/xbin/dload-mode.sh
secopy ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} read-write.sh ${PREFIX}/xbin/read-write.sh
secopy ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} disable_kc_security.ko ${PREFIX}/lib/modules/disable_kc_security.ko
secopy ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} dload_mode.ko ${PREFIX}/lib/modules/dload_mode.ko
secopy ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} mmc_protect.ko ${PREFIX}/lib/modules/mmc_protect.ko

# disable "Inappropriate application may have been installed" infobar on Kyocera devices.
chmod 0000 ${PREFIX}/vendor/bin/akscd

secopy ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} install-recovery.sh ${PREFIX}/etc/install-recovery.sh
if [ "${SELINUX}" != "" ]; then
  su_unpack ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} ${ARCH}/su ${PREFIX}/xbin/su
else
  su_unpack ${DEFAULT_OWNER} 6755 ${DEFAULT_SECONTEXT_SOURCE} ${ARCH}/su ${PREFIX}/xbin/su
fi
mkdir -p ${PREFIX}/bin/.ext
setprop ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} ${PREFIX}/bin/.ext
if [ "${SELINUX}" != "" ]; then
  su_unpack ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} ${ARCH}/su ${PREFIX}/bin/.ext/.su
else
  su_unpack ${DEFAULT_OWNER} 6755 ${DEFAULT_SECONTEXT_SOURCE} ${ARCH}/su ${PREFIX}/bin/.ext/.su
fi
su_unpack ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} ${ARCH}/su ${PREFIX}/xbin/daemonsu
su_unpack ${DEFAULT_OWNER} 0755 ${SUGOTE_SECONTEXT_SOURCE} ${ARCH}/su ${PREFIX}/xbin/sugote
su_unpack ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} ${ARCH}/supolicy ${PREFIX}/xbin/supolicy
su_unpack ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} ${ARCH}/libsupol.so ${PREFIX}/lib/libsupol.so
cp -a ${PREFIX}/bin/mksh ${PREFIX}/xbin/sugote-mksh
chown ${DEFAULT_OWNER} ${PREFIX}/xbin/sugote-mksh
bb_unpack ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} busybox${SELINUX}.xz ${PREFIX}/xbin/busybox
bb_unpack ${DEFAULT_OWNER} 0755 ${DEFAULT_SECONTEXT_SOURCE} ssl_helper ${PREFIX}/xbin/ssl_helper

for i in `cat busybox${SELINUX}.list`; do
  # "su" symlink is excluded from busybox list
  ln -s busybox ${PREFIX}/xbin/${i}
  if [ "${SELINUX}" != "" ]; then
    chcon -h --reference=${DEFAULT_SECONTEXT_SOURCE} ${PREFIX}/xbin/${i}
  fi
  chown -h 0.2000 ${PREFIX}/xbin/${i}
done

etc="${PREFIX}/etc"
bb_unpack ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} addusergroup.sh addusergroup.sh
. ./addusergroup.sh

setprop ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} ${etc}/passwd
setprop ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} ${etc}/group
secopy ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} resolv.conf ${etc}/resolv.conf
su_unpack ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} common/Superuser.apk ${PREFIX}/app/Superuser.apk

# This fix allows apps to write to sdcard
if [ "${SELINUX}" != "" ]; then
  secopy ${DEFAULT_OWNER} 0644 ${DEFAULT_SECONTEXT_SOURCE} platform.xml ${PREFIX}/etc/permissions/platform.xml
fi

echo 3 > /proc/sys/vm/drop_caches
umount ${PREFIX}
tune2fs -C 0 -M '' ${DST}

echo "SuperSU was successfully injected into ${DST}"
