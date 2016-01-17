FROM ubuntu:15.10
MAINTAINER Jeroen Geusebroek <me@jeroengeusebroek.nl>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    APTLIST="apache2 php5 php5-curl php5-gd php5-gmp php5-mysql git-core sudo cron" \
    REFRESHED_AT='2015-01-18'

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt-get -qy --force-yes dist-upgrade && \
    apt-get install -qy --force-yes $APTLIST && \

    # Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -r /var/www/html && \
    rm -rf /tmp/*

RUN git clone https://github.com/spotweb/spotweb.git /var/www/spotweb && \
    cd /var/www/spotweb && \
    git checkout media && \
    chmod -R 775 /var/www/spotweb && \
    chown -R www-data:www-data /var/www/spotweb

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

COPY files/000-default.conf /etc/apache2/sites-enabled/000-default.conf

VOLUME [ "/config" ]

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]