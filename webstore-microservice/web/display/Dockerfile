FROM php:7.4.33-apache

ENV DATABASE_NAME database

ADD https://raw.github.ncsu.edu/rrangar/AWS_aaS/main/3%20Microservices%20Display%20IaaS/displayProducts.php?token=GHSAT0AAAAAAAAAWN5PTEANNHQZR4Z3AVXQY3X4ADQ /var/www/html/displayProducts.php

RUN chmod -R 755 /var/www/html/

RUN sed -i "s/<database-public-IPv4-address>/${DATABASE_NAME}/g" /var/www/html/displayProducts.php

RUN docker-php-ext-install mysqli

EXPOSE 80
