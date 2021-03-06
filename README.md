# `docker-util`

A bulky image with all kinds of utility installed. You can use it to link to
existing containers and do things to them, while they're running.

## Get a db prompt in a mysql container
~~~
docker run --name "db" -e MYSQL_ROOT_PASSWORD -d mariadb
docker run --rm -ti --link db:db adimit/util /bin/sh -c 'mysql -uroot -hdb -p${DB_ENV_MYSQL_ROOT_PASSWORD}'
~~~

## Open a stream to a service
~~~
docker run --name memcache -d memcached
docker run --rm -ti --link memcache:mc adimit/util telnet mc 11211
~~~

(You could also use netcat.)

# License

This repository is public domain.