/*
    libparted - a library for manipulating disk partitions
    Copyright (C) 2013-2014 Free Software Foundation, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <config.h>

#include <parted/parted.h>
#include <parted/endian.h>

/* Located 64k inside the partition (start of the first btrfs superblock) */
#define BTRFS_MAGIC 0x4D5F53665248425FULL /* ascii _BHRfS_M, no null */
#define BTRFS_CSUM_SIZE 32
#define BTRFS_FSID_SIZE 16


static PedGeometry*
btrfs_probe (PedGeometry* geom)
{
        union {
            struct {
                /* Just enough of the btrfs_super_block to get the magic */
                uint8_t csum[BTRFS_CSUM_SIZE];
                uint8_t fsid[BTRFS_FSID_SIZE];
                uint64_t bytenr;
                uint64_t flags;
                uint64_t magic;
            } sb;
            int8_t      sector[8192];
        } buf;
        PedSector offset = (64*1024)/geom->dev->sector_size;

        if (geom->length < offset+1)
                return 0;
        if (!ped_geometry_read (geom, &buf, offset, 1))
                return 0;

        if (PED_LE64_TO_CPU(buf.sb.magic) == BTRFS_MAGIC) {
                return ped_geometry_new (geom->dev, geom->start, geom->length);
        }
        return NULL;
}

static PedFileSystemOps btrfs_ops = {
        probe:          btrfs_probe,
};

static PedFileSystemType btrfs_type = {
        next:   NULL,
        ops:    &btrfs_ops,
        name:   "btrfs",
};

void
ped_file_system_btrfs_init ()
{
        ped_file_system_type_register (&btrfs_type);
}

void
ped_file_system_btrfs_done ()
{
        ped_file_system_type_unregister (&btrfs_type);
}
