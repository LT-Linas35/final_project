FROM rockylinux:9.3 AS first_stage

RUN \
    dnf -y update \
&& \
    dnf -y upgrade \
&& \
    dnf install -y \
        sudo \
        yum-utils \
        unzip \
        wget \
        git \
        bash-completion \
        policycoreutils-python-utils \
        bzip2 \
        httpd \
&& \
    dnf -y install epel-release https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %rhel).rpm \
&& \
    dnf -y module reset php \
&& \
    dnf -y module enable php:remi-8.3 \
&& \
    dnf -y config-manager --set-enabled crb \
&& \
    dnf -y update \
&& \
    dnf -y install \
        php \
        php-cli \
        php-gd \
        php-mbstring \
        php-intl \
        php-pecl-apcu \
        php-sodium \
        php-ldap \
        ffmpeg-free \
        libreoffice \
        php-mysqlnd \
        php-opcache \
        php-json \
        php-zip \
        php-redis \
        supervisor \
        php-process \
        php-bcmath \
        php-gmp \
        php-pecl-imagick-im7 \
&& \
    dnf -y clean all

FROM first_stage AS second_stage

RUN \
    LATEST_TAG="$(curl --silent "https://api.github.com/repos/LT-Linas35/nextcloud_server/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')" \
&& \
    git clone --branch $LATEST_TAG --depth 1 https://github.com/LT-Linas35/nextcloud_server.git /var/www/html/nextcloud

COPY nextcloud.conf /etc/httpd/conf.d/
COPY .htaccess /var/www/html/nextcloud/.htaccess
COPY supervisord.conf /etc/

RUN \
    mkdir -p /var/www/html/nextcloud/data \
&& \
    chown -R apache /var/www/html/nextcloud \
&& \
    chmod -R 755 /var/www/html/nextcloud \
&& \
    mkdir -p /var/run/php-fpm/ \
&& \
    sed -i 's/;php_admin_value\[memory_limit\] = 128M/php_admin_value[memory_limit] = 512M/' /etc/php-fpm.d/www.conf \
&& \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php.ini \
&& \
    echo "apc.enable_cli = 1" >> /etc/php.ini

FROM second_stage AS third_tage

RUN \
    --mount=type=secret,id=NEW_RELIC_API_KEY_PHP \
    --mount=type=secret,id=NR_INSTALL_KEY_PHP \
&& \
    NEW_RELIC_API_KEY=$(cat /run/secrets/NEW_RELIC_API_KEY_PHP) \
&& \
    NR_INSTALL_KEY=$(cat /run/secrets/NR_INSTALL_KEY_PHP) \
&& \
    rpm -Uvh http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm \
&& \
    dnf -y install newrelic-php5 \
&& \
    NR_INSTALL_SILENT=1 newrelic-install install all \
&& \
    find /etc /opt/etc /usr/local/etc -type f -name newrelic.ini -exec sed -i -e "s/$NEW_RELIC_API_KEY/$NR_INSTALL_KEY/" -e "s/newrelic.appname[[:space:]]=[[:space:]].*/newrelic.appname = \"NextCloud\"/" {} \; 2>/dev/null \
&& \
    unset NEW_RELIC_API_KEY NEW_RELIC_ACCOUNT_ID NR_INSTALL_KEY

FROM third_tage AS final

WORKDIR /var/www/html/nextcloud
#USER apache
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
