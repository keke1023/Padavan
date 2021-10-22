SRC_NAME=dosfstools-4.2
SRC_URL=https://github.com/dosfstools/dosfstools/releases/download/v4.2/dosfstools-4.2.tar.gz
CFLAGS+=$(COPT) -ffunction-sections -fdata-sections -fvisibility=hidden
LDFLAGS += -Wl,--gc-sections

all: download_test extract_test config_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME)

download_test:
	( if [ ! -f $(SRC_NAME).tar.gz ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_NAME).tar.gz $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar -xzf $(SRC_NAME).tar.gz; \
	fi )

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_NAME) ;\
	./configure \
		--enable-compat-symlinks \
		--exec-prefix=/ \
		--without-udev \
		LIBS="-liconv" \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean; \
	fi ; \
	rm -f config_done
	rm -f fsck.fat

romfs:
	cp $(SRC_NAME)/src/fsck.fat .
	$(STRIP) fsck.fat
	$(ROMFSINST) /sbin/fsck.fat
