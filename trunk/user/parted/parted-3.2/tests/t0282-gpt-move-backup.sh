#!/bin/sh
# put backup copy gpt in the wrong place, ensure that
# parted offers to fix

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

ss=$sector_size_
n_sectors=5000

dd if=/dev/null of=$dev bs=$ss seek=$n_sectors || fail=1

# create gpt label
parted -s $dev mklabel gpt > empty 2>&1 || fail=1
compare /dev/null empty || fail=1

# print the empty table
parted -m -s $dev unit s print > t 2>&1 || fail=1
sed "s,.*/$dev:,$dev:," t > out || fail=1

# check for expected output
printf "BYT;\n$dev:${n_sectors}s:file:$sector_size_:$sector_size_:gpt::;\n" \
  > exp || fail=1
compare exp out || fail=1

# move the backup
gpt-header-move $dev || fail=1

# printing must warn, but not fix in script mode
parted -s $dev print > out 2>&1 || fail=1

# Transform the actual output, to avoid spurious differences when
# $PWD contains a symlink-to-dir.  Also, remove the ^M      ...^M bogosity.
# normalize the actual output
mv out o2 && sed -e "s,/.*/$dev,DEVICE,;s,   *,,g;s, $,," \
                      -e "s,^.*/lt-parted: ,parted: ," o2 > out

# check for expected diagnostic
cat <<EOF > exp || fail=1
Error: The backup GPT table is not at the end of the disk, as it should be.  Fix, by moving the backup to the end (and removing the old backup)?
Model:  (file)
Disk DEVICE: 2560kB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start  End  Size  File system  Name  Flags

EOF
compare exp out || fail=1

# now we fix
printf 'f\n' | parted ---pretend-input-tty $dev print > out 2>&1 || fail=1

# Transform the actual output, to avoid spurious differences when
# $PWD contains a symlink-to-dir.  Also, remove the ^M      ...^M bogosity.
# normalize the actual output
mv out o2 && sed -e "s,/.*/$dev,DEVICE,;s,   *,,g;s, $,," \
                      -e "s,^.*/lt-parted: ,parted: ," o2 > out

# check for expected diagnostic
emit_superuser_warning > exp || fail=1
cat <<EOF >> exp || fail=1
Error: The backup GPT table is not at the end of the disk, as it should be.  Fix, by moving the backup to the end (and removing the old backup)?
Fix/Ignore? f
Model:  (file)
Disk DEVICE: 2560kB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start  End  Size  File system  Name  Flags

EOF
compare exp out || fail=1


# Now should not warn

parted -s $dev print > err 2>&1 || fail=1
grep Error: err > k ; mv k err
compare /dev/null err || fail=1

Exit $fail
