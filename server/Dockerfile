FROM rockylinux:9

RUN dnf update -y && dnf -y upgrade && dnf install -y sudo yum-utils unzip wget git \
    bash-completion policycoreutils-python-utils bzip2 httpd && \
    dnf -y install epel-release https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %rhel).rpm && \
    dnf -y module reset php && dnf -y module enable php:remi-8.3 && dnf -y config-manager --set-enabled crb && \
    dnf -y update && dnf install -y php php-cli php-gd php-mbstring php-intl php-pecl-apcu php-sodium php-ldap ffmpeg-free libreoffice \
    php-mysqlnd php-opcache php-json php-zip php-redis supervisor php-process mod_ssl php-bcmath php-gmp php-pecl-imagick-im7 && \
    dnf -y clean all && \
    git clone https://github.com/LT-Linas35/nextcloud_server.git /var/www/html/nextcloud && \
    mkdir -p /var/www/html/nextcloud/data && chown -R apache /var/www/html/nextcloud && \
    chmod -R 755 /var/www/html/nextcloud && mkdir -p /var/run/php-fpm/
RUN sudo sed -i 's/;php_admin_value\[memory_limit\] = 128M/php_admin_value[memory_limit] = 512M/' /etc/php-fpm.d/www.conf


#RUN rpm -Uvh http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm && \
#    curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && \
#    dnf -y install newrelic-php5

#RUN --mount=type=secret,id=NEW_RELIC_API_KEY_PHP \
#    --mount=type=secret,id=NEW_RELIC_ACCOUNT_ID_PHP \
#    --mount=type=secret,id=NR_INSTALL_KEY_PHP \
#    NEW_RELIC_API_KEY=$(cat /run/secrets/NEW_RELIC_API_KEY_PHP) && \
#    NEW_RELIC_ACCOUNT_ID=$(cat /run/secrets/NEW_RELIC_ACCOUNT_ID_PHP) && \
#    NR_INSTALL_KEY=$(cat /run/secrets/NR_INSTALL_KEY_PHP) && \
#    NEW_RELIC_REGION=EU NR_INSTALL_SILENT=1 newrelic-install install && \
#    find /etc /opt/etc /usr/local/etc -type f -name newrelic.ini -exec sed -i -e "s/$NEW_RELIC_API_KEY/$NR_INSTALL_KEY/" -e "s/newrelic.appname[[:space:]]=[[:space:]].*/newrelic.appname = \"nextcloud\"/" {} \; 2>/dev/null && \
#    NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -n logs-integration
WORKDIR /var/www/html/nextcloud
RUN sudo -u apache php occ db:add-missing-indices
COPY nextcloud.conf /etc/httpd/conf.d/
COPY .htaccess .
COPY generate_keys.sh /tmp/
RUN chmod +x /tmp/generate_keys.sh
COPY supervisord.conf /etc/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

