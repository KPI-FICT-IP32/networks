FROM ubuntu:xenial

RUN apt-get update -y
RUN apt-get install dnsutils -y
RUN apt-get install rsyslog -y
RUN apt-get install sendmail -y
RUN apt-get install vim -y

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT sh /entrypoint.sh