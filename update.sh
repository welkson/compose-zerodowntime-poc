#!/bin/bash

reload_nginx() {  
  docker exec nginx-proxy /usr/sbin/nginx -s reload  
}

zero_downtime_deploy() {  
  service_name=echo
  old_container_id=$(docker ps -f name=$service_name -q | tail -n1)

  # bring a new container online, running new code  
  # (nginx continues routing to the old container only)  
  echo "Scalling $service_name to 2 instances..."
  docker-compose up -d --no-deps --scale $service_name=2 --no-recreate $service_name

  # wait for new container to be available  
  echo "Wait for new container to be available..."
  new_container_id=$(docker ps -f name=$service_name -q | head -n1)
  new_container_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $new_container_id)
  echo "<<< Debug -> new_container_id=$new_container_id / new_container_ip=$new_container_ip"
  docker exec -it nginx-proxy bash -c "/usr/bin/curl --silent --include --retry-connrefused --retry 30 --retry-delay 1 --fail http://$new_container_ip:5678" || exit 1
  echo "Result: $?"

  # start routing requests to the new container (as well as the old)  
  echo "Reloading nginx..."
  reload_nginx

  # take the old container offline  
  echo "Stop and removing old container $old_container_id..."
  docker stop $old_container_id
  docker rm $old_container_id

  echo "Scale $service_name to 1..."
  docker-compose up -d --no-deps --scale $service_name=1 --no-recreate $service_name

  # stop routing requests to the old container  
  echo "Reload nginx..."
  reload_nginx  

  echo "Update finished!"
}

zero_downtime_deploy
