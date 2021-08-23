#!/bin/sh
# ensure parted can ignore partitions that overlap or are
# longer than the disk and remove them

# Copyright (C) 2009-2012, 2014 Free Software Foundation, Inc.

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

. "${srcdir=.}/init.sh"; path_prepend_ ../parted $srcdir
require_512_byte_sector_size_
dev=loop-file

truncate -s 10m $dev || framework_failure
parted -s $dev mklabel msdos || framework_failure
msdos-overlap $dev || framework_failure

# print the empty table
parted ---pretend-input-tty $dev <<EOF > out 2>&1 || fail=1
print
ignore
rm
2
EOF

# $PWD contains a symlink-to-dir.  Also, remove the ^M      ...^M bogosity.
# normalize the actual output
mv out o2 && sed -e "s,/.*/$dev,DEVICE,;s,   *,,g;s, $,," \
                      -e "s,^.*/lt-parted: ,parted: ," -e "s/^GNU Parted .*$/GNU Parted VERSION/" o2 > out

# check for expected output
emit_superuser_warning > exp || fail=1
cat <<EOF >> exp || fail=1
GNU Parted VERSION
Using DEVICE
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) print
Error: Can't have overlapping partitions.
Ignore/Cancel? ignore
Model:  (file)
Disk DEVICE: 10.5MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  5243kB  4194kB  primary
 2      5242kB  8000kB  2758kB  primary

(parted) rm
Partition number? 2
(parted)
EOF
compare exp out || fail=1

truncate -s 3m $dev || fail=1

# print the table, verify error, ignore it, and remove the partition
parted ---pretend-input-tty $dev <<EOF > out 2>&1 || fail=1
print
ignore
rm
1
EOF

# $PWD contains a symlink-to-dir.  Also, remove the ^M      ...^M bogosity.
# normalize the actual output
mv out o2 && sed -e "s,/.*/$dev,DEVICE,;s,   *,,g;s, $,," \
                      -e "s,^.*/lt-parted: ,parted: ," -e "s/^GNU Parted .*$/GNU Parted VERSION/" o2 > out

# check for expected output
emit_superuser_warning > exp || fail=1
cat <<EOF >> exp || fail=1
GNU Parted VERSION
Using DEVICE
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) print
Error: Can't have a partition outside the disk!
Ignore/Cancel? ignore
Model:  (file)
Disk DEVICE: 3146kB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  5243kB  4194kB  primary

(parted) rm
Partition number? 1
(parted)
EOF
compare exp out || fail=1

Exit $fail
