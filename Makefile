install:
	mkdir -p "${DESTDIR}/usr/lib/systemd/system/multi-user.target.wants"
	cp units/* "${DESTDIR}/usr/lib/systemd/system"
	ln -sf ../trove-setup.service "${DESTDIR}/usr/lib/systemd/system/multi-user.target.wants/trove-setup.service"
	cp -r etc "${DESTDIR}"
	mkdir -p "${DESTDIR}/var/www/htdocs"
	cp http-assets/* "${DESTDIR}/var/www/htdocs"
	ln -s cgit "${DESTDIR}/var/www/htdocs/cgi-bin"
	ln -s /home/lorry/bundles "${DESTDIR}/var/www/htdocs/bundles"
	ln -s /home/lorry/tarballs "${DESTDIR}/var/www/htdocs/tarballs"
	ln -s /home/lorry/lc-status.html "${DESTDIR}/var/www/htdocs/lc-status.html"
	ln -s /usr/share/lorry-controller/static/ "${DESTDIR}/var/www/htdocs/lc-static"
	mkdir -p "${DESTDIR}/usr/share/trove-setup"
	cp -r share/* "${DESTDIR}/usr/share/trove-setup/"

	ln -s /usr/lib/gitano/bin/gitano-command.cgi \
		"${DESTDIR}/var/www/htdocs/gitano-command.cgi"

	ln -s /usr/lib/gitano/bin/gitano-smart-http.cgi \
		"${DESTDIR}/var/www/htdocs/gitano-smart-http.cgi"
