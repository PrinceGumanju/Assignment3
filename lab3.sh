#!/bin/bash

verbose=0
if [ "$1" == "-verbose" ]; then
    verbose=1
    shift
fi

options=""
if [ $verbose -eq 1 ]; then
    options="-verbose"
fi

scp configure-host.sh remoteadmin@server1-mgmt:/root
ssh remoteadmin@server1-mgmt -- /root/configure-host.sh $options -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4

scp configure-host.sh remoteadmin@server2-mgmt:/root
ssh remoteadmin@server2-mgmt -- /root/configure-host.sh $options -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3

./configure-host.sh $options -hostentry loghost 192.168.16.3
./configure-host.sh $options -hostentry webhost 192.168.16.4
