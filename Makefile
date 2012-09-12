install:
	mkdir -p "${DESTDIR}/usr/share/gitano/skel"
	cp -a gitano-admin "${DESTDIR}/usr/share/gitano/skel"
	mkdir -p "${DESTDIR}/usr/lib/systemd/system/multiuser-target.wants"
	cp units/* "${DESTDIR}/usr/lib/systemd/system"
	for I in $$(cd units; ls); do \
		ln -sf ../$$I "${DESTDIR}/usr/lib/systemd/system/multiuser-target.wants/$I"; \
	done
