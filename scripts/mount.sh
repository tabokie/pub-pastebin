# usage: mount.sh nvme1n1 /data
set -ueo pipefail

DEVICE=/dev/$1
MNT=$2
if [[ $DEVICE == *"nvme"* ]]; then
  PARTITION=${DEVICE}p1
else
  PARTITION=${DEVICE}1
fi

if [ -f ${PARTITION} ] ; then
  sudo parted -s -a optimal $DEVICE mklabel gpt -- mkpart primary ext4 1 -1
  sleep 2
  sudo mkfs.ext4 $PARTITION
fi
sudo mkdir -p ${MNT}
sudo mount -t ext4 $PARTITION $MNT -o defaults,barrier,nodelalloc,nodiratime,noatime
