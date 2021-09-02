BASEOBJS = miniupnpd.o upnphttp.o upnpdescgen.o upnpsoap.o \
           upnpreplyparse.o minixml.o portinuse.o \
           upnpredirect.o getifaddr.o daemonize.o \
           options.o upnppermissions.o minissdp.o natpmp.o pcpserver.o \
           upnpglobalvars.o upnpevents.o upnputils.o getconnstatus.o \
           upnpstun.o upnppinhole.o pcplearndscp.o asyncsendto.o

# sources in linux/ directory
LNXOBJS = linux/getifstats.o linux/ifacewatcher.o
ifeq ($(ENABLE_IPV6),1)
LNXOBJS += linux/getroute.o
endif
