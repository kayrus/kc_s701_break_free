#!/bin/sh

adb push dcow /data/local/tmp/
adb shell chmod 755 /data/local/tmp/dcow
adb push dload_mode.ko /data/local/tmp/
adb push run-as /data/local/tmp/
adb shell /data/local/tmp/dcow /data/local/tmp/dload_mode.ko /system/lib/modules/pronto/pronto_wlan.ko
adb shell /data/local/tmp/dcow /data/local/tmp/run-as /system/bin/run-as
adb shell run-as svc wifi disable
adb shell run-as svc wifi enable
adb shell rm /data/local/tmp/dload_mode.ko
adb shell rm /data/local/tmp/dcow
adb shell rm /data/local/tmp/run-as
adb reboot
