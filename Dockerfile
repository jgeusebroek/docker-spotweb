FROM ubuntu:18.04
MAINTAINER Jeroen Geusebroek <me@jeroengeusebroek.nl>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    APTLIST="apache2 php7.2 php7.2-curl php7.2-gd php7.2-gmp php7.2-mysql php7.2-pgsql php7.2-xml php7.2-xmlrpc php7.2-mbstring php7.2-zip git-core cron wget jq" \
    REFRESHED_AT='2020-03-06'

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy $APTLIST && \
    \
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

# Add caching and compression config to .htaccess
COPY files/001-htaccess.conf .
RUN cat /001-htaccess.conf >> /var/www/spotweb/.htaccess
RUN rm /001-htaccess.conf

VOLUME [ "/config" ]

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
