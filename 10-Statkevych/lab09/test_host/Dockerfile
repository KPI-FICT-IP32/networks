FROM ubuntu:xenial

RUN apt-get update -y
RUN apt-get install dnsutils -y

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT sh /entrypoint.sh