# rewriting original for debian install, since alpine is dropping support / not uptodate for required packages
# intended for easy deployment on qnap

FROM debian:stretch-slim
MAINTAINER https://github.com/ScottDeLacy

ARG S6_VERSION="v3.0.0.2"
ARG S6_ARCH="amd64"
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
        php8.0 \
        php8.0-cgi \
        php8.0-cli \
        php8.0-common \
        php8.0-curl \
        php8.0-gd \
        php8.0-json \
        php8.0-mysql \
        php8.0-readline \
        php8.0-recode \
        php8.0-tidy \
        php8.0-xml \
        php8.0-xmlrpc \
        php8.0-bcmath \
        php8.0-bz2 \
        php8.0-dba \
        php8.0-fpm \
        php8.0-intl \
        php8.0-mbstring \
        php8.0-mcrypt \
        php8.0-soap \
        php8.0-xsl \
        php8.0-zip \
        php-imagick \
        php-pear \
        tzdata \
        unrar-free \

    && locale-gen $LANG

ADD "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" "/tmp/s6.tar.gz"
RUN tar xfz /tmp/s6.tar.gz -C /
RUN apt-get clean \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*
    

EXPOSE 80 443
HEALTHCHECK NONE
COPY rootfs/ /
ENTRYPOINT ["/init"]

