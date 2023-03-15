# Tyk API Gateway on IBM s390x

**Experimental:** building s390x Docker image for the Tyk API Gateway. Supports Open Source and Licensed usage.

## Why?

Somebody recently asked if they could run the Tyk API Gateway runs s390x. While not currently an officially supported platform for Tyk, I still have a functioning IBM chip implant from my formative years at Big Blue... I couldn't help but give it a try.

Nowadays s390x can run various flavours of Linux such as [Ubuntu](https://wiki.ubuntu.com/S390X). Docker buildx and [QEMU](https://wiki.qemu.org/Documentation/Platforms/S390X) allow you to build binaries for s390x.

## What does this repo do?

The main [Tyk repo](https://github.com/TykTechnologies/tyk) includes a Dockerfile for building the image. It also has a bunch of Github Actions for building releases.. and they're too much for me to get my head around.

This repo serves as a simple testbed for me to build the s390x binaries without cloning the whole Tyk repo. The Dockerfile runs git directly to clone the code (not always recommended) at the specified tag and builds the binary.

## Can I build locally?

Yep. I'm on an M1 Mac and use [Colima](https://github.com/abiosoft/colima) and the [buildx plugin](https://docs.docker.com/build/install-buildx/) so specifics may vary, but here's how I did it..

```
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx build --platform linux/s390x .
```

Once complete you can run the image locally by specifying `--platform linux/s390x` as part of your Docker `run` command.

```
docker run --platform linux/s390x <image id>
```

## Can I run it locally, without the build, like?

```
docker run --platform linux/s390x -it ghcr.io/chrisanderton/tyk-s390x:v4.3.3
```

## Configuration

Check out the [documentation](https://tyk.io/docs/tyk-oss-gateway/configuration/) and [tyk-demo](https://github.com/TykTechnologies/tyk-demo) for examples.

Mount your `tyk.conf` into the container over the default in `/opt/tyk-gateway/tyk`.

You'll need to run a [Redis](https://github.com/redis/redis) instance and configure access to it in `tyk.conf`; the default looks for a hostname of `tyk-redis` without any access control (which doesn't seem smart for any production use.. change it!).

## Where can I test in a real s390x environment?

You can get a free [120 day trial](https://developer.ibm.com/articles/get-started-with-ibm-linuxone/) of OpenShift and/or a VM.

## Docker Compose

Simple example:

```docker-compose.yml
version: "3.8"

services:
  tyk:
    hostname: "tyk"
    image: ghcr.io/chrisanderton/tyk-s390x:v4.3.2
    volumes: 
      - ./tyk.conf:/opt/tyk-gateway/tyk.conf
    ports:
      - 8080:8080
    networks:
      - gateway
  
  tyk-redis:
    hostname: "tyk-redis"
    image: redis:6.0.4
    expose:
      - "6379"
    volumes:
      - tyk-redis-data:/data
    networks:
      - gateway

volumes:
  tyk-redis-data:

networks:
  gateway:
```

Or [check the tyk-demo for other examples](https://github.com/TykTechnologies/tyk-demo).

## Tyk configuration

[Check the tyk-demo for examples](https://github.com/TykTechnologies/tyk-demo).

Sign-up for a [Tyk Cloud Demo](https://tyk.io/sign-up/) and get a [hybrid gateway setup](https://raw.githubusercontent.com/TykTechnologies/tyk-gateway-docker/master/tyk.hybrid.conf) in minutes.

## What's this multi-arch folder?

Ignore it for now.. trying cross-compilation and while it built without errors it looks like I have work to do on linking.

## And one more thing.. IBM Power Servers

Out of my depth... but I noticed ppc64le as a supported build target.  In theory, this might allow Tyk API Gateway to run on IBM Power 7, Power 8 and Power 9 servers.. I don't have one to test so DYOR.
