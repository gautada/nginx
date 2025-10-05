#!/bin/bash
#
# entrypoint: Located at `/etc/container/entrypoint` this script is the custom
#             entry for a container as called by `/usr/bin/container-entrypoint` set
#             in the upstream [alpine-container](https://github.com/gautada/alpine-container).
#             The default template is kept in
#             [gist](https://gist.github.com/gautada/f185700af585a50b3884ad10c2b02f98)

container_version() {
  /usr/sbin/nginx -v 2>&1 | cut -d/ -f2 | cut -d' ' -f1
}

container_entrypoint() {
  # set -x
  # ln -fsv "/etc/nginx/locations/${NGINX_LOCATION:-static}.conf" \
  #  /etc/nginx/location.conf
  /usr/sbin/nginx -g "daemon off;"
}
