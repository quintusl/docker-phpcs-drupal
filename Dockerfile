FROM php:8.1-cli
LABEL maintainer="Quintus Leung"

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN apt-get update && apt-get install -y \
		git \
		curl \
		libicu-dev \
		libxml2-dev \
		libzip-dev \
		libcurl4-openssl-dev \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-install gd bcmath curl zip

ENV PATH="/root/.composer/vendor/bin:$PATH"
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer global config --no-plugins allow-plugins.mglaman/composer-drupal-lenient true
RUN composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
RUN composer global require "squizlabs/php_codesniffer=*"
RUN composer global require "micheh/phpcs-gitlab"
RUN composer global require drupal/coder:8.3.13
RUN composer global require drupal/coder
RUN composer global update --with-dependencies drupal/coder
RUN composer global require mglaman/composer-drupal-lenient
RUN /root/.composer/vendor/bin/phpcs --config-set installed_paths /root/.composer/vendor/drupal/coder/coder_sniffer
RUN git config --global --add safe.directory /drupal

RUN mkdir /output
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /drupal
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
