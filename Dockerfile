FROM ghcr.io/umami-software/umami:postgresql-v2.17.0

USER root

RUN apk add --no-cache nginx

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
