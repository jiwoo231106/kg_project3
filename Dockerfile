FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y vim apache2 \
       && mv /etc/localtime /etc/localtime_org \
       && ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN mkdir /etc/apache2/logs
COPY 000-default.conf /etc/apache2/sites-available/
COPY 000-default.conf /etc/apache2/sites-enabled/
RUN a2enmod proxy_http
RUN service apache2 start
EXPOSE 80
CMD apachectl -DFOREGROUND

