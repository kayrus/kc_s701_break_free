#!/system/bin/sh

# cat /sys/kernel/mmc_protect/status
/system/xbin/insmod /system/lib/modules/mmc_protect.ko
echo -n "mmcblk0p19" > /sys/kernel/mmc_protect/clear
