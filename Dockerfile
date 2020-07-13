FROM centos:7

ARG VERSION=3.1.3
ARG IMLIB2_VERSION=1.4.5

# Influences feh make (install) location
ARG PREFIX=/feh

# See https://feh.finalrewind.org/
WORKDIR /usr/local/src
RUN yum install -y epel-release \
    && yum install -y \
        bzip2 \
        freetype-devel \
        libX11-devel \
        libXt-devel \
        libXext-devel \
        libXinerama-devel \
        pkgconfig \
        make \
        git \
        gcc \
    && find /usr/lib64/* ! -type d | sort > old.txt

# MANUAL imlib2
# RUN yum install -y \
#     libjpeg-devel \
#     libpng-devel \
#     libtiff-devel \
#     giflib-devel \
#     libtool \
#     bzip2-devel \
#     libid3tag-devel
# WORKDIR /usr/local/src/imlib2
# RUN curl -L http://downloads.sourceforge.net/enlightenment/imlib2-${IMLIB2_VERSION}.tar.bz2 \
#     | tar -xj --strip-components=1 \
#     && autoreconf -ifv \
#     && x_libs=" " ./configure \
#         --disable-static \
#         --with-pic \
#         --disable-mmx \
#         --enable-amd64 \
#         --prefix="" \
#     && make \
#     && make install DESTDIR=${PREFIX} && rm -fv ${PREFIX}/bin/* 
#     # && make install DESTDIR=/usr

WORKDIR /usr/local/src
RUN yum install -y \
        imlib2-devel \
        libjpeg-turbo-devel
#     && yum clean all \
#     && find /usr/lib64/* ! -type d | sort \
#     | diff -y --suppress-common-lines - old.txt \
#     | sed -E 's:(/usr/lib64/)(\S+)\s+<.*:mkdir -vp \$(dirname \2) \&\& cp -rv \1\2 \2:' > copy.txt

RUN mkdir -vp ${PREFIX} curl feh \
    && LATEST_CURL=$(curl https://github.com/curl/curl/releases/latest \
                  | sed -n 's/.*"http/http/ ; s/".*// ; s:/tag:/download:p') \
    && CURL_NAME=${LATEST_CURL##*/} \
    && curl -Ls ${LATEST_CURL}/${CURL_NAME//_/.}.tar.gz \
    | tar -C curl -xz --strip-components=1 \
    && git clone https://git.finalrewind.org/feh feh
    # && curl -Ls https://github.com/derf/feh/archive/${VERSION}.tar.gz \
    # | tar -C feh -xz --strip-components=1

WORKDIR /usr/local/src/curl
RUN ./configure \
    && make --silent -j $(nproc) \
    && make install

WORKDIR /usr/local/src/feh
# ENV LD_LIBRARY_PATH=${PREFIX}/lib
RUN git checkout ${VERSION} \
    && make --silent -j $(nproc) \
    # && CFLAGS="-I${PREFIX}/include -Wl,-L${PREFIX}/lib" make --silent -j $(nproc) \
    && make install

ENV PREFIX=${PREFIX}
# WORKDIR ${PREFIX}/lib64
# RUN source /usr/local/src/copy.txt
    # Segmentation faults if you hot patch lol
    # && sed -i s:/usr/lib64/imlib2/:$(pwd)/imlib2/:g libImlib2.so*

