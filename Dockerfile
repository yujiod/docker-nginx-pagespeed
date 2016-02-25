FROM ubuntu:trusty

RUN apt update && apt upgrade -y \
    && apt install -y build-essential zlib1g-dev libpcre3 libpcre3-dev openssl libssl-dev libperl-dev wget ca-certificates logrotate git

RUN wget -qO - "$(wget -O - https://api.github.com/repos/cubicdaiya/nginx-build/releases/latest | grep -E browser_download_url.+nginx-build-linux-amd64 | head -n 1 | cut -d \" -f 4)" | tar zxf - -C /usr/local/bin

ADD modules.ini /tmp

RUN nginx-build -d /tmp -m /tmp/modules.ini --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=%{_libdir}/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-threads --with-stream --with-stream_ssl_module --with-http_v2_module --with-ipv6

RUN cd /tmp/nginx/$(ls /tmp/nginx/)/nginx-$(ls /tmp/nginx/) && make install

RUN rm -Rf /tmp/* \
    && apt-get purge -y wget build-essential \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir /var/ngx_pagespeed_cache
RUN chmod 777 /var/ngx_pagespeed_cache

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
