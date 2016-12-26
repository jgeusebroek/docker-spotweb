FROM ubuntu:16.10
MAINTAINER Jeroen Geusebroek <me@jeroengeusebroek.nl>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    APTLIST="apache2 php7.0 php7.0-curl php7.0-gd php7.0-gmp php7.0-mysql php-xml php-xmlrpc git-core" \
    REFRESHED_AT='2016-12-26'

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy $APTLIST && \

    # Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -r /var/www/html && \
    rm -rf /tmp/*

RUN git clone -b master --single-branch https://github.com/spotweb/spotweb.git /var/www/spotweb && \
    rm -rf /var/www/spotweb/.git && \
    chmod -R 775 /var/www/spotweb && \
    chown -R www-data:www-data /var/www/spotweb

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

COPY files/000-default.conf /etc/apache2/sites-enabled/000-default.conf

VOLUME [ "/config" ]

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
