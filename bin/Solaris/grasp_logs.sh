#!/bin/bash

function usage() {
	echo "Usage:      ./grasp_logs.sh <LOGS_LOCAL_PATH> <REMOVE_FROM_CLUSTER>"
	echo "               REMOVE_FROM_CLUSTER: YES/NO (to remove the log files from the cluster after the download)"
	exit
}


# Check correct number of command line arguments
if [ $# -ne 2 ]; then
	echo "Error: Illegal number of command line arguments. Required 2 argument and got $#. Exiting..."
	usage
fi

removeIfEmpty(){
	DIR=$1
	if [ `ls -A $DIR | wc -l` == 0 ]
	then 
		rm -r $DIR
	fi
}

# local path variables
LOGS_LOCAL_PATH=$1/
REMOVE_FROM_CLUSTER=$2
mkdir -p $LOGS_LOCAL_PATH
rm -rf $LOGS_LOCAL_PATH*

# remote variables
MACHINE=squalldata@icdatasrv
MACHINE5=${MACHINE}5
ZOO1=squalldata@icdatasrv9
ZOO2=squalldata@icdatasrv7
LOGS_REMOTE_PATH=/data/squall_zone/logs
STORM_MASTER=$LOGS_LOCAL_PATH/master
STORM_SUPERVISOR=$LOGS_LOCAL_PATH/supervisor
STORM_ZOO1=$LOGS_LOCAL_PATH/zoo1
STORM_ZOO2=$LOGS_LOCAL_PATH/zoo2
ZOO_REMOTE_PATH=/data/squall_zone/zookeeper_data/consoleZoo.txt

# actual processing
. ./storm_version.sh

# Grasping zoo
mkdir -p $STORM_ZOO1
scp -r $ZOO1:$ZOO_REMOTE_PATH $STORM_ZOO1
removeIfEmpty $STORM_ZOO1
# TODO see what to do with $REMOVE_FROM_CLUSTER

mkdir -p $STORM_ZOO2
scp -r $ZOO2:$ZOO_REMOTE_PATH $STORM_ZOO2
removeIfEmpty $STORM_ZOO2
# TODO see what to do with $REMOVE_FROM_CLUSTER


#Grasping output from master node
mkdir -p $STORM_MASTER
scp -r $MACHINE5:$LOGS_REMOTE_PATH/* $STORM_MASTER
removeIfEmpty "$STORM_MASTER"
if [ $REMOVE_FROM_CLUSTER == "YES" ]; then
  # TODO, we don't delete because Storm behaves strangely
  ssh $MACHINE5 'echo "" > ' $LOGS_REMOTE_PATH'/nimbus.log'
fi

#Grasping output from supervisor nodes
for blade in {1..10}
do
  for port in {1001..1022}
  do
	supervisor=${STORM_SUPERVISOR}${blade}-${port}
	mkdir -p $supervisor
	scp -P "$port" -r $MACHINE${blade}:$LOGS_REMOTE_PATH/* $supervisor
	removeIfEmpty "$supervisor"
	if [ $REMOVE_FROM_CLUSTER == "YES" ]; then
	  ssh -p "$port" $MACHINE${blade} 'rm -r ' $LOGS_REMOTE_PATH'/*'
	fi
  done
done
