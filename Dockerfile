FROM s390x/debian:bullseye as assets

# This Dockerfile facilitates bleeding edge development docker image builds
# directly from source. To build a development image, run `make docker`.
# If you need to tweak the environment for testing, you can override the
# `GO_VERSION` as docker build arguments.

ARG GO_VERSION=1.16

WORKDIR /assets

RUN	apt update && apt install wget -y && \
 	wget -q https://dl.google.com/go/go${GO_VERSION}.linux-s390x.tar.gz

FROM s390x/debian:bullseye as buildenv

ARG GO_VERSION=1.16

COPY --from=assets /assets/ /tmp/
WORKDIR /tmp

# Install Go

ENV PATH=$PATH:/usr/local/go/bin

RUN	tar -C /usr/local -xzf go${GO_VERSION}.linux-s390x.tar.gz && \
	go version

RUN apt update && apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl wget libbz2-dev git -y
RUN	apt install python3 -y

# Clean up build assets
RUN find /tmp -type f -delete

# Build gateway
FROM buildenv

RUN git clone --depth 1 https://github.com/TykTechnologies/tyk.git /opt/tyk-gateway

RUN cd /opt/tyk-gateway && make build && go clean -modcache

RUN cd /opt/tyk-gateway && cp tyk.conf.example tyk.conf

RUN 	echo "Tyk: $(/opt/tyk-gateway/tyk --version 2>&1)" && \
	echo "Go: $(go version)" && \
	echo "Python: $(python3 --version)"

ENTRYPOINT ["/opt/tyk-gateway/tyk"]
