#!/bin/sh
# Test creating a msdos partition over a GPT partition with
# fdisk which doesn't remove the GPT partitions, only the PMBR

# Copyright (C) 2009-2014 Free Software Foundation, Inc.

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

ss=$sector_size_
dev=loop-file

# Create a GPT partition table.
dd if=/dev/null of=$dev bs=$ss seek=80 2> /dev/null || framework_failure
parted -s $dev mklabel gpt > out 2>&1 || framework_failure_
compare /dev/null out || framework_failure_

# Create an MSDOS partition table in another file.
dd if=/dev/null of=m bs=$ss seek=80 2> /dev/null || framework_failure
parted -s m mklabel msdos > out 2>&1 || framework_failure_
compare /dev/null out || framework_failure_

# Transplant the MSDOS MBR into the GPT-formatted image.
dd if=m of=$dev bs=$ss count=1 conv=notrunc || framework_failure_

# Now, try to create a GPT partition table in $dev.
# Before, parted would prompt, asking about the apparent inconsistency.
parted -s $dev mklabel gpt > out 2>&1 || fail=1
# expect no output
compare /dev/null out || fail=1

Exit $fail
