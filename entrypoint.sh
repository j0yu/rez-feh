#!/bin/bash
set -euf -o pipefail

curl -#L http://feh.finalrewind.org/feh-"$VERSION".tar.bz2 \
| tar -xj --strip-components=1

# See https://feh.finalrewind.org/
make --silent -j $(nproc) curl=0 exif=1 test=1 xinerama=1 debug=1
make install PREFIX="$INSTALL_PATH"

# Copy over runtime dependencies
mkdir -p "$INSTALL_PATH"/lib64
ldd "$INSTALL_PATH"/bin/feh \
| sed -n 's:.* => \(/.*lib.*so\S*\).*:\1:gp' \
| while read LIB_SO
do
    if [ -e "$LIB_SO" ]
    then
        cp -v "$LIB_SO" "$INSTALL_PATH"/lib64
    fi
done

# Cleanup, see feh.spec files from:
# ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/linux/updates/31/Everything/SRPMS/Packages/f/feh-3.1.3-3.fc31.src.rpm
# http://mirror.ghettoforge.org/distributions/gf/el/7/gf/SRPMS/feh-2.19.3-1.gf.el7.src.rpm
find "$INSTALL_PATH" -type f -name "*.la" -print -delete
