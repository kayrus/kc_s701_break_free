#!/bin/sh

adb push dcow /data/local/tmp/
adb shell chmod 755 /data/local/tmp/dcow
adb push dload_mode.ko /data/local/tmp/
adb shell /data/local/tmp/dcow /data/local/tmp/dload_mode.ko /system/lib/modules/pronto/pronto_wlan.ko
adb shell rm /data/local/tmp/dload_mode.ko
adb shell rm /data/local/tmp/dcow
echo "Now toggle WiFi and press enter"
read tmp
adb reboot
