# FROM mariadb:10.5.26-focal
FROM mariadb:10.6.19-focal
RUN apt-get update \
    && apt-get install -y make gcc default-libmysqlclient-dev

WORKDIR /workdir

COPY . .

RUN ./configure \
    && make \
    && make install

