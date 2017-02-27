# make sure to first give this file permissions
# chmod +x __gitUpdate.sh
# run with ./__gitUpdate.sh

#!/bin/sh

PORT=$1 # use the port passed in as a first argument

ember s --port $PORT & # start server on the desired port
PID=$! # capture service PID to be able to stop it later

while(true) # repeat infinitely
  do
    sleep 300 # check every x seconds

    echo $(date +"%r") fetching, service $PID, port $PORT # status update for user

    git fetch # fetch new updates
    HASCHANGES="$( git log HEAD..origin/master --oneline )" # check if changes exist

    if [ "${HASCHANGES}" != "" ]; then
      echo dealing with remote changes
      echo killing service $PID
      kill $PID
      sleep 10 # wait for server to stop
      echo pulling changes
      git pull
      sleep 10 # wait for new changes to settle
      ember s --port $PORT & # restart the server again
      PID=$! # get a new PID to kill later
      echo restarting server $PID, port $PORT
    fi
done
