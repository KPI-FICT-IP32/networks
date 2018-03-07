FROM ubuntu:xenial

RUN apt-get update -y
RUN apt-get install bind9 bind9utils bind9-doc dnsutils -y
RUN apt-get install vim -y
RUN apt-get install sendmail -y

# Copy BIND configurations to server
COPY ./named/bind9 /etc/default/bind9
COPY ./named/named.conf.local /etc/bind/named.conf.local
COPY ./named/named.conf.options /etc/bind/named.conf.options

COPY ./named/zones/zone10.org.ua /etc/bind/zones/zone10.org.ua

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT sh /entrypoint.sh