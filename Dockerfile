# rewriting original for debian install, since alpine is dropping support / not uptodate for required packages
# intended for easy deployment on qnap

FROM debian:stretch-slim
MAINTAINER https://github.com/ScottDeLacy

ARG S6_VERSION="v3.0.0.2"
ARG S6_FILEVERSION="3.0.0.2" #file names dont have v{version number} and this is easier than another run command
#ARG S6_ARCH="amd64" staticly set. Follows version #
ARG S6_ARCH="x86_64"
ARG DEBIAN_FRONTEND="noninteractive"
ARG LANG="en_US.UTF-8"
ARG LC_ALL="C.UTF-8"
ARG LANGUAGE="en_US.UTF-8"
ARG TERM="xterm-256color"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils locales\
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        curl \
        ffmpeg \
        gettext-base \
        git \
        libtext-micromason-perl \
        mediainfo \
        nginx-extras \
        p7zip-full \
        php7.0 \
        php7.0-cgi \
        php7.0-cli \
        php7.0-common \
        php7.0-curl \
        php7.0-gd \
        php7.0-json \
        php7.0-mysql \
        php7.0-readline \
        php7.0-recode \
        php7.0-tidy \
        php7.0-xml \
        php7.0-xmlrpc \
        php7.0-bcmath \
        php7.0-bz2 \
        php7.0-dba \
        php7.0-fpm \
        php7.0-intl \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-soap \
        php7.0-xsl \
        php7.0-zip \
        php-imagick \
        php-pear \
        tzdata \
        xz-utils \
        unrar-free && locale-gen $LANG
        
#required noarch primary build to place ./init otherwise it doesnt exist. Also requires full suite, install scripts depend on 'suexec'.
ADD "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-noarch-${S6_FILEVERSION}.tar.gz" "/tmp/s6-noarch-${S6_FILEVERSION}.tar.gz"
ADD "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}-${S6_FILEVERSION}.tar.xz" "/tmp/s6-${S6_ARCH}-${S6_FILEVERSION}.tar.xz"
# change extract code
RUN tar xf /tmp/s6-${S6_ARCH}-${S6_FILEVERSION}.tar.xz -C /
RUN tar xf /tmp/s6-noarch-${S6_FILEVERSION}.tar.gz -C /
RUN apt-get clean \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*
    

EXPOSE 80 443
HEALTHCHECK NONE
COPY rootfs/ /
ENTRYPOINT ["/init"]

