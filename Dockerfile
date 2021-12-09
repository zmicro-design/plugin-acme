FROM whatwewant/zmicro:v1.6.8

LABEL maintainer="whatwewant<tobewhatwewant@gmail.com>"

RUN apt install -yqq cron

ARG VERSION=v0.0.2

ENV VERSION=${VERSION}

ENV echo "VERSION: $VERSION"

RUN zmicro package install acme

RUN zmicro install acme

COPY docker/entrypoint.sh /

CMD /entrypoint.sh