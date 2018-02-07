#!/usr/bin/env bash

# docker rm -f haproxy

mkdir -p /etc/haproxy
cat << EOF > /etc/haproxy/haproxy.cfg
global
        quiet
        maxconn 2048
        ca-base /etc/ssl/cert
        log /dev/log local2 debug
defaults
        mode    tcp
        log     global
        balance leastconn
        timeout client     120000ms
        timeout server     120000ms
        timeout connect      6000ms
        retries 3

frontend http
        mode http
        bind :::80 v6only
        bind *:80
        option tcplog
        option httplog
        acl lazy_work hdr(host) -m sub lazy.work
        use_backend backend_lazy_work if lazy_work

frontend https
        # bind :::443 v6only
        bind *:443
        option tcplog
        mode tcp
        acl tls req.ssl_hello_type 1
        tcp-request inspect-delay 5s
        tcp-request content accept if tls

        acl lazy_work_tls req.ssl_sni -m end .lazy.work
        use_backend backend_lazy_work_tls if lazy_work_tls

backend backend_lazy_work
        mode http
        option httpclose
        option forwardfor
        cookie JSESSIONID prefix
        server web_lazy_work_http 172.18.201.101:80 cookie A check

backend backend_lazy_work_tls
        mode tcp
        option ssl-hello-chk
        server web_lazy_work_https 172.18.201.101:443 check

EOF

# docker run -d --name haproxy \
#   --restart always \
#   -v /etc/ssl/certs:/etc/ssl/certs \
#   -p 80:80 \
#   -p 443:443 \
#   -v /etc/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
#   haproxy:1.8
systemctl restart haproxy
