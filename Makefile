install:
	mkdir -p "${DESTDIR}/usr/share/gitano/skel"
	cp -a gitano-admin "${DESTDIR}/usr/share/gitano/skel"
	mkdir -p "${DESTDIR}/usr/lib/systemd/system/multi-user.target.wants"
	cp units/* "${DESTDIR}/usr/lib/systemd/system"
	for I in $$(cd units; ls); do \
		ln -sf ../$$I "${DESTDIR}/usr/lib/systemd/system/multi-user.target.wants/$$I"; \
	done
	mkdir -p "${DESTDIR}/etc"
	for I in etc/*; do \
		cp $$I "${DESTDIR}/"; \
	done
	mkdir -p "${DESTDIR}/var/www/htdocs"
	cp http-assets/* "${DESTDIR}/var/www/htdocs"
	ln -s cgit "${DESTDIR}/var/www/htdocs/cgi-bin"
	ln -s /home/lorry/bundles "${DESTDIR}/var/www/htdocs/bundles"
