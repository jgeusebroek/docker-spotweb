[![](https://images.microbadger.com/badges/image/jgeusebroek/spotweb.svg)](https://microbadger.com/images/jgeusebroek/spotweb "Get your own image badge on microbadger.com")
# Docker Spotweb image

An image running [ubuntu/17.10](https://github.com/ubuntu/17.10) Linux and [Spotweb](https://github.com/spotweb/spotweb).

## Requirements

You need a seperate MySQL / MariaDB server. This can of course be a (linked) docker container but also a dedicated database server.


## Usage

### Initial Installation

First create a database on your database server, and make sure the container has access to the database, then run a temporary container.

	docker run -it --rm -p 80:80 \
		-e TZ='Europe/Amsterdam' \
		jgeusebroek/spotweb

Please NOTE that there is no database configuration here, this will enable the install process.

The run the Spotweb installer using the web interface: 'http://yourhost/install.php'.
This will create the necessary database tables and users. Ignore the warning when it tries to save the configuration.

When you are done, exit the container (CTRL/CMD-c) and configure the permanent running container.

### Permanent installation

	docker run --restart=always -d -p 80:80 \
		--hostname=spotweb \
		--name=spotweb \
		-v <hostdir_where_config_will_persistently_be_stored>:/config \
		-e TZ='Europe/Amsterdam' \
		-e SPOTWEB_DB_TYPE=pdo_mysql \
		-e SPOTWEB_DB_HOST=<database_server_hostname> \
		-e SPOTWEB_DB_NAME=spotweb \
		-e SPOTWEB_DB_USER=spotweb \
		-e SPOTWEB_DB_PASS=spotweb \
		jgeusebroek/spotweb

Please NOTE that the volume is optional. Only necessary when you have special configuration settings.

You should now be able to reach the spotweb interface on port 80.

### Automatic retreiving of new spots

To enable automatic retreiving, you need to setup a cronjob on the docker host.

	*/15 * * * * docker exec spotweb /usr/bin/php /var/www/spotweb/retrieve.php >/dev/null 2>&1

This example will retrieve new spots every 15 minutes.

### Updates

The container will try to auto-update the database when a newer version is released.

### Environment variables

* `TZ` The timezone the server is running in. Defaults to `Europe/Amsterdam`.
* `SPOTWEB_DB_TYPE` Database type. Use `pdo_mysql` for MySQL.
* `SPOTWEB_DB_HOST` The hostname / IP of the database server.
* `SPOTWEB_DB_NAME` The database used for spotweb.
* `SPOTWEB_DB_USER` The database server username.
* `SPOTWEB_DB_PASS` The database server password.

## License

MIT / BSD

## Author Information

[Jeroen Geusebroek](https://jeroengeusebroek.nl/)