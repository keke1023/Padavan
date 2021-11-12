SUBDIRS = doc src
EXTRA_DIST = autogen.sh GPL.txt Stanford.txt
dist_sysconf_DATA = igmpproxy.conf

.PHONY: ChangeLog
ChangeLog:
	@if git -C $(srcdir) log --format="" -1 > /dev/null; then \
		echo "Generating $@"; \
		if test -f $(srcdir)/$@; then chmod u+w $(srcdir)/$@; fi; \
		git -C $(srcdir) log --format="%ai  %aN <%aE>%n%n%x09* %B" | sed 's/^\([^2\t]\)/\t  \1/' > $(srcdir)/$@; \
	elif ! test -f $(srcdir)/$@; then \
		echo "Cannot generate ChangeLog: Not in git repository"; \
		exit 1; \
	fi

AUTHORS: $(srcdir)/ChangeLog
	@echo "Generating $@"
	@if test -f $(srcdir)/$@; then chmod u+w $(srcdir)/$@; fi
	@{ \
		echo "Authors and contributors, in alphabetical order:"; echo; \
		sed -r "s/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} [+-][0-9]{4}  (.*)/\1/;t;d" $< | LC_ALL=C sort -u; \
	} > $(srcdir)/$@
