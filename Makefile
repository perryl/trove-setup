install:
	mkdir -p "${DESTDIR}/usr/share/gitano/skel"
	cp -a gitano-admin "${DESTDIR}/usr/share/gitano/skel"
	mkdir -p "${DESTDIR}/usr/lib/systemd/system/multi-user.target.wants"
	cp units/* "${DESTDIR}/usr/lib/systemd/system"
	for I in $$(cd units; ls); do \
		ln -sf ../$$I "${DESTDIR}/usr/lib/systemd/system/multi-user.target.wants/$$I"; \
	done
	mkdir -p "${DESTDIR}/etc"
	cp etc/* "${DESTDIR}/etc"
	mkdir -p "${DESTDIR}/var/www/htdocs"
	cp http-assets/* "${DESTDIR}/var/www/htdocs"
	ln -s cgit "${DESTDIR}/var/www/htdocs/cgi-bin"
	ln -s /home/lorry/bundles "${DESTDIR}/var/www/htdocs/bundles"
	ln -s /home/lorry/tarballs "${DESTDIR}/var/www/htdocs/tarballs"
	ln -s /home/lorry/lc-status.html "${DESTDIR}/var/www/htdocs/lc-status.html"
	mkdir -p "${DESTDIR}/usr/bin"
	cp bins/* "${DESTDIR}/usr/bin/"
	mkdir -p "${DESTDIR}/usr/share/trove-setup"
	cp -r share/* "${DESTDIR}/usr/share/trove-setup/"
