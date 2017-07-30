FROM shelvak/baseimage

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r postgres && useradd -r -g postgres postgres

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8


RUN apt-get update && rm -rf /var/lib/apt/lists/* \
	&& curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
  && apt-get install -y locales cron \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -y autoremove clean autoclean

ENV LANG en_US.utf8
ENV PG_MAJOR 9.3
ENV PG_VERSION 9.3.6-1.pgdg70+1
ENV POSTGIS_MAJOR 2.1
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

RUN apt-get update \
	&& apt-get install -y postgresql-common \
		postgresql-$PG_MAJOR \
		postgresql-contrib-$PG_MAJOR \
		postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
    postgis \
	&& rm -rf /var/lib/apt/lists/* \
  && apt-get -y clean autoclean autoremove

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

VOLUME /var/lib/postgresql/

ADD pgdump /etc/cron.daily/pgdump
RUN chmod 777 /etc/cron.daily/pgdump

RUN cron

RUN mkdir /docker-entrypoint-initdb.d
ADD docker-entrypoint.sh /
RUN chmod 777 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
