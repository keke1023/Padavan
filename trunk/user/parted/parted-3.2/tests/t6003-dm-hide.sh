#!/bin/sh
# ensure that parted -l only shows dmraid device-mapper devices

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

test "x$ENABLE_DEVICE_MAPPER" = xyes \
  || skip_ "no device-mapper support"

# Device maps names - should be random to not conflict with existing ones on
# the system
linear_=plinear-$$

d1=
f1=
dev=
cleanup_fn_() {
    # Insist.  Sometimes the initial removal fails (race?).
    # When that happens, a second removal appears to be sufficient.
    dmsetup remove $linear_ || dmsetup remove $linear_

    test -n "$d1" && losetup -d "$d1"
    rm -f "$f1"
}

f1=$(pwd)/1; d1=$(loop_setup_ "$f1") \
  || fail=1

# setup: create a mapping
echo 0 2048 linear $d1 0 | dmsetup create $linear_ || fail=1
dev=/dev/mapper/$linear_

# No "DMRAID-" UUID prefix, hence the device should not show up.
parted -s -l >out 2>&1
grep "^Disk $dev:" out && fail=1

# Unless we perform both dmsetup-remove *and* losetup -d,
# the following dmsetup-create would fail with EBUSY.
dmsetup remove $linear_
losetup -d "$d1" || fail=1
# Reopen (or get new) loop device.
d1=$(loop_setup_ "$f1") || fail=1

# This time, use a fake UUID.
echo 0 2048 linear $d1 0 | dmsetup create $linear_ -u "DMRAID-fake-$$" || fail=1

# Thus, the device should now show up.
parted -s -l >out 2>&1
grep "^Disk $dev:" out || fail=1

Exit $fail
