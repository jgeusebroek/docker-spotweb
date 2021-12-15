#!/bin/bash

if [ ! -f /config/ownsettings.php ] && [ -f /var/www/spotweb/ownsettings.php ]; then
  cp /var/www/spotweb/ownsettings.php /config/ownsettings.php
fi

touch /config/ownsettings.php && chown www-data:www-data /config/ownsettings.php
rm -f /var/www/spotweb/ownsettings.php
ln -s /config/ownsettings.php /var/www/spotweb/ownsettings.php

chown -R www-data:www-data /var/www/spotweb

if [[ -n "$SPOTWEB_DB_TYPE" && -n "$SPOTWEB_DB_HOST" && -n "$SPOTWEB_DB_NAME" && -n "$SPOTWEB_DB_USER" ]]; then
    echo "Creating database configuration"
    echo "<?php" > /config/dbsettings.inc.php
    echo "\$dbsettings['engine'] = '$SPOTWEB_DB_TYPE';" >> /config/dbsettings.inc.php
    echo "\$dbsettings['host'] = '$SPOTWEB_DB_HOST';" >> /config/dbsettings.inc.php
    echo "\$dbsettings['dbname'] = '$SPOTWEB_DB_NAME';"  >> /config/dbsettings.inc.php
    echo "\$dbsettings['user'] = '$SPOTWEB_DB_USER';" >> /config/dbsettings.inc.php
    if [[ -n "$SPOTWEB_DB_PASS" ]]; then
    	echo "\$dbsettings['pass'] = '$SPOTWEB_DB_PASS';"  >> /config/dbsettings.inc.php
    fi
fi

if [[ -n "$SPOTWEB_DB_PORT" ]]; then
    echo "\$dbsettings['port'] = '$SPOTWEB_DB_PORT';"  >> /config/dbsettings.inc.php
fi

if [ -f /config/dbsettings.inc.php ]; then
	chown www-data:www-data /config/dbsettings.inc.php
	rm /var/www/spotweb/dbsettings.inc.php
	ln -s /config/dbsettings.inc.php /var/www/spotweb/dbsettings.inc.php
else
	echo -e "\nWARNING: You have no database configuration file, either create /config/dbsettings.inc.php or restart this container with the correct environment variables to auto generate the config.\n"
fi

TZ=${TZ:-"Europe/Amsterdam"}
echo -e "Setting (PHP) time zone to ${TZ}\n"
sed -i "s#^;date.timezone =.*#date.timezone = ${TZ}#g"  /etc/php/8.*/*/php.ini

if [[ -n "$SPOTWEB_CRON_RETRIEVE" || -n "$SPOTWEB_CRON_CACHE_CHECK" ]]; then
    ln -sf /proc/$$/fd/1 /var/log/stdout
    service cron start
	if [[ -n "$SPOTWEB_CRON_RETRIEVE" ]]; then
        echo "$SPOTWEB_CRON_RETRIEVE su -l www-data -s /usr/bin/php /var/www/spotweb/retrieve.php >/var/log/stdout 2>&1" > /etc/crontab
	fi
	if [[ -n "$SPOTWEB_CRON_CACHE_CHECK" ]]; then
        echo "$SPOTWEB_CRON_CACHE_CHECK su -l www-data -s /usr/bin/php /var/www/spotweb/bin/check-cache.php >/var/log/stdout 2>&1" >> /etc/crontab
	fi
    crontab /etc/crontab
fi

# Run database update
/usr/bin/php /var/www/spotweb/bin/upgrade-db.php >/dev/null 2>&1

# Clean up apache pid (if there is one)
rm -rf /run/apache2/apache2.pid

# Enabling PHP mod rewrite, expires and deflate (they may be on already by default)
unset rt
/usr/sbin/a2enmod rewrite && rt=1
/usr/sbin/a2enmod expires && rt=1
/usr/sbin/a2enmod deflate && rt=1

# Only restart if one of the enmod commands succeeded
if [[ -n $rt ]]; then
    /etc/init.d/apache2 restart
fi

tail -F /var/log/apache2/* /dev/stdout /dev/stderr
