ARG GO_BUILD_VERSION=1.16.15
ARG GO_BUILD_OS=bullseye

ARG PYTHON_BUILD_VERSION=3.7.13
ARG PYTHON_BUILD_OS=bullseye

ARG TYK_GW_VERSION=4.3.3

FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx
FROM --platform=$BUILDPLATFORM golang:${GO_BUILD_VERSION}-${GO_BUILD_OS} AS builder

ARG TARGETPLATFORM
ARG TYK_GW_VERSION
ARG CGO_ENABLED=1

COPY --from=xx / /

RUN apt update
RUN xx-apt update \
    && xx-apt install -y gcc zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev

# XX_CC_PREFER_STATIC_LINKER prefers ld to lld in ppc64le and 386.
ENV XX_CC_PREFER_STATIC_LINKER=1

RUN git clone --depth 1 --branch v${TYK_GW_VERSION} https://github.com/TykTechnologies/tyk.git /opt/tyk-gateway
WORKDIR /opt/tyk-gateway/

RUN cd /opt/tyk-gateway/ \
    && xx-go mod download -x \
    && xx-go mod verify \
    && xx-go build -v -tags "coprocess grpc goplugin" -o tyk . \
    && xx-go clean -modcache

#WIP: build wheel for grpcio with openssl (required for s390x as boringssl does not work)
FROM --platform=$TARGETPLATFORM python:${PYTHON_BUILD_VERSION}-${PYTHON_BUILD_OS} AS build_wheel

ARG TARGETPLATFORM
ARG GRPC_VERSION=1.51.3
ARG PROTOBUF_VERSION=3.20.1

RUN apt update \
    && apt-get install -y libssl-dev libz-dev

ENV GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
ENV GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1

WORKDIR /wheel/grpcio

RUN if [ "$TARGETPLATFORM" = "linux/s390x" ] || [ "$TARGETPLATFORM" = "linux/ppc64le" ]; then \
      pip3 install --upgrade pip setuptools wheel \
      && pip3 download -v -d /wheel/grpcio grpcio==${GRPC_VERSION} \
      && tar xzf grpcio-${GRPC_VERSION}.tar.gz \
      && cd /wheel/grpcio/grpcio-${GRPC_VERSION} \
      && python3 setup.py bdist_wheel -d /wheel/dist; \
    else \
      pip download --only-binary=:all: -d /wheel/dist grpcio==${GRPC_VERSION}; \
    fi \
    && pip download --only-binary=:all: -d /wheel/dist protobuf==${PROTOBUF_VERSION};

FROM --platform=$TARGETPLATFORM python:${PYTHON_BUILD_VERSION}-${PYTHON_BUILD_OS}

WORKDIR /opt/tyk-gateway/

COPY --from=builder /opt/tyk-gateway/tyk /opt/tyk-gateway/tyk
COPY --from=builder /opt/tyk-gateway/templates/ /opt/tyk-gateway/templates/
COPY --from=builder /opt/tyk-gateway/policies/ /opt/tyk-gateway/policies/
COPY --from=builder /opt/tyk-gateway/middleware/ /opt/tyk-gateway/middleware/
COPY --from=builder /opt/tyk-gateway/tyk.conf.example /opt/tyk-gateway/tyk.conf
COPY --from=build_wheel /wheel/dist /wheel/dist

RUN pip3 install --upgrade pip \
    && find /wheel/dist -name "*.whl" | xargs pip install

ENTRYPOINT ["/opt/tyk-gateway/tyk", "--conf", "/opt/tyk-gateway/tyk.conf"]
