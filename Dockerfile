FROM olafbroms/asrc:asrc-php7.2-apache2

# move oracle instant client binaries to container
COPY dock-files/instantclient-basic-linux.x64-12.1.0.2.0.zip /opt/oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip
COPY dock-files/instantclient-sdk-linux.x64-12.1.0.2.0.zip /opt/oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip
COPY dock-files/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip /opt/oracle/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip

# apt-get update and needed packages
RUN apt-get update && apt-get install -qqy git unzip libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        default-mysql-client \
        nodejs \
        npm \
        libaio1 wget && apt-get clean autoclean && apt-get autoremove --yes &&  rm -rf /var/lib/{apt,dpkg,cache,log}/ 

#composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ORACLE oci 
RUN cd /opt/oracle 

# Install Oracle Instantclient
RUN  unzip /opt/oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && ln -s /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so \
    && ln -s /opt/oracle/instantclient_12_1/libclntshcore.so.12.1 /opt/oracle/instantclient_12_1/libclntshcore.so \
    && ln -s /opt/oracle/instantclient_12_1/libocci.so.12.1 /opt/oracle/instantclient_12_1/libocci.so \
    && rm -rf /opt/oracle/*.zip
    
ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_12_1:${LD_LIBRARY_PATH}
    
# Install Oracle php extensions
RUN echo 'instantclient,/opt/oracle/instantclient_12_1/' | pecl install oci8 \ 
      && docker-php-ext-enable \
               oci8 \ 
       && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_12_1,12.1 \
       && docker-php-ext-install \
               pdo_oci 
RUN docker-php-ext-install pdo_mysql

# get php code sniffer
RUN wget -O /tmp/phpcs.phar https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
RUN cp /tmp/phpcs.phar /usr/local/bin/phpcs
RUN chmod +x /usr/local/bin/phpcs

# set phpcs config
RUN /usr/local/bin/phpcs --config-set show_progress 1 && \
    /usr/local/bin/phpcs --config-set colors 1 && \
    /usr/local/bin/phpcs --config-set report_width 140 && \
    /usr/local/bin/phpcs --config-set encoding utf-8

# get php code beautifier
RUN wget -O /tmp/phpcbf.phar https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar
RUN cp /tmp/phpcbf.phar /usr/local/bin/phpcbf
RUN chmod +x /usr/local/bin/phpcbf