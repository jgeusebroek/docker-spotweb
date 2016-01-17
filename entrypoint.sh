#!/bin/bash
set -x

SPOTWEB_CRON=${SPOTWEB_CRON:-'*/15 * * * *'}

if [ ! -f /config/ownsettings.php ] && [ -f /var/www/spotweb/ownsettings.php ]; then
  cp /var/www/spotweb/ownsettings.php /config/ownsettings.php

elif [ ! -f /config/ownsettings.php ] && [ ! -f /var/www/spotweb/ownsettings.php ]; then
  touch /config/ownsettings.php
fi

chown www-data:www-data /config/ownsettings.php
rm -f /var/www/spotweb/ownsettings.php
ln -s /config/ownsettings.php /var/www/spotweb/ownsettings.php

if [[ -n "$SPOTWEB_DB_TYPE" && -n "$SPOTWEB_DB_HOST" && -n "$SPOTWEB_DB_NAME" && -n "$SPOTWEB_DB_USER" && -n "$SPOTWEB_DB_PASS" ]]; then
    echo "Creating database configuration"
    echo "<?php" > /config/dbsettings.inc.php
    echo "\$dbsettings['engine'] = '$SPOTWEB_DB_TYPE';" >> /config/dbsettings.inc.php
    echo "\$dbsettings['host'] = '$SPOTWEB_DB_HOST';" >> /config/dbsettings.inc.php
    echo "\$dbsettings['dbname'] = '$SPOTWEB_DB_NAME';"  >> /config/dbsettings.inc.php
    echo "\$dbsettings['user'] = '$SPOTWEB_DB_USER';" >> /config/dbsettings.inc.php
    echo "\$dbsettings['pass'] = '$SPOTWEB_DB_PASS';"  >> /config/dbsettings.inc.php
fi

if [ -f /config/dbsettings.inc.php ]; then
	chown www-data:www-data /config/dbsettings.inc.php
	rm /var/www/spotweb/dbsettings.inc.php
	ln -s /config/dbsettings.inc.php /var/www/spotweb/dbsettings.inc.php

	# Run database update
	/usr/bin/php /var/www/spotweb/upgrade-db.php
else
	echo "WARNING: You have no database configuration file, either create /config/dbsettings.inc.php or restart this container with the correct environment variables to auto generate the config."
fi

echo "Updating PHP time zone"
TIMEZONE=${TIMEZONE:-"Europe/Amsterdam"}
sed -i "s#^;date.timezone =.*#date.timezone = ${TIMEZONE}#g" /etc/php5/*/php.ini

echo "Enabling PHP mod rewrite"
/usr/sbin/a2enmod rewrite

echo "Updating hourly cron"
(crontab -l ; echo "${SPOTWEB_CRON} /usr/bin/php /var/www/spotweb/retrieve.php | tee /var/log/spotweb-retrieve.log") | crontab -

/etc/init.d/apache2 restart
tail -F /var/log/apache2/*