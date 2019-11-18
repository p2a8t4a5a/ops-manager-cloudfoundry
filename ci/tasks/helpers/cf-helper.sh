#!/usr/local/bin/dumb-init /bin/bash

#cf.helper. wait for particular service status 
wait_service_status_change() {
  local instance_name=$1
  local status=$2
  local time=0
  local verify_status=$(cf services | awk  '/'$instance_name'.*'$status'/{print "$status"}')
  until [[ $verify_status == $status ]] || [[ $time -gt $INSTALL_TIMEOUT ]]; do
    echo "...${verify_status}"
    sleep 3m
    let "time=$time+3"
    verify_status=$(cf services | awk  '/test-mongodb-service.*$status/{print "$status"}')
  done
}

delete_service_if_exists() {
  local instance_name=$1
  local service=$(cf services | awk '/'$instance_name'/{print "exist"}')
  if [[ $service == "exist" ]]; then
    cf delete-service test-mongodb-service -f
  fi
  wait_service_status_change("delete in progress")
  service_status=$(cf services | awk  '/'$instance_name'.*failed/{print "failed"}')
  if [[ $service_status == "failed" ]]; then
    cf purge-service-instance test-mongodb-service -f
  fi
}