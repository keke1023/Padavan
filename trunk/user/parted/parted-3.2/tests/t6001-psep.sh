#!/bin/sh
# ensure that parted names partitions on dm disks correctly

# Copyright (C) 2011-2014 Free Software Foundation, Inc.

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
(dmsetup --help) > /dev/null 2>&1 || skip_test_ "No dmsetup installed"

# Device maps names - should be random to not conflict with existing ones on
# the system
linear_=plinear-$$
linear2_=plinear-$$foo

d1= d2=
f1= f2=
cleanup_fn_() {
    dmsetup remove ${linear_}p1
    dmsetup remove $linear_
    dmsetup remove ${linear2_}1
    dmsetup remove $linear2_
    test -n "$d1" && losetup -d "$d1"
    test -n "$d2" && losetup -d "$d2"
    rm -f "$f1 $f2";
}

loop_file_1=loop-file-1-$$
loop_file_2=loop-file-2-$$

d1=$(loop_setup_ $loop_file_1) || framework_failure
d1_size=$(blockdev --getsz $d1)
d2=$(loop_setup_ $loop_file_2) || framework_failure
d2_size=$(blockdev --getsz $d2)

dmsetup create $linear_ --table "0 $d1_size linear $d1 0" || framework_failure
dev="/dev/mapper/$linear_"

# Create msdos partition table
parted -s $dev mklabel msdos mkpart primary fat32 1m 5m > out 2>&1 || fail=1
compare /dev/null out || fail=1

#make sure device name is correct
test -e ${dev}p1 || fail=1

#repeat on name not ending in a digit
# setup: create a mapping
dmsetup create $linear2_ --table "0 $d2_size linear $d2 0" || framework_failure
dev="/dev/mapper/$linear2_"

# Create msdos partition table
parted -s $dev mklabel msdos mkpart primary fat32 1m 5m > out 2>&1 || fail=1
compare /dev/null out || fail=1

#make sure device name is correct
test -e ${dev}1 || fail=1

if [ -n "$fail" ]; then
    ls /dev/mapper
fi

Exit $fail
