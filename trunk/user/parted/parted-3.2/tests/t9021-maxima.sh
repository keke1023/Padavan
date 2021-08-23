#!/bin/sh
# verify that partition maxima-querying functions work

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

dev=dev-file
PATH="..:$PATH"
export PATH

max_n_partitions()
{
  case $1 in

    # Technically, msdos partition tables have no limit on the maximum number
    # of partitions, but we pretend it is 64 due to implementation details.
    msdos) m=64;;

    gpt) m=128;;
    dvh) m=16;;
    sun) m=8;;
    mac) m=65536;;
    bsd) m=8;;
    amiga) m=128;;
    loop) m=1;;
    pc98) case $ss in 512) m=16;; *) m=64;; esac;;
    *) warn_ invalid partition table type: $1 1>&2; exit 1;;
  esac
  echo $m
}

# FIXME: add aix when/if it's supported again
for t in msdos gpt dvh sun mac bsd amiga loop pc98; do
    echo $t
    rm -f $dev
    dd if=/dev/zero of=$dev bs=$ss count=1 seek=10000 || { fail=1; continue; }
    parted -s $dev mklabel $t || { fail=1; continue; }

    #case $t in pc98) sleep 999d;; esac

    max_start=4294967295
    max_len=4294967295
    case $t in
	gpt|loop) max_start=18446744073709551615; max_len=$max_start;;
	sun) max_start=549755813760;; # 128 * (2^32-1)
    esac

    print-max $dev > out 2>&1 || fail=1
    m=$(max_n_partitions $t) || fail=1
    printf '%s\n' "max len: $max_len" \
	"max start sector: $max_start" \
	"max number of partitions: $m" \
      > exp || fail=1
    compare exp out || fail=1
done

Exit $fail
