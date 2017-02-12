#!/bin/sh

adb push dcow /data/local/tmp/
adb shell chmod 755 /data/local/tmp/dcow
adb push disable_kc_security.ko /data/local/tmp/
adb push mmc_protect.ko /data/local/tmp/
adb push insmod_as_wlan /data/local/tmp/
adb shell chmod 755 /data/local/tmp/insmod_as_wlan
adb push run-as /data/local/tmp/
adb shell /data/local/tmp/dcow /data/local/tmp/run-as /system/bin/run-as
adb shell run-as /data/local/tmp/insmod_as_wlan /data/local/tmp/disable_kc_security.ko
adb shell run-as insmod /data/local/tmp/mmc_protect.ko
adb shell run-as cat /sys/kernel/mmc_protect/status
adb shell "run-as sh -c 'echo -n mmcblk0p16 > /sys/kernel/mmc_protect/clear'"
adb shell rm /data/local/tmp/disable_kc_security.ko
adb shell rm /data/local/tmp/dcow
adb shell rm /data/local/tmp/mmc_protect.ko
adb shell rm /data/local/tmp/insmod_as_wlan
adb shell rm /data/local/tmp/run-as
