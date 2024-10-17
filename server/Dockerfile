FROM rockylinux:9.3 AS first_stage

RUN dnf update -y && dnf -y upgrade 

FROM first_stage AS second_stage

RUN dnf install -y sudo yum-utils unzip wget git \
    bash-completion policycoreutils-python-utils bzip2 httpd

FROM second_stage AS third_stage

RUN dnf -y install epel-release https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %rhel).rpm && \
    dnf -y module reset php && dnf -y module enable php:remi-8.3 && dnf -y config-manager --set-enabled crb && \
    dnf -y update && dnf install -y php php-cli php-gd php-mbstring php-intl php-pecl-apcu php-sodium php-ldap ffmpeg-free libreoffice \
    php-mysqlnd php-opcache php-json php-zip php-redis supervisor php-process php-bcmath php-gmp php-pecl-imagick-im7 && \
    dnf -y clean all && sed -i 's/;php_admin_value\[memory_limit\] = 128M/php_admin_value[memory_limit] = 512M/' /etc/php-fpm.d/www.conf && \
    echo "extension=apcu.so" >> /etc/php.ini

FROM third_stage AS fouth_stage

RUN  git clone https://github.com/LT-Linas35/nextcloud_server.git /var/www/html/nextcloud && \
     mkdir -p /var/www/html/nextcloud/data && chown -R apache /var/www/html/nextcloud && \
     chmod -R 755 /var/www/html/nextcloud && mkdir -p /var/run/php-fpm/
COPY nextcloud.conf /etc/httpd/conf.d/
COPY .htaccess .
COPY supervisord.conf /etc/

FROM fouth_stage AS fifth_stage

RUN --mount=type=secret,id=NEW_RELIC_API_KEY_PHP \
    --mount=type=secret,id=NEW_RELIC_ACCOUNT_ID_PHP \
    --mount=type=secret,id=NR_INSTALL_KEY_PHP \
    export NEW_RELIC_API_KEY=$(cat /run/secrets/NEW_RELIC_API_KEY_PHP) && \
    export NEW_RELIC_ACCOUNT_ID=$(cat /run/secrets/NEW_RELIC_ACCOUNT_ID_PHP) && \
    export NR_INSTALL_KEY=$(cat /run/secrets/NR_INSTALL_KEY_PHP) && \
    rpm -Uvh http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm && \
    dnf -y install newrelic-php5 && NR_INSTALL_SILENT=1 newrelic-install install all \
    find /etc /opt/etc /usr/local/etc -type f -name newrelic.ini -exec sed -i -e "s/$NEW_RELIC_API_KEY/$NR_INSTALL_KEY/" -e "s/newrelic.appname[[:space:]]=[[:space:]].*/newrelic.appname = \"NextCloud\"/" {} \; 2>/dev/null
#curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -n logs-integration && unset NEW_RELIC_API_KEY NEW_RELIC_ACCOUNT_ID NR_INSTALL_KEY    

FROM fifth_stage AS main

WORKDIR /var/www/html/nextcloud
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

