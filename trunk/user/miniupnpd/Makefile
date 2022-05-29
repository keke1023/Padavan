SRC_NAME=miniupnpd-2.3.0
SRC_URL=http://miniupnp.free.fr/files/download.php?file=$(SRC_NAME).tar.gz

# reference to iptables package
IPT_VERSION:=iptables-1.8.7

# disable support IPv6 yet, because no profit w/o IGDv2
# e.g. Windows not supported IGDv2 and UPnP not worked
ENABLE_IPV6:=1

IPTABLESPATH=$(ROOTDIR)/user/iptables/$(IPT_VERSION)

#all: download_test extract_test
all:
	cd $(SRC_NAME) && ./configure
	$(MAKE) -C $(SRC_NAME) IPTABLESPATH=$(IPTABLESPATH) ENABLE_IPV6=$(ENABLE_IPV6)

download_test:
	( if [ ! -f $(SRC_NAME).tar.gz ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_NAME).tar.gz $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar xzf $(SRC_NAME).tar.gz; \
		patch -d $(SRC_NAME) -p1 -i ../miniupnpd-orig.patch; \
	fi )

clean:
	$(MAKE) -C $(SRC_NAME) clean
	rm -f miniupnpd

romfs:
	cp $(SRC_NAME)/miniupnpd .
	$(ROMFSINST) /usr/bin/miniupnpd

