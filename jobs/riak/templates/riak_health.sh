#!/bin/bash

JOB_DIR=/var/vcap/jobs/riak
RUN_DIR=/var/vcap/sys/run/riak
LOG_DIR=/var/vcap/sys/log/riak
PIDFILE=$RUN_DIR/riak_health.pid

source ${JOB_DIR}/bin/functions.sh

# PID/lock - we only want one instance running.
f_lock_test ${PIDFILE}


mkdir -p ${LOG_DIR}
mkdir -p ${RUN_DIR}

while true
  do

  response=`/var/vcap/packages/riak/rel/bin/riak-admin test`
  if [ $? == 0 ]
    then true
    else
      echo ${response}
      exit 1
  fi

  sleep 60

  done
