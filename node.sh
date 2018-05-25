#!/bin/bash

source config

function NetAppRpc {
    curl -k "https://$USER:$PASS@$MVIP/json-rpc/10.1"  --data "{\"id\":1499,\"method\":\"$1\",\"params\":$2}"
}

yum install -y iscsi-initiator-utils
systemctl enable iscsi
systemctl start iscsi

# # cat /etc/iscsi/initiatorname.iscsi 
# InitiatorName=iqn.1994-05.com.redhat:f3b7beaf25f9
source /etc/iscsi/initiatorname.iscsi 

# get ip of this host
IP=`hostname -i | tr ' ' '\n' | tail -n 1`

# create initiator, use ip as alias
NetAppRpc CreateInitiators "{\"initiators\":[{\"alias\":\"$IP\", \"name\":\"$InitiatorName\"}]}"
