FROM ubuntu:14.04
MAINTAINER Phil Dodd "tripper54@gmail.com"
ENV REFRESHED_AT 2016-03-10

# avoid debconf and initrd
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

RUN apt-get update && apt-get install -y apache2 php5 php5-mysql php5-mcrypt \
php5-curl php5-gd php5-imagick cron
RUN apt-get install -y libapache2-mod-php5

# eyeD3 MP3 tag inspector
RUN apt-get install -y eyeD3

# image compression
RUN apt-get install -y advancecomp pngcrush gifsicle jpegoptim libjpeg-progs libjpeg8-dbg \
libimage-exiftool-perl imagemagick pngnq libpng-dev pngquant optipng libjpeg-turbo-progs \
libav-tools

# s3fuse
RUN apt-get install -y automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config git
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git
RUN cd s3fs-fuse
RUN cd s3fs-fuse && ./autogen.sh && ./configure && make && make install

#supervisord
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

#supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor

#apache env vars
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

#apache modules and config
RUN a2enmod rewrite
ADD apache/000-default.conf /etc/apache2/sites-available/000-default.conf

#php config
RUN rm -rf /etc/php5/apache2/conf.d
RUN rm /etc/php5/apache2/php.ini
ADD php /etc/php5/apache2


EXPOSE 80
CMD ["/usr/bin/supervisord"]

