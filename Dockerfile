FROM ubuntu:20.04 AS build

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y apache2-dev build-essential wget libssl-dev libcurl4-openssl-dev libpcre++-dev \
    && wget -O mod_auth_cas.tar.gz https://github.com/apereo/mod_auth_cas/archive/v1.2.tar.gz \
    && tar -zxf mod_auth_cas.tar.gz \
    && cd mod_auth_cas-1.2 \
    && autoreconf -ivh \
    && ./configure \
    && make \
    && make install

FROM ubuntu:20.04

ENV ALLOWED_IPS=127.0.0.1

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install apache2 libpcre3 libcurl4 -y && \
    mkdir -p /var/cache/apache2/mod_auth_cas && \
    chown -R www-data:www-data /var/cache/apache2/mod_auth_cas && \
    rm -Rf /var/lib/apt/lists/*

COPY auth_cas.conf /etc/apache2/mods-available/auth_cas.conf
COPY auth_cas.load /etc/apache2/mods-available/auth_cas.load
COPY remoteip.conf /etc/apache2/mods-available/remoteip.conf
COPY default-site.conf /etc/apache2/sites-available/default.conf
COPY --from=build /usr/lib/apache2/modules/mod_auth_cas.so /usr/lib/apache2/modules/mod_auth_cas.so

RUN a2enmod auth_cas && \
    a2enmod authz_groupfile && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod proxy_wstunnel && \
    a2enmod remoteip && \
    a2enmod rewrite && \
    a2ensite default && \
    a2dissite 000-default

EXPOSE 80

CMD ["/usr/sbin/apachectl", "-d", "/etc/apache2", "-f", "apache2.conf", "-e", "info", "-DFOREGROUND"]