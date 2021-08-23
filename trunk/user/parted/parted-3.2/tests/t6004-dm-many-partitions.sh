#!/bin/sh
# device-mapper: create many partitions
# This would not create partitions > 16 when using device-mapper

# Copyright (C) 2012, 2014 Free Software Foundation, Inc.

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

ss=$sector_size_
ns=300
n_partitions=20
start_sector=34
loop_file=loop-file-$$
dm_name=dm-test-$$

cleanup_() {
    dmsetup remove $dm_name
    test -n "$dev" && losetup -d "$dev"
    rm -f $loop_file;
}

# create a file large enough to hold a GPT partition table
dd if=/dev/null of=$loop_file bs=$ss seek=$ns || framework_failure
dev=$(losetup --show -f $loop_file) || framework_failure
dmsetup create $dm_name --table "0 $ns linear $dev 0" || framework_failure

cmd=
for ((i=1; i<=$n_partitions; i+=1)); do
  s=$((start_sector + i - 1))
  cmd="$cmd mkpart p$i ${s}s ${s}s"
done
parted -m -a min -s /dev/mapper/$dm_name mklabel gpt $cmd > /dev/null 2>&1 || fail=1

# Make sure all the partitions appeared under /dev/mapper/
for ((i=1; i<=$n_partitions; i+=1)); do
    if [ ! -e "/dev/mapper/${dm_name}p$i" ]; then
        fail=1
        break
    fi
    # remove the partitions as we go, otherwise cleanup won't work.
    dmsetup remove /dev/mapper/${dm_name}p$i
done

Exit $fail
