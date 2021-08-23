#!/bin/sh
# make sure that loop labels work correctly
# create an actual partition

# Copyright (C) 2013-2014 Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. "${srcdir=.}/init.sh"; path_prepend_ ../parted
path_prepend_ ../partprobe
require_root_
require_scsi_debug_module_
ss=$sector_size_

scsi_debug_setup_ sector_size=$ss dev_size_mb=90 > dev-name ||
  skip_ 'failed to create scsi_debug device'
dev=$(cat dev-name)

mke2fs -F $dev
parted -s "$dev" print > out 2>&1 || fail=1
cat <<EOF > exp
Model: Linux scsi_debug (scsi)
Disk DEVICE: 94.4MB
Sector size (logical/physical): ${ss}B/${ss}B
Partition Table: loop
Disk Flags:

Number  Start  End     Size    File system  Flags
 1      0.00B  94.4MB  94.4MB  ext2

EOF
mv out o2 && sed -e "s,$dev,DEVICE,;s/  *$//" o2 > out

compare exp out || fail=1
parted -s $dev rm 1 || fail=1
if [ -e ${dev}1 ]; then
    echo "Partition should not exist on loop device"
    fail=1
fi
partprobe $dev || fail=1
if [ -e ${dev}1 ]; then
    echo "Partition should not exist on loop device"
    fail=1
fi

mount_point="`pwd`/mnt"

# Be sure to unmount upon interrupt, failure, etc.
cleanup_fn_() { umount "$mount_point" > /dev/null 2>&1; }

# create mount point dir. and mount the just-created partition on it
mkdir $mount_point || fail=1
mount -t ext2 "${dev}" $mount_point || fail=1

# now that a partition is mounted, mklabel attempt must fail
parted -s "$dev" mklabel msdos > out 2>&1; test $? = 1 || fail=1

# create expected output file
echo "Error: Partition(s) on $dev are being used." > exp
compare exp out || fail=1

# make sure partition busy check works ( mklabel checks whole disk )
parted -s "$dev" rm 1 > out 2>&1; test $? = 1 || fail=1
# create expected output file
echo "Warning: Partition ${dev} is being used. Are you sure you want to continue?" > exp
compare exp out || fail=1

umount "$mount_point"

# make sure partprobe cleans up stale partition devices
parted -s $dev mklabel msdos mkpart primary ext2 0% 100% || fail=1
if [ ! -e ${dev}1 ]; then
    echo "Partition doesn't exist on loop device"
    fail=1
fi

mke2fs -F $dev
partprobe $dev || fail=1
if [ -e ${dev}1 ]; then
    echo "Partition should not exist on loop device"
    fail=1
fi

# make sure new loop label removes old partitions > 1
parted -s $dev mklabel msdos mkpart primary ext2 0% 50% mkpart primary ext2 50% 100% || fail=1
parted -s $dev mklabel loop || fail=1
if [ -e ${dev}2 ]; then
    echo "Partition 2 not removed"
    fail=1
fi

Exit $fail
