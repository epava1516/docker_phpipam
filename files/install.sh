#!/bin/bash

apt update
apt -y install git php php-{mysql,curl,gd,intl,pear,imap,memcache,pspell,recode,tidy,xmlrpc,mbstring,gettext,gmp,json,xml,fpm,cli,ldap,apcu,cas}

git clone --recursive https://github.com/phpipam/phpipam.git /var/www/phpipam
chown -R nginx:nginx /var/www/phpipam

sed 's/^\;listen.mode = 0660/listen.mode = 0660/g' -i /etc/php/7.3/fpm/pool.d/www.conf
sed 's/www-data/nginx/g' -i /etc/php/7.3/fpm/pool.d/www.conf
mkdir /run/php

rm -rf /etc/nginx/conf.d/*.conf

cat> /etc/nginx/fastcgi_params <<EOF
fastcgi_param  QUERY_STRING       \$query_string;
fastcgi_param  REQUEST_METHOD     \$request_method;
fastcgi_param  CONTENT_TYPE       \$content_type;
fastcgi_param  CONTENT_LENGTH     \$content_length;

fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
fastcgi_param  SCRIPT_NAME        \$fastcgi_script_name;
fastcgi_param  REQUEST_URI        \$request_uri;
fastcgi_param  DOCUMENT_URI       \$document_uri;
fastcgi_param  DOCUMENT_ROOT      \$document_root;
fastcgi_param  SERVER_PROTOCOL    \$server_protocol;
fastcgi_param  REQUEST_SCHEME     \$scheme;
fastcgi_param  HTTPS              \$https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/\$nginx_version;

fastcgi_param  REMOTE_ADDR        \$remote_addr;
fastcgi_param  REMOTE_PORT        \$remote_port;
fastcgi_param  SERVER_ADDR        \$server_addr;
fastcgi_param  SERVER_PORT        \$server_port;
fastcgi_param  SERVER_NAME        \$server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
EOF

cat > /etc/nginx/conf.d/phpipam.conf <<EOF
server {
    listen       80;
    server_name  localhost;
    root   /var/www/phpipam;
    index index.php;
    charset utf-8;

    # php-fpm
    location ~ \.php$ {
        fastcgi_pass   unix:/run/php/php7.3-fpm.sock;
        fastcgi_index  index.php;
        include        /etc/nginx/fastcgi_params;
    }
}
EOF