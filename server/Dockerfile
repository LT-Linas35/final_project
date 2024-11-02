FROM rockylinux:9.3 AS first_stage

RUN <<EOF
    dnf -y update
    dnf -y upgrade 
    dnf -y install \
        sudo \
        yum-utils \
        unzip \
        wget \
        git \
        bash-completion \
        policycoreutils-python-utils \
        bzip2 \
        httpd
    dnf -y install epel-release https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %rhel).rpm
    dnf -y module reset php
    dnf -y module enable php:remi-8.3
    dnf -y config-manager --set-enabled crb
    dnf -y update
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
        php-pecl-imagick-im7
EOF

FROM first_stage AS second_stage

RUN <<EOF
    LATEST_TAG="$(curl --silent "https://api.github.com/repos/LT-Linas35/nextcloud_server/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')" 
    git clone --branch $LATEST_TAG --depth 1 https://github.com/LT-Linas35/nextcloud_server.git /var/www/html/nextcloud
EOF

COPY nextcloud.conf /etc/httpd/conf.d/
#COPY .htaccess /var/www/html/nextcloud/.htaccess
COPY supervisord.conf /etc/

RUN <<EOF
    mkdir -p /var/www/html/nextcloud/data 
    chown -R apache /var/www/html/nextcloud
    chmod -R 755 /var/www/html/nextcloud
    sed -i 's/;php_admin_value\[memory_limit\] = 128M/php_admin_value[memory_limit] = 512M/' /etc/php-fpm.d/www.conf
    sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php.ini
    echo "apc.enable_cli = 1" >> /etc/php.ini
cat <<EOL >> /etc/php.d/10-opcache.ini
opcache.interned_strings_buffer=32
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=60
opcache.jit=1255
opcache.jit_buffer_size=128M
EOL
EOF
FROM second_stage AS third_tage

RUN --mount=type=secret,id=NEW_RELIC_API_KEY_PHP \
    --mount=type=secret,id=NR_INSTALL_KEY_PHP \
    export NEW_RELIC_API_KEY=$(cat /run/secrets/NEW_RELIC_API_KEY_PHP) && \
    export NR_INSTALL_KEY=$(cat /run/secrets/NR_INSTALL_KEY_PHP) && \
    rpm -Uvh http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm && \
    dnf -y install newrelic-php5 && NR_INSTALL_SILENT=1 newrelic-install install all && \
    find /etc -type f -name newrelic.ini -exec sed -i -e "s/$NEW_RELIC_API_KEY/$NR_INSTALL_KEY/" -e "s/newrelic.appname[[:space:]]=[[:space:]].*/newrelic.appname = \"NextCloud\"/" {} \; && \
    dnf -y clean all && \
    unset NEW_RELIC_API_KEY NR_INSTALL_KEY

FROM third_tage AS final

WORKDIR /var/www/html/nextcloud

COPY .htaccess /var/www/html/nextcloud/

RUN  <<EOF
mkdir -p ./data/.ocdata 
mkdir -p /run/php-fpm 
chown -R apache /var/www/html/nextcloud
chmod -R 755 /var/www/html/nextcloud # twice to make sure right permissions
chown apache /run/php-fpm
EOF

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
