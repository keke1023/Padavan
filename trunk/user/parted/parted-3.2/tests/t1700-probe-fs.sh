#!/bin/sh
# Probe Ext2, Ext3 and Ext4 file systems

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
require_512_byte_sector_size_

dev=loop-file
ss=$sector_size_
n_sectors=$((257*1024))

for type in ext2 ext3 ext4 btrfs xfs nilfs2 ntfs vfat hfsplus; do

  ( mkfs.$type 2>&1 | grep -i '^usage' ) > /dev/null \
      || { warn_ "$ME: no $type support"; continue; }

  fsname=$type
  force=
  case $type in
      ext*) force=-F;;
      xfs) force=-f;;
      nilfs2) force=-f;;
      ntfs) force=-F;;
      vfat) fsname=fat16;;
      hfsplus) fsname=hfs+;;
  esac

  # create an $type file system
  if [ "$type" = "xfs" ]; then
      # Work around a problem with s390
      mkfs.xfs -ssize=$ss -dfile,name=$dev,size=${n_sectors}s || fail=1
  else
      dd if=/dev/null of=$dev bs=$ss seek=$n_sectors >/dev/null || fail=1
      mkfs.$type $force $dev || { warn_ $ME: mkfs.$type failed; fail=1; continue; }
  fi

  # probe the $type file system
  parted -m -s $dev u s print >out 2>&1 || fail=1
  grep '^1:.*:'$fsname'::;$' out || { cat out; fail=1; }
  rm $dev
done

# Some features should indicate ext4 by themselves.
for feature in uninit_bg flex_bg; do
  # create an ext3 file system
  dd if=/dev/null of=$dev bs=1024 seek=4096 >/dev/null || fail=1
  mkfs.ext3 -F $dev >/dev/null || skip_ "mkfs.ext3 failed"

  # set the feature
  tune2fs -O $feature $dev || skip_ "tune2fs failed"

  # probe the file system, which should now be ext4
  parted -m -s $dev u s print >out 2>&1 || fail=1
  grep '^1:.*:ext4::;$' out || fail=1
  rm $dev
done

Exit $fail
