FROM php:7.4.33-apache

ENV DATABASE_NAME database

ADD https://raw.github.ncsu.edu/rrangar/AWS_aaS/main/4%20Microservices%20Buy%20IaaS/buyProducts.php?token=GHSAT0AAAAAAAAAWN5P3CGZF7TKGVFFYXWAY3X4CZA /var/www/html/buyProducts.php

RUN chmod -R 755 /var/www/html/

RUN sed -i "s/<database-public-IPv4-address>/${DATABASE_NAME}/g" /var/www/html/buyProducts.php

RUN docker-php-ext-install mysqli

EXPOSE 80
