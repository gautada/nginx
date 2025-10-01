ARG ALPINE_VERSION=3.22
FROM gautada/alpine:$ALPINE_VERSION

LABEL source="https://github.com/gautada/nginx-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="An nginx container"

USER root
WORKDIR /

EXPOSE 80/tcp
# EXPOSE 443/tcp

ARG NGINX_VERSION=1.20.2
ARG NGINX_PACKAGE="$NGINX_VERSION"-r1
# RUN /sbin/apk add --no-cache nginx=$NGINX_PACKAGE
RUN /sbin/apk add --no-cache nginx openssl curl wget git bash libressl


RUN /bin/echo "%wheel         ALL = (ALL) NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers

RUN rm /etc/container/entrypoint
COPY entrypoint /etc/container/entrypoint
COPY http-default.conf /etc/nginx/http.d/default.conf
# COPY https-default.conf /etc/nginx/http.d/https-default.conf
COPY index.html /home/nginx/www/index.html
# COPY pki/* /etc/nginx/pki/

RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log


ARG USER=nginx
# VOLUME /opt/$USER
# nginix group & user is already created
# && /usr/sbin/addgroup $USER \
# && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
RUN /bin/mkdir -p /opt/$USER
RUN /usr/sbin/usermod -aG wheel $USER
RUN /bin/echo "$USER:$USER" | chpasswd
RUN /bin/chown $USER:$USER -R /opt/$USER
RUN chown nginx:nginx -R /etc/nginx /home/nginx

USER $USER
WORKDIR /home/$USER


RUN echo "sudo /usr/sbin/nginx -g 'daemon off;'" > /home/nginx/go \
 && chmod +x /home/nginx/go

