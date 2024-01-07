FROM ubuntu:22.04
LABEL Author="Jeroen Geusebroek <me@jeroengeusebroek.nl>"

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    APTLIST="apache2 php8.1 php8.1-curl php8.1-gd php8.1-gmp php8.1-mysql php8.1-pgsql php8.1-xml php8.1-xmlrpc php8.1-mbstring php8.1-zip git-core cron wget jq locales"

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt -qy install software-properties-common && add-apt-repository ppa:ondrej/php && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy $APTLIST && \
    a2enmod headers && \
    locale-gen --no-purge nl_NL.UTF-8 en_US.UTF-8 && \
    \
    # Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -r /var/www/html && \
    rm -rf /tmp/*

RUN git clone --no-checkout -b master --depth 1 --single-branch https://github.com/spotweb/spotweb.git /var/www/spotweb && \
    cd /var/www/spotweb && \
    git config core.symlinks false && \
    git checkout && \
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
