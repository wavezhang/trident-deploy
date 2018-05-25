#!/bin/bash

source config
NAMESPACE=$1
NAMESPACE=${NAMESPACE:=default}
PWD=`dirname $(realpath $0)`
cd $PWD/trident-installer

# remove storage classes
for i in `seq 0 9`; do 
  cat setup/sf-sc.yaml | sed  "s/NAME/l$i/g" | kubectl delete -f -
done

# remove backend
tridentctl delete backend solidfire_$SVIP -n $NAMESPACE

# uninstall plugin
tridentctl uninstall -n $NAMESPACE

