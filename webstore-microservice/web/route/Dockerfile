FROM php:7.4.33-apache

ADD https://raw.github.ncsu.edu/rrangar/AWS_aaS/main/5%20Microservices%20Route%20IaaS/products.js?token=GHSAT0AAAAAAAAAWN5PNXD2DZVTMV5WM3D6Y3X33GA /var/www/html/products.js
ADD https://raw.github.ncsu.edu/rrangar/AWS_aaS/main/5%20Microservices%20Route%20IaaS/products.php?token=GHSAT0AAAAAAAAAWN5OJGVYKNTHUS45CB2CY3X33PQ /var/www/html/products.php

RUN chmod -R 755 /var/www/html/

RUN sed -i "s/\/displayProducts\.php/:80\/displayProducts\.php/g" /var/www/html/products.php
RUN sed -i "s/\/buyProducts\.php/:80\/buyProducts\.php/g" /var/www/html/products.php

RUN docker-php-ext-install mysqli

EXPOSE 80
