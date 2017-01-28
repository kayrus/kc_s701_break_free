#!/bin/bash -e

BS=512
COUNT=1024
nextblock=0

IMG=19-system-root.img
DEST=/dev/sdb19

if [ ! -f ${IMG} ]; then
  echo "Source file is not available: ${IMG}"
  exit 1
fi

if [ ! -b ${DEST} ]; then
  echo "Destination device is not available: ${IMG}"
  exit 1
fi

IMG_SIZE=$(du -b ${IMG} | cut -f1)
ITERATIONS=$((IMG_SIZE/(BS*COUNT)))

DEST_SIZE=$(blockdev --getsize64 ${DEST})

if [ "${IMG_SIZE}" != "${DEST_SIZE}" ]; then
  echo "Image size and destination size don't equal"
  exit 1
fi

for i in $(seq 1 ${ITERATIONS}); do
  echo $i
  DEST_SHA256=$(dd if=${DEST} bs=${BS} skip=${nextblock} count=${COUNT} status=none | sha256sum | cut -d' ' -f1)
  IMG_SHA256=$(dd if=${IMG} bs=${BS} skip=${nextblock} count=${COUNT} status=none | sha256sum | cut -d' ' -f1)
  if [ "${DEST_SHA256}" != "${IMG_SHA256}" ]; then
    echo dd if=${IMG} of=${DEST} bs=${BS} seek=${nextblock} skip=${nextblock} count=${COUNT} oflag=direct
    dd if=${IMG} of=${DEST} bs=${BS} seek=${nextblock} skip=${nextblock} count=${COUNT} oflag=direct
  fi
  nextblock=$((nextblock+COUNT))
  echo "nextblock = ${nextblock}"
done

sync
echo 3 > /proc/sys/vm/drop_caches

echo "System partition has been written"
