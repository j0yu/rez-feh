#!/bin/bash
set -euf -o pipefail

# Perform the actual Python building and installing
# Ideally we're currently in an empty directory
INSTALL_DIR="${INSTALL_DIR:-$(mktemp -d)}"
VERSION="${VERSION:-3.7}"
URL=http://feh.finalrewind.org/feh-"$VERSION".tar.bz2

mkdir -vp "$INSTALL_DIR"

CURL_FLAGS=("-L")
[ -t 1 ] && CURL_FLAGS+=("-#") || CURL_FLAGS+=("-sS")

echo "Downloading and extracting: $URL"
echo "    into current directory: $(pwd)"
curl "${CURL_FLAGS[@]}" "$URL" \
| tar --strip-components=1 -xj

# See https://feh.finalrewind.org/
LD_RUN_PATH='$ORIGIN:$ORIGIN/../lib64':"$INSTALL_DIR"/lib64 make \
    --silent -j"$(nproc)" curl=0 exif=1 test=1 xinerama=1 debug=1
make install PREFIX="$INSTALL_DIR"

# Copy over runtime dependencies
mkdir -p "$INSTALL_DIR"/lib64
ldd "$INSTALL_DIR"/bin/feh \
| sed -n 's:.* => \(/.*lib.*so\S*\).*:\1:gp' \
| while read LIB_SO
do
    if [ -e "$LIB_SO" ]
    then
        cp -v "$LIB_SO" "$INSTALL_DIR"/lib64
    fi
done

# Cleanup, see feh.spec files from:
# ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/linux/updates/31/Everything/SRPMS/Packages/f/feh-3.1.3-3.fc31.src.rpm
# http://mirror.ghettoforge.org/distributions/gf/el/7/gf/SRPMS/feh-2.19.3-1.gf.el7.src.rpm
find "$INSTALL_DIR" -type f -name "*.la" -print -delete

# Ensure all libraries are linked properly. Exit 1 if any libraries are "not found"
LDD_RESULTS="$(mktemp)"
ldd -v "$INSTALL_DIR"/bin/feh > "$LDD_RESULTS"
grep -q "not found" "$LDD_RESULTS" || exit 0

grep "not found" "$LDD_RESULTS"
echo "----- from: ldd -v "$INSTALL_DIR"/bin/feh -----"
cat "$LDD_RESULTS"
exit 1