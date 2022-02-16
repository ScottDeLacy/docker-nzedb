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


# Upgraded php from 7.0 to 7.1. Tested php 7.2-8.1 > required packages not available / missing. Unsure what is/is not required for nzedb. Might take some effort to get 7.2-7.4 working

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils locales\
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 wget \
    && wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > '/etc/apt/sources.list.d/php.list' \
    && apt-get update && apt-get -y install \
        curl \
        ffmpeg \
        gcc \
        gettext-base \
        git \
        libtext-micromason-perl \
        make \
        mediainfo \
        nginx-extras \
        p7zip-full \
        php7.1 \
        tzdata \
        unrar-free \
        xz-utils \
		php7.1-bcmath \
		php7.1-bz2 \
		php7.1-cgi \
		php7.1-cli \
		php7.1-common \
		php7.1-curl \
		php7.1-dba \
		php7.1-fpm \
		php7.1-gd \
		php7.1-imagick \
		php7.1-intl \
		php7.1-json \
		php7.1-ldap \
		php7.1-mbstring \
		php7.1-mcrypt \
		php7.1-mysql \
		php7.1-opcache \
		php-pear \ #correct target?
		php7.1-pgsql \
		php7.1-readline \
		php7.1-recode \
		php7.1-soap \
		php7.1-tidy \
		php7.1-xml \
		php7.1-xmlrpc \
		php7.1-xsl \
		php7.1-zip \
        && locale-gen $LANG

#make, gcc, wget can probably be removed later
        
#required noarch primary build to place ./init otherwise it doesnt exist. Also requires full suite, install scripts depend on 'suexec'.
ADD "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-noarch-${S6_FILEVERSION}.tar.xz" "/tmp/s6-noarch-${S6_FILEVERSION}.tar.xz"
ADD "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}-${S6_FILEVERSION}.tar.xz" "/tmp/s6-${S6_ARCH}-${S6_FILEVERSION}.tar.xz"
ADD "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-symlinks-noarch-${S6_FILEVERSION}.tar.xz" "/tmp/s6-symlinks-noarch-${S6_FILEVERSION}.tar.xz"

# change extract code
#RUN tar -xf /tmp/s6-${S6_ARCH}-${S6_FILEVERSION}.tar.xz -C /
#RUN tar -xf /tmp/s6-noarch-${S6_FILEVERSION}.tar.xz -C /
#RUN tar -xf /tmp/s6-symlinks-${S6_FILEVERSION}.tar.xz -C /

RUN for file in /tmp/*.tar.xz; do tar -xf "$file" -C / ; done

RUN apt-get clean \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*
    

EXPOSE 80 443
HEALTHCHECK NONE
COPY rootfs/ /
# default S6 timeout = 5000 (5 sec) not long enough. Timeout kills legacy install scripts
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME="0"
ENTRYPOINT ["/init"]

