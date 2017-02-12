#!/bin/bash -e

adb shell "run-as chmod 666 /dev/block/mmcblk0p16"
adb push 16-system-root.img /dev/block/mmcblk0p16
adb shell sync
adb shell "run-as sh -c 'echo 3 > /proc/sys/vm/drop_caches'"

echo "System partition has been written"
