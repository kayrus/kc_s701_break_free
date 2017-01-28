#!/system/bin/sh

# If you're implementing this in a custom kernel/firmware,
# I suggest you use a different script name, and add a service
# to launch it from init.rc

# Launches SuperSU in daemon mode only on Android 4.3+.
# Nothing will happen on 4.2.x or older, unless SELinux+Enforcing.
# If you want to force loading the daemon, use "--daemon" instead

# stop Kyocera security daemon which causes "Inappropriate application may have been installed"
setprop ctl.stop akscd

/system/xbin/daemonsu --auto-daemon &
