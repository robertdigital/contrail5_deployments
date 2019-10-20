#!/bin/bash

# This script will run as cron job to start control container if it gets exited 
# How to run this script as cron job, every 2 minutes
# */2 * * * * bash <script_location>

#set -o pipefail -e

# Run as root user
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

export LOGFILE=/var/log/contrail/start_container_job.log
exec > >(sudo tee -a $LOGFILE)
exec 2>&1
echo "===========  start ============"

# Names to identify containers
CONTAINER_NAME="control_control_1"

log() {
   echo "$(date)> $1"
}

error() {
   echo ""
   echo "$(date)>>> ERROR - $1"
}

STATUS="true"
check_status() {
   log "Checking the container $CONTAINER_NAME status"
   STATUS=$(docker inspect --format="{{.State.Running}}" $CONTAINER_NAME 2> /dev/null)
}

start_container() {
   log "Starting the container $CONTAINER_NAME"
   docker start $CONTAINER_NAME

   if [ $? -ne 0 ]; then
      error "Failed to start the container $CONTAINER_NAME !!"
      exit 1
   else
      log "Started the container $CONTAINER_NAME successfully"
   fi
}

check_status

if [ "$STATUS" == "true" ]; then
   log "Container $CONTAINER_NAME is running"
elif [ "$STATUS" == "false" ]; then
   error "Container $CONTAINER_NAME is not running"
   start_container
else
   error "Container $CONTAINER_NAME does not exist"
   exit 1
fi

echo "===========  stop ============"
