#!/bin/sh
# make sure that removing a higher numbered partition and adding a lower
# one using that space at the same time works

# Copyright (C) 2014 Free Software Foundation, Inc.

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
ss=$sector_size_

d1= f1=
cleanup_fn_()
{
  test -n "$d1" && losetup -d "$d1"
  rm -f "$f1"
}

f1=$(pwd)/1; d1=$(loop_setup_ "$f1") \
  || skip_ "is this partition mounted with 'nodev'?"

require_partitionable_loop_device_ $d1

# create one big partition
parted -s $d1 mklabel msdos mkpart primary ext2 1m 10m || fail=1

# save this table
dd if=$d1 of=saved count=1 || fail=1

# create two small partitions
parted -s $d1 mklabel msdos mkpart primary ext2 1m 5m mkpart primary ext2 5m 10m || fail=1

# restore first table and make sure partprobe works
dd if=saved of=$d1 || fail=1
partprobe $d1 || fail=1

Exit $fail
