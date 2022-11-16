FROM yobasystems/alpine-mariadb:latest

ENV MYSQL_ROOT_PASSWORD csc547cloud
ENV MYSQL_DATABASE Products
ENV MYSQL_USER csc547
ENV MYSQL_PASSWORD csc547cloud

ADD https://raw.githubusercontent.com/TyroneWu547/footwear-webstore-cloudops/main/webstore-microservice/database/populate_db.sql /docker-entrypoint-initdb.d/

RUN chmod -R 775 /docker-entrypoint-initdb.d/ && \
    chown -R mysql:mysql /docker-entrypoint-initdb.d/
