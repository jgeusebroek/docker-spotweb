# Docker spotweb
	docker run --restart=always -d -p 80:80 \
		--hostname=spotweb \
		--name=spotweb \
		-v /config:/config \
		-e SPOTWEB_DB_TYPE=pdo_mysql \
		-e SPOTWEB_DB_HOST=<hostname> \
		-e SPOTWEB_DB_NAME=spotweb \
		-e SPOTWEB_DB_USER=spotweb \
		-e SPOTWEB_DB_PASS=spotweb \
		jgeusebroek/spotweb