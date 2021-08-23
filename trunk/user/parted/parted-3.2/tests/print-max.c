#include <config.h>
#include <parted/parted.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include "closeout.h"
#include "progname.h"
#include "error.h"

int
main (int argc, char **argv)
{
  atexit (close_stdout);
  set_program_name (argv[0]);

  if (argc != 2)
    return EXIT_FAILURE;

  char const *dev_name = argv[1];
  PedDevice *dev = ped_device_get (dev_name);
  if (dev == NULL)
    return EXIT_FAILURE;
  PedDisk *disk = ped_disk_new (dev);
  if (disk == NULL)
    return EXIT_FAILURE;

  PedSector max_length = ped_disk_max_partition_length (disk);
  PedSector max_start_sector = ped_disk_max_partition_start_sector (disk);

  if (!ped_device_open(dev))
    error (EXIT_FAILURE, errno, "failed to open %s\n", dev_name);
  int max_n_partitions;
  bool ok = ped_disk_get_max_supported_partition_count (disk,
							&max_n_partitions);

  printf ("max len: %llu\n", (unsigned long long) max_length);
  printf ("max start sector: %llu\n", (unsigned long long) max_start_sector);
  printf ("max number of partitions: %d\n",
	  ok ? max_n_partitions : -1);

  ped_disk_destroy (disk);
  ped_device_destroy (dev);
  return EXIT_SUCCESS;
}
