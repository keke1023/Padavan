#!/bin/sh
# With parted-3.1, a MAC partition table that specified a sector size (B)
# larger than what the kernel told us (SS) would cause parted to read B
# bytes into a smaller, SS-byte buffer, clobbering heap storage.

# Copyright (C) 2012-2014 Free Software Foundation, Inc.

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

dd if=/dev/null of=$dev bs=$ss seek=2000 || framework_failure
parted -s $dev mklabel mac > out 2>&1 || fail=1
# expect no output
compare /dev/null out || fail=1

# Poke a big-endian 1024 into the 2-byte block_size slot.
perl -e 'print pack("S>", 1024)'|dd of=$dev bs=1 seek=2 count=2 conv=notrunc \
  || fail=1

printf 'ignore\ncancel\n' > in || framework_failure

cat <<EOF > exp
BYT;
FILE:2000s:file:1024:512:unknown::;
EOF

parted -m ---pretend-input-tty $dev u s p < in > err 2>&1 || fail=1
sed 's,   *,,g;s!^/[^:]*:!FILE:!' err \
  | grep -Evi '^(ignore|fix|error|warning)' \
  > k && mv k err || fail=1
compare exp err || fail=1

Exit $fail
