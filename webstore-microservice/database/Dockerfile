FROM mariadb:latest

ENV MYSQL_ROOT_PASSWORD csc547cloud
ENV MYSQL_DATABASE Products
ENV MYSQL_USER csc547
ENV MYSQL_PASSWORD csc547cloud

ADD https://raw.githubusercontent.com/TyroneWu547/footwear-webstore-cloudops/main/webstore-microservice/database/DatabaseSetup.sql /docker-entrypoint-initdb.d/DatabaseSetup.sql

EXPOSE 3306
