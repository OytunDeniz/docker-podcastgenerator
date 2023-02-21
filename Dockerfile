FROM debian:latest

LABEL maintainer="Oytun Deniz <oytun.deniz@gmail.com>" \
    name="podcastgenerator" \
    version="3.2.9"


ENV HOME /root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && \
    apt-get install -y --no-install-recommends nginx php-fpm php-xml ca-certificates unzip wget vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PODCASTGEN_VERSION=3.2.9



RUN mkdir -p /media /images

ADD php.ini /etc/php/7.4/fpm/php.ini
ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available

ADD run.sh /run/run.sh
RUN chmod +x /run/run.sh

ENV LC_ALL C.UTF-8
ENV TERM xterm

ENV DIR /var/www/PodcastGenerator

RUN wget -O /tmp/podcastgen.zip \
    https://github.com/albertobeta/PodcastGenerator/archive/v${PODCASTGEN_VERSION}.zip
RUN unzip /tmp/podcastgen.zip && \
    cp -r PodcastGenerator-${PODCASTGEN_VERSION}/PodcastGenerator/ /var/www && \
    chown -R www-data:www-data /var/www/ && \
    rm /tmp/podcastgen.zip && \
    rm -rf /var/www/PodcastGenerator/media /var/www/PodcastGenerator/images && \
    ln -s /media /var/www/PodcastGenerator/media && \
    ln -s /images /var/www/PodcastGenerator/images

WORKDIR /var/www/PodcastGenerator
RUN wget -O composer-setup.php https://getcomposer.org/installer && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer && \
    composer require james-heinrich/getid3:* --ignore-platform-reqs

EXPOSE 80
VOLUME [ "/media", "/images" ]


CMD ["/run/run.sh"]
