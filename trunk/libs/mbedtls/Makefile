SRC_NAME=mbedtls-2.28.1
SRC_URL=https://tls.mbed.org/download/mbedtls-2.28.1.tar.gz

all: download_test extract_test config_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME)/build

download_test:
	( if [ ! -f $(SRC_NAME).tar.gz ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_NAME).tar.gz $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar -xf $(SRC_NAME).tar.gz; \
	fi )

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( mkdir -p $(SRC_NAME)/build && cd $(SRC_NAME)/build ; \
	cmake \
	-DCMAKE_INSTALL_PREFIX=$(STAGEDIR) \
	-DCMAKE_TOOLCHAIN_FILE=../../cross-mipsel-linux.cmake \
	-DUSE_SHARED_MBEDTLS_LIBRARY=ON \
	-DUSE_STATIC_MBEDTLS_LIBRARY=OFF \
	-DENABLE_TESTING=OFF \
	-DENABLE_PROGRAMS=OFF \
	-DLINK_WITH_PTHREAD=ON \
	-DENABLE_ZLIB_SUPPORT=ON \
	.. \
	)

clean:
	rm -rf $(SRC_NAME)/build
	rm -f config_done

install:
	$(MAKE) -C $(SRC_NAME)/build install DESTDIR=""

romfs:
	cp -fP $(DESTDIR)/lib/libmbedcrypto.so* $(ROMFSDIR)/lib
	cp -fP $(DESTDIR)/lib/libmbedtls.so* $(ROMFSDIR)/lib
	cp -fP $(DESTDIR)/lib/libmbedx509.so* $(ROMFSDIR)/lib
