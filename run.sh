#!/bin/bash 

service php7.4-fpm start
service nginx start && tail -f /var/log/nginx/error.log
