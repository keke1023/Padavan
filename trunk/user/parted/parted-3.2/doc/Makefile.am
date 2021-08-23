# C must be the first sub-directory because it contains the POT files.
SUBDIRS = C pt_BR

info_TEXINFOS = parted.texi
MAKEINFO = makeinfo --no-split

EXTRA_DIST = FAT		\
			 USER.jp	\
			 API		\
			 fdl.texi	\
			 parted-pt_BR.texi

.PHONY: updatepo
updatepo:
	$(AM_V_GEN)list='$(SUBDIRS)'; for dir in $$list; do \
		$(MAKE) -C "$$dir" updatepo; \
	done
