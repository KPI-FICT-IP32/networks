FROM alpine:3.7
RUN apk add --no-cache nginx openssl apache2-utils
RUN mkdir -p /usr/local/http /usr/home/http /cert /config
COPY ./gencert.sh /bin/gencert.sh
