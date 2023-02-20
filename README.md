# tyk-s390x

**Experimental:** building s390x Docker image for Tyk Gateway. Supports Open Source and Licensed usage.

## Why?

Somebody recently asked if Tyk runs on s390x. While not currently an officially supported platform for Tyk, I still have a functioning IBM chip implant from my formative years at Big Blue... I couldn't help but give it a try.

## Where can I test s390x?

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

### Tyk configuration

[Check the tyk-demo for examples](https://github.com/TykTechnologies/tyk-demo).

Sign-up for a [Tyk Cloud Demo](https://tyk.io/sign-up/) and get a [hybrid gateway setup](https://raw.githubusercontent.com/TykTechnologies/tyk-gateway-docker/master/tyk.hybrid.conf) in minutes.
