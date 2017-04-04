# docker build -t yuanying/keepalived .
# docker run --privileged yuanying/keepalived

FROM alpine:latest
MAINTAINER OTSUKA, Yuanying "yuan-docker@fraction.jp"

COPY start.sh /

RUN apk --no-cache add \
    keepalived \
    netcat-openbsd; \
    rm -rf /var/cache/apk/*; \
    chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
CMD ["/usr/sbin/keepalived", "-f", "/etc/keepalived/keepalived.cfg", "-l", "-D", "-P", "-n"]
