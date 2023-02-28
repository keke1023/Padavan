THISDIR = $(shell pwd)
xray_dir="xray.com/core/main"
export GO111MODULE=on
export GOPROXY=https://goproxy.cn
xray_SED_ARGS:=
xray_SED_ARGS += \
	s/_ "xray.com\/core\/main\/json"/\/\/ &/; \
	/\/\/ _ "xray.com\/core\/main\/jsonem"/s/\/\/ //;
xray_SED_ARGS += \
	s/_ "xray.com\/core\/main\/json"/\/\/ &/;
xray_VERSION := 1.7.5
xray_URL := https://codeload.github.com/xtls/xray-core/tar.gz/v$(xray_VERSION)

all:download_xray build_extract build_xray

download_xray:
	( if [ ! -f $(THISDIR)/Xray-core-$(xray_VERSION).tar.gz ]; then \
	curl --create-dirs -L $(xray_URL) -o $(THISDIR)/Xray-core-$(xray_VERSION).tar.gz ; \
	fi )
	
build_extract:
	mkdir -p $(THISDIR)/xray.com
	mkdir -p $(THISDIR)/bin
	( if [ ! -d $(THISDIR)/xray.com/core ]; then \
	tar zxfv $(THISDIR)/Xray-core-$(xray_VERSION).tar.gz -C $(THISDIR)/xray.com ; \
	mv $(THISDIR)/xray.com/Xray-core-$(xray_VERSION) $(THISDIR)/xray.com/core ; \
	fi )

build_xray:
	( cd $(THISDIR)/$(xray_dir); \
	sed -i \
			'$(xray_SED_ARGS)' \
			distro/all/all.go ; \
	GOOS=linux GOARCH=mipsle go build -ldflags "-s -w -buildid=" -o $(THISDIR)/bin/xray; \
	)
	
clean:
	rm -rf $(THISDIR)/xray.com
	rm -rf $(THISDIR)/bin
	
romfs:
	$(ROMFSINST) -p +x $(THISDIR)/bin/xray /usr/bin/v2ray
