FROM golang:1.20-alpine AS builder

RUN apk update && apk add --no-cache git

WORKDIR /go/src/github.com/andreimarcu/linx-server

RUN set -ex \
        && apk add --no-cache --virtual .build-deps git \
        && git clone https://github.com/andreimarcu/linx-server.git . \
        && go build --ldflags "-s -w -buildid=" -v -o linx-server . \
        && cp linx-server /go/bin/linx-server \
        && apk del .build-deps

FROM alpine:3.17

ENV GOPATH=/go
WORKDIR /go/src/github.com/andreimarcu/linx-server
COPY --from=builder /go/bin/linx-server /usr/local/bin/linx-server
COPY --from=builder /go/src/github.com/andreimarcu/linx-server/static ./static
COPY --from=builder /go/src/github.com/andreimarcu/linx-server/templates ./templates

WORKDIR /data/files
WORKDIR /data/meta
WORKDIR /data
EXPOSE 8080

COPY linx-server.conf /etc/linx-server.conf

CMD ["/usr/local/bin/linx-server", "-config", "/etc/linx-server.conf"]
