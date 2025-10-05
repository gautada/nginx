ARG ALPINE_VERSION=3.22

FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ VARIABLES          │
# ╰――――――――――――――――――――╯
ARG IMAGE_NAME="nginx"
ARG PACKAGE_VERSION="1.28.0"
ARG PACKAGE_RELEASE="r5"

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A test container for nginx."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.version="${PACKAGE_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=nginx
RUN /usr/sbin/usermod -l $USER alpine \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER alpine \
 && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ BACKUP             │
# ╰――――――――――――――――――――╯
# COPY backup.sh /etc/container/backup

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY entrypoint.sh /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ PRIVILEGE          │
# ╰――――――――――――――――――――╯
COPY privileges /etc/sudoers.d/nginx

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache \
    "${IMAGE_NAME}=${PACKAGE_VERSION}-${PACKAGE_RELEASE}" bind-tools openssl \
    nginx-mod-http-dav-ext grep libxml2-utils \
 && openssl req -x509 -nodes -days 365 \
    -subj "/C=US/ST=North Carolina/L=Charlotte/O=Self-Signed Auto-Generated Certificate/OU=nginx/CN=localhost/emailAddress=nginx@fqdn.domain.tld" \
    -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt
# RUN mv /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf~
COPY nginx.conf /etc/nginx/nginx.conf
# COPY inline.conf /etc/nginx/http.d/inline.conf
# COPY files.conf /etc/nginx/locations/static.conf
# COPY index.html /var/lib/nginx/html/static/index.html
# COPY proxy.conf /etc/nginx/locations/proxy.conf
# COPY webdav.conf /etc/nginx/locations/webdav.conf
# RUN ln -fsv /etc/nginx/locations/static.conf /etc/nginx/location.conf
COPY location.conf /etc/nginx/location.conf

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
RUN chown -R $USER:$USER /usr/share/nginx
USER $USER
COPY htpasswd /etc/nginx/htpasswd
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080
EXPOSE 8443
WORKDIR /home/$USER
