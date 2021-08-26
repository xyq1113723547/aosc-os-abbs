trap - ERR; trap "abdie" ERR; bash -n "$0"

XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --enable-shared"

for package in $(grep -v '^#' lib-7.7.md5 | awk '{print $2}')
do
    abinfo "Building ${package}..."
    packagedir=${package%.tar.bz2}
    pushd "$packagedir"
    cp /usr/share/automake-1.16/config.* .
    if [[ $packagedir = libxshmfence-* ]]; then
        sed -i 's@#define MFD_ALLOW_SEALING\t0x0002U@&\nint memfd_create (const char *__name, unsigned int __flags) __THROW;@g' src/xshmfence_alloc.c
    fi
    case $packagedir in
        libXfont-[0-9]* )
            ./configure $XORG_CONFIG --disable-devel-docs || return 1
            ;;
        libXt-[0-9]* )
            ./configure $XORG_CONFIG \
                --with-appdefaultdir=/etc/X11/app-defaults || return 1
            ;;
        libX11-[0-9]* )
            ./configure $XORG_CONFIG --disable-xf86bigfont || return 1
            ;;
        * )
            ./configure $XORG_CONFIG || return 1
            ;;
    esac
    make || return 1
    make DESTDIR="$PKGDIR" install || return 1
    popd
done

abinfo "Removing some files found in x11-proto..."
rm -v "$PKGDIR"/usr/include/X11/extensions/XKBgeom.h
rm -v "$PKGDIR"/usr/include/X11/extensions/vldXvMC.h

trap - ERR
