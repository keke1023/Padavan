SRC_NAME=util-linux-2.36.1
SRC_URL=https://www.kernel.org/pub/linux/utils/util-linux/v2.36/util-linux-2.36.1.tar.xz

THISDIR = $(shell pwd)

CFLAGS += -ffunction-sections -fdata-sections
LDFLAGS += -Wl,--gc-sections

all: download_test extract_test config_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME) && \
	$(MAKE) -C $(SRC_NAME) install DESTDIR=""

download_test:
	( if [ ! -f $(SRC_NAME).tar.xz ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_NAME).tar.xz $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar xJf $(SRC_NAME).tar.xz; \
		patch -d $(SRC_NAME) -p1 -i ../libblkid.patch; \
	fi )

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_NAME) ; \
	./autogen.sh ; \
	PKG_CONFIG_PATH=$(STAGEDIR)/lib/pkgconfig \
	scanf_cv_type_modifier=no \
	./configure \
		--prefix=$(STAGEDIR) \
		--without-ncurses \
		--without-ncursesw \
		--without-slang \
		--without-selinux \
		--without-audit \
		--without-udev \
		--without-python \
		--without-systemd \
		--without-btrfs \
		--without-readline \
		--disable-all-programs \
		--enable-libblkid \
		--enable-libuuid \
		--enable-blkid \
		--disable-bash-completion \
		--disable-nls \
		--disable-libmount \
		--disable-mount \
		--disable-losetup \
		--disable-fsck \
		--disable-partx \
		--disable-uuidd \
		--disable-mountpoint \
		--disable-fallocate \
		--disable-unshare \
		--disable-eject \
		--disable-agetty \
		--disable-cramfs \
		--disable-wdctl \
		--disable-switch_root \
		--disable-pivot_root \
		--disable-kill \
		--disable-utmpdump \
		--disable-rename \
		--disable-login \
		--disable-sulogin \
		--disable-su \
		--disable-schedutils \
		--disable-wall \
		--disable-use-tty-group \
		--disable-makeinstall-chown \
		--disable-makeinstall-setuid \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done

romfs:
	$(ROMFSINST) $(STAGEDIR)/sbin/blkid /sbin/blkid
	$(ROMFSINST) $(STAGEDIR)/lib/libblkid.so.1.1.0 /lib/libblkid.so.1.1.0
	$(ROMFSINST) $(STAGEDIR)/lib/libuuid.so.1.3.0 /lib/libuuid.so.1.3.0
	$(ROMFSINST) -s libblkid.so.1.1.0 /lib/libblkid.so
	$(ROMFSINST) -s libblkid.so.1.1.0 /lib/libblkid.so.1
	$(ROMFSINST) -s libuuid.so.1.3.0 /lib/libuuid.so
	$(ROMFSINST) -s libuuid.so.1.3.0 /lib/libuuid.so.1
