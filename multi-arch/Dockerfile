# ignore for now: work in progress

FROM --platform=$BUILDPLATFORM golang:1.16.15 as deps

ARG TYK_VERSION=4.3.3

RUN apt update && apt install wget build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl wget libbz2-dev git python3 -y 

FROM deps as build

RUN git clone --depth 1 --branch v${TYK_VERSION} https://github.com/TykTechnologies/tyk.git /opt/tyk-gateway

WORKDIR /opt/tyk-gateway/

RUN go mod download -x && go mod verify

COPY . .

ARG TARGETOS TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH cd /opt/tyk-gateway/ && go build -tags "coprocess grpc goplugin" -o tyk -v . && go clean -modcache

FROM golang:1.16.15
RUN apt update && apt install wget curl wget python3 -y 

COPY --from=build /opt/tyk-gateway/ /opt/tyk-gateway/
COPY --from=build /opt/tyk-gateway/tyk.conf.example /opt/tyk-gateway/tyk.conf

RUN echo "Tyk: $(/opt/tyk-gateway/tyk --version 2>&1)" && \
    echo "Go: $(go version)" && \
    echo "Python: $(python3 --version)"

ENTRYPOINT ["/opt/tyk-gateway/tyk"]
