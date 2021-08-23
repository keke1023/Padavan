#!/bin/sh
# exercise the resize sub-command
# based on t3000-resize-fs.sh test

# Copyright (C) 2009-2011 Free Software Foundation, Inc.

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
require_scsi_debug_module_

ss=$sector_size_

default_start=1024s
default_end=2048s

# create memory-backed device
scsi_debug_setup_ dev_size_mb=5 > dev-name ||
  skip_ 'failed to create scsi_debug device'
dev=$(cat dev-name)

# TODO test simple shrink
# TODO test expand past end of the disk
# TODO test expand past begin of next partition
# TODO test shrink before start
# TODO test everything with GPT
# TODO more tests with extended/logical partitions

parted -s $dev mklabel msdos > out 2> err || fail=1
# expect no output
compare /dev/null out || fail=1
compare /dev/null err || fail=1

# ensure that the disk is large enough
dev_n_sectors=$(parted -s $dev u s p|sed -n '2s/.* \([0-9]*\)s$/\1/p')
device_sectors_required=$(echo $default_end | sed 's/s$//')
# Ensure that $dev is large enough for this test
test $device_sectors_required -le $dev_n_sectors || fail=1

# create an empty partition
parted -a minimal -s $dev mkpart primary $default_start $default_end > out 2>&1 || fail=1
compare /dev/null out || fail=1

# print partition table
parted -m -s $dev u s p > out 2>&1 || fail=1

# FIXME: check expected output

# wait for new partition device to appear
wait_for_dev_to_appear_ ${dev}1 || { warn_ "${dev}1 did not appear"  fail=1; }
sleep 1


# extend the filesystem to end on sector 4096
new_end=4096s
parted -s $dev resizepart 1 $new_end > out 2> err || fail=1
# expect no output
compare /dev/null out || fail=1
compare /dev/null err || fail=1

# print partition table
parted -m -s $dev u s p > out 2>&1 || fail=1

sed -n 3p out > k && mv k out || fail=1
printf "1:$default_start:$new_end:3073s:::$ms;\n" > exp || fail=1
compare exp out || fail=1

# Remove the partition explicitly, so that mklabel doesn't evoke a warning.
parted -s $dev rm 1 || fail=1

# Create a clean partition table for the next iteration.
parted -s $dev mklabel msdos > out 2>&1 || fail=1
# expect no output
compare /dev/null out || fail=1

Exit $fail
