# nginx-php image 
#   docker build -t elarasu/weave-nginx-php7 .
#
FROM elarasu/weave-supervisord
MAINTAINER elarasu@outlook.com

# Install requirements
RUN  apt-get update  \
  && apt-get install -yq software-properties-common ssh nodejs sudo cron git sendmail fetchmail ca-certificates nodejs-legacy npm python-pygments \
       build-essential g++ nginx --no-install-recommends

  #&& apt-get install -yq software-properties-common \
  #&& add-apt-repository ppa:ondrej/php \
  #&& apt-get update \

# Install php components
RUN  add-apt-repository ppa:ondrej/php \
  && apt-get update \
  && apt-get install -yq php7.0 php7.0-fpm php7.0-mysql \
       php7.0-mcrypt php7.0-intl php7.0-gd php7.0-dev php7.0-curl php7.0-ldap php7.0-imap php7.0-mbstring php7.0-soap php-pear --no-install-recommends \
  && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Expose Nginx on port 80 and 443
EXPOSE 80
EXPOSE 443

# Add service config files
ADD conf/fastcgi.conf /etc/nginx/
ADD conf/nginx.conf /etc/nginx/
ADD conf/php.ini-production /etc/php/7.0/fpm/php.ini
ADD conf/php.ini-production /etc/php/7.0/cli/php.ini

# Add Supervisord config files
ADD conf/cron.sv.conf /etc/supervisor/conf.d/
ADD conf/nginx.sv.conf /etc/supervisor/conf.d/
ADD conf/php7-fpm.sv.conf /etc/supervisor/conf.d/

CMD supervisord

