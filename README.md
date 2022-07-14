## Demo-Zero-Downtime

Docker-Compose zero-downtime PoC.

Based in [1] [2] posts.

### Config test domain

```bash
sudo echo "127.0.0.1	blog.domain.com" >> /etc/hosts
```

### Config Proxy Network

```bash
docker network create net
```

### Run NGInx-Proxy

```
./nginx.sh
```

### Test Docker-Compose 

Run test application:
```
docker-compose up -d
```

In another window test response from echo:
```
./curl-test.sh
```
`Output shows "v1" from -text parameter in docker-compose.yaml`

Change version from `-text` parameter on docker-compose.yaml to `"v2"`.

Execute update script:
```
./update.sh
```

In curl-test shows v1 and v2 for some moments, in the end only v2 with zero downtime.

### Links

[1] https://www.tines.com/blog/simple-zero-downtime-deploys-with-nginx-and-docker-compose

[2] https://linuxhandbook.com/update-docker-container-zero-downtime/

