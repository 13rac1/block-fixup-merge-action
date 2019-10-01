FROM alpine:3.10

RUN apk add --no-cache \
  bash \
  jq
COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
