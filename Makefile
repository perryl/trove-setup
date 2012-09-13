install:
	mkdir -p "${DESTDIR}/usr/share/gitano/skel"
	cp -a gitano-admin "${DESTDIR}/usr/share/gitano/skel"
	mkdir -p "${DESTDIR}/usr/lib/systemd/system/multi-user.target.wants"
	cp units/* "${DESTDIR}/usr/lib/systemd/system"
	for I in $$(cd units; ls); do \
		ln -sf ../$$I "${DESTDIR}/usr/lib/systemd/system/multi-user.target.wants/$$I"; \
	done
	mkdir -p "${DESTDIR}/etc"
	cp cgitrc "${DESTDIR}/etc/cgitrc"
	cp cgit-head.inc "${DESTDIR}/etc/cgit-trove-head.inc"
	mkdir -p "${DESTDIR}/var/www/htdocs"
	cp http-assets/* "${DESTDIR}/var/www/htdocs"
	ln -s cgit "${DESTDIR}/var/www/htdocs/cgi-bin"
