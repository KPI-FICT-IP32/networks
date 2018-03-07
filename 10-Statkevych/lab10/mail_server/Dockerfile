FROM ubuntu:xenial

RUN apt-get update -y
RUN apt-get install vim -y
RUN apt-get install sendmail -y
RUN apt-get install rsyslog -y
RUN apt-get install vim -y
RUN apt-get install dnsutils -y

COPY ./entrypoint.sh /entrypoint.sh
COPY sendmail.mc /etc/mail/sendmail.mc

ENTRYPOINT sh /entrypoint.sh