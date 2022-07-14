#!/bin/bash
docker run -d -p 80:80 --network net --name nginx-proxy -v /var/run/docker.sock:/tmp/docker.sock:ro nginxproxy/nginx-proxy