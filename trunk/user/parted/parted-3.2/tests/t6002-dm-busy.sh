#!/bin/sh
# ensure that parted can alter a partition on a dmraid disk
# while another one is mounted

# Copyright (C) 2008-2014 Free Software Foundation, Inc.

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

require_root_

# We could make this work for arbitrary sector size, but I'm lazy.
require_512_byte_sector_size_

test "x$ENABLE_DEVICE_MAPPER" = xyes \
  || skip_ "no device-mapper support"

# Device maps names - should be random to not conflict with existing ones on
# the system
linear_=plinear-$$

d1=
f1=
dev=
cleanup_fn_() {
    umount "${dev}p2" > /dev/null 2>&1
    dmsetup remove ${linear_}p1
    dmsetup remove ${linear_}p2
    dmsetup remove $linear_
    test -n "$d1" && losetup -d "$d1"
    rm -f "$f1"
}

f1=$(pwd)/1; d1=$(loop_setup_ "$f1") \
  || fail=1

# setup: create a mapping
n=204800
echo "0 $n linear $d1 0" | dmsetup create $linear_ || fail=1
dev="/dev/mapper/$linear_"

# Create msdos partition table
parted -s $dev mklabel msdos > out 2>&1 || fail=1
compare /dev/null out || fail=1

parted -s $dev -a none mkpart primary fat32 1s 1000s > out 2>&1 || fail=1
compare /dev/null out || fail=1

parted -s $dev -a none mkpart primary fat32 1001s 200000s > out 2>&1 || fail=1
compare /dev/null out || fail=1

# wait for new partition device to appear
wait_for_dev_to_appear_ ${dev}p2 || fail_ ${dev}p2 did not appear

mkfs.vfat -F 32 ${dev}p2 || fail_ mkfs.vfat failed

mount_point=$(pwd)/mnt

mkdir $mount_point || fail=1
mount "${dev}p2" "$mount_point" || fail=1

# Removal of unmounted partition must succeed.
parted -s "$dev" rm 1 > /dev/null 2>&1 || fail=1

# Removal of mounted partition must fail.
parted -s "$dev" rm 2 > /dev/null 2>&1 && fail=1

parted -m -s "$dev" u s print > out 2>&1 || fail=1
sed "s,^$dev,DEV," out > k; mv k out

# Create expected output file.
cat <<EOF >> exp || fail=1
BYT;
DEV:${n}s:dm:512:512:msdos:Linux device-mapper (linear):;
2:1001s:200000s:199000s:fat32::lba;
EOF

compare exp out || fail=1

Exit $fail
