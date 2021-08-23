#!/bin/sh
# Test unicode partition names
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

dev=loop-file

# create zeroed device
truncate -s 10m $dev || fail=1

export LC_ALL=C.UTF-8
# create gpt label with named partition
part_name=$(printf 'foo\341\264\244')
parted -s $dev mklabel gpt mkpart primary ext2 1MiB 2MiB name 1 $part_name > empty 2>&1 || fail=1

# ensure there was no output
compare /dev/null empty || fail=1

# check for expected output
dd if=$dev bs=1 skip=$(($sector_size_+$sector_size_+56)) count=10 2>/dev/null | od -An -tx1 > out || fail=1
echo ' 66 00 6f 00 6f 00 24 1d 00 00' >> exp
compare exp out || fail=1

Exit $fail
