#!/bin/sh

dd if=/dev/sdb19 of=19-system.img &
while killall -USR1 dd; do
  sleep 1
done
echo "Done"
