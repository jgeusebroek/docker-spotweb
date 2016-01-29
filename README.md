[![](https://badge.imagelayers.io/jgeusebroek/spotweb:latest.svg)](https://imagelayers.io/?images=jgeusebroek/spotweb:latest 'Get your own badge on imagelayers.io')

# Docker Spotweb image

An image running [ubuntu/15.10](https://github.com/gliderlabs/docker-alpine) Linux and [Spotweb](https://github.com/spotweb/spotweb) (media branch).

This image is mainly for own use, but it seems to a be populair image so I decided to provide some documentation.

## MySQL

You need a seperate MySQL / MariaDB server. This can be a ofcourse be a (linked) docker container but also a dedicated database server.

## Updates

The container will try to auto-update the database when a newer version image is  released.

## Usage

	docker run --restart=always -d -p 80:80 \
		--hostname=spotweb \
		--name=spotweb \
		-v <hostdir_where_config_will_persistently_be_stored>:/config \
		-e TZ='Europe/Amsterdam'
		-e SPOTWEB_DB_TYPE=pdo_mysql \
		-e SPOTWEB_DB_HOST=<database_server_hostname> \
		-e SPOTWEB_DB_NAME=spotweb \
		-e SPOTWEB_DB_USER=spotweb \
		-e SPOTWEB_DB_PASS=spotweb \
		jgeusebroek/spotweb

You should now be able to reach the spotweb interface on port 80, and you can configure Spotweb.

## Environment variables

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