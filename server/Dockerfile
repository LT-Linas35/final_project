FROM redhat/ubi9:9.4

RUN dnf update -y && dnf -y upgrade && dnf install -y  yum-utils unzip wget git \
    bash-completion policycoreutils-python-utils bzip2 httpd && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm && \
    dnf -y module reset php && dnf -y module install php:remi-8.2 && \
    dnf -y update && dnf install -y  php php-cli php-gd php-mbstring php-intl php-pecl-apcu \
    php-mysqlnd php-opcache php-json php-zip && dnf install -y php-redis && \  #php-imagick
    git clone https://github.com/LT-Linas35/nextcloud_server.git /var/www/html/nextcloud && \
    mkdir -p /var/www/html/nextcloud/data && chown -R apache:apache /var/www/html/nextcloud && \
    chmod -R 755 /var/www/html/nextcloud && mkdir -p /var/run/php-fpm/ && rm -dR /etc/httpd/conf.d/* # Ta date reikia primountinti

    

COPY nextcloud.conf /etc/httpd/conf.d/
#COPY ca.key /etc/ssl/certs/
#COPY ca.crt /etc/ssl/certs/

CMD ["bash", "-c", "php-fpm && httpd -DFOREGROUND"]
