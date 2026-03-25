#!/bin/bash

printf -- '----> Running containers and their images\n'; printf -- "Total number： $(docker ps --format '{{.ID}}' | wc -l)\n"
docker ps --format "table {{.ID}}\t{{.Image}}"

printf -- '----> Non-running containers and their images\n'
printf -- "Total number： $(docker ps -a -f "status=exited" -f "status=created" -f"status=paused" --filter "status=dead" --format '{{.ID}}' | wc -l)\n"
docker ps -a -f "status=exited" -f "status=created" -f "status=paused" -f "status=dead" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"

printf -- '----> Dangling images (not tagged)\n'
printf -- "Total number： $(docker images -f "dangling=true" --format '{{.ID}}' | wc -l)\n"
docker images -f "dangling=true" --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"

printf -- '----> System information\n'
docker system df

printf -- '----> Available actions:\n1) Remove dangling images：docker image prune\n2? Remove dangling and unused images：docker image prune -a\n3) Remove all stopped containers：docker container prune\n'