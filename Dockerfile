ARG CENTOS_MAJOR=7
FROM centos:$CENTOS_MAJOR

WORKDIR /usr/local/src
RUN yum install -y epel-release \
    && yum install -y \
        bzip2 \
        gcc \
        imlib2-devel \
        libXinerama-devel \
        libXt-devel \
        libexif-devel \
        libjpeg-devel \
        libpng-devel \
        make \
    && yum clean all

COPY entrypoint.sh /
ENTRYPOINT ["bash", "/entrypoint.sh"]
