#!/bin/sh

COMPOSE_PROJECT_NAME=`whoami` DOCKER_UID=$(id -u) DOCKER_GID=$(id -g) docker-compose build
