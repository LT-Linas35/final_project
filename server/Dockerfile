FROM redhat/ubi9:latest

RUN dnf update -y && dnf -y upgrade


RUN dnf install -y  yum-utils unzip wget git \
                    bash-completion policycoreutils-python-utils bzip2 \
                    httpd 

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm

RUN dnf -y module reset php
RUN dnf -y module install php:remi-8.2
RUN dnf -y update

RUN dnf install -y  php php-cli php-gd php-mbstring php-intl php-pecl-apcu \
                    php-mysqlnd php-opcache php-json php-zip

RUN dnf install -y php-redis 
#php-imagick

RUN git clone https://github.com/LT-Linas35/nextcloud_server.git /var/www/html/nextcloud
# Ta date reikia primountinti
RUN mkdir -p /var/www/html/nextcloud/data
RUN chown -R apache:apache /var/www/html/nextcloud
RUN chmod -R 755 /var/www/html/nextcloud

RUN mkdir -p /var/run/php-fpm/
#RUN rm -dR /etc/httpd/conf.d/*
COPY nextcloud.conf /etc/httpd/conf.d/
#COPY ca.key /etc/ssl/certs/
#COPY ca.crt /etc/ssl/certs/



CMD ["bash", "-c", "php-fpm && httpd -DFOREGROUND"]
