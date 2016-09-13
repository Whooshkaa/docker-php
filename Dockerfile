FROM ubuntu:16.04
MAINTAINER Phil Dodd "tripper54@gmail.com"
ENV REFRESHED_AT 2016-09-13

# avoid debconf and initrd
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

RUN apt-get update && apt-get install -y apache2 php php-mysql php-mcrypt \
php-curl php-gd php-imagick cron
RUN apt-get install -y libapache2-mod-php
RUN apt-get install -y wget

# eyed3 MP3 tag inspector
RUN apt-get install -y eyed3

# command to add repositories
RUN apt-get install -y software-properties-common

# audio waveform generator
RUN apt-get install -y git-core make cmake gcc g++ libmad0-dev libsndfile1-dev \
  libgd2-xpm-dev libboost-filesystem-dev libboost-program-options-dev \
  libboost-regex-dev
RUN git clone https://github.com/bbcrd/audiowaveform.git
RUN mkdir /audiowaveform/build
WORKDIR /audiowaveform
RUN wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz
RUN tar xzf release-1.8.0.tar.gz
RUN ln -s googletest-release-1.8.0/googletest googletest
RUN ln -s googletest-release-1.8.0/googlemock googlemock
WORKDIR /audiowaveform/build
RUN cmake ..
RUN make
WORKDIR /



# image compression
RUN apt-get install -y advancecomp pngcrush gifsicle jpegoptim libjpeg8-dbg \
libimage-exiftool-perl imagemagick pngnq libpng-dev pngquant optipng libjpeg-turbo-progs \
libav-tools

# s3fuse
RUN apt-get install -y automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config git
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git
RUN cd s3fs-fuse
RUN cd s3fs-fuse && ./autogen.sh && ./configure && make && make install

# Filebeat to send logs to ELK stack
RUN apt-get install apt-transport-https -y
RUN echo "deb https://packages.elastic.co/beats/apt stable main" |  tee -a /etc/apt/sources.list.d/beats.list
RUN apt-get update -y
RUN apt-get install filebeat -y --force-yes

# Python and aws cli to copy things from s3
RUN apt-get -y install python-pip
RUN pip install awscli

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
#RUN rm -rf /etc/php5/apache2/conf.d
#RUN rm /etc/php5/apache2/php.ini
#ADD php /etc/php5/apache2


EXPOSE 80
CMD ["/usr/bin/supervisord"]

