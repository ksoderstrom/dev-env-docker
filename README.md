# dev-env-docker

This is my personal dev environment. Heavily based on [dpeterson/dev-container-*](https://github.com/dpetersen/dev-container-base).

## Building

Build the docker-compose project with:

```
COMPOSE_PROJECT_NAME=`whoami` DOCKER_UID=$(id -u) DOCKER_GID=$(id -g) docker-compose build
```

## Starting

Run the containers with:

```
COMPOSE_PROJECT_NAME=`whoami` docker-compose up -d
```

This will launch the devbox and a postgres container.

## Connecting

Add the following to the `~/.ssh/config`:

```
Host devbox
  HostName <YOUR IP OR HOSTNAME>
  Port 31122
  User dev
  ForwardAgent true
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

and then connect using `ssh devbox`.

It's possible to connect to the postgres container using the hostname `postgres`.

## TODO

* make mosh work
