/* -*- Mode: c; indent-tabs-mode: nil -*-

    libparted - a library for manipulating disk partitions
    Copyright (C) 2007, 2009-2014 Free Software Foundation, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>. */

#include <inttypes.h>
#include <uuid/uuid.h>

/* hack: use the ext2 uuid library to generate a reasonably random (hopefully
 * with /dev/random) number.  Unfortunately, we can only use 4 bytes of it.
 * We make sure to avoid returning zero which may be interpreted as no FAT
 * serial number or no MBR signature.
 */
static inline uint32_t
generate_random_uint32 (void)
{
       union {
               uuid_t uuid;
               uint32_t i;
       } uu32;

       uuid_generate (uu32.uuid);

       return uu32.i > 0 ? uu32.i : 0xffffffff;
}

/* Return nonzero if FS_TYPE_NAME starts with "linux-swap".
   This must match the NUL-terminated "linux-swap" as well
   as "linux-swap(v0)" and "linux-swap(v1)".  */
static inline int
is_linux_swap (char const *fs_type_name)
{
  char const *prefix = "linux-swap";
  return strncmp (fs_type_name, prefix, strlen (prefix)) == 0;
}
