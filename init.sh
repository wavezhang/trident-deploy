#!/bin/bash

source config
PWD=`dirname $(realpath $0)`
RUN_PATH=/tmp/
pscp -H "$K8S_NODES" $PWD/config $PWD/node.sh $RUN_PATH 
pssh -H "$K8S_NODES" chmod +x $RUN_PATH/node.sh
pssh -H "$K8S_NODES" $RUN_PATH/node.sh

function NetAppRpc {
    curl -k "https://$USER:$PASS@$MVIP/json-rpc/10.1"  --data "{\"id\":1499,\"method\":\"$1\",\"params\":$2}"
}
function join { local IFS="$1"; shift; echo "$*"; }

# Create Volume Access Group
resp=$(NetAppRpc CreateVolumeAccessGroup "{\"name\":\"$VAG_NAME\"}")
#{"id":1499,"result":{"volumeAccessGroup":{"attributes":{},"deletedVolumes":[],"initiatorIDs":[],"initiators":[],"name":"bj-paas","volumeAccessGroupID":3,"volumes":[]},"volumeAccessGroupID":3}}

# obtain Volume Access Group ID
VAG_ID=`echo $resp | python -m json.tool | grep volumeAccessGroupID | tail -n 1 | awk '{print $2}'`
# update Volume Access Group ID
sed -i "s/VAG_ID=.*/VAG_ID=$VAG_ID/g" config

# get initiator names
names=$(pssh -H "$K8S_NODES" -i cat /etc/iscsi/initiatorname.iscsi | grep Name | awk -F= '{print "\""$2"\""}')
INITIATORS=$(join , ${names[@]})

# add initiators to Volume Access Group
NetAppRpc ModifyVolumeAccessGroup "{\"volumeAccessGroupID\":$VAG_ID,\"initiators\":[$INITIATORS],\"deleteOrphanInitiators\":false}"

# download trident plugin
cd $PWD
wget https://github.com/NetApp/trident/releases/download/v$VERSION/trident-installer-$VERSION.tar.gz
tar -xzf trident-installer-$VERSION.tar.gz
