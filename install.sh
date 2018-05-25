#!/bin/bash

source config
NAMESPACE=$1
NAMESPACE=${NAMESPACE:=default}
PWD=`dirname $(realpath $0)`
cd $PWD/trident-installer
cp -a ../setup ./
cp ./tridentctl /usr/bin/

# render file baseon $1.tmpl and bash variables from config
function render {
  eval "cat <<EOF
$(<$1.tmpl)
EOF
" > $1 2> /dev/null
}

render setup/backend.json

# update namespace value in yaml
sed -i -r "s/namespace: [a-z0-9]([-a-z0-9]*[a-z0-9])?/namespace: $NAMESPACE/g" setup/*

# install trident plugin
tridentctl install -n $NAMESPACE --use-custom-yaml

# create storage backend
tridentctl create backend -f setup/backend.json -n $NAMESPACE

# create storage class
render setup/sf-sc.yaml
for i in `seq 0 9`; do 
  cat setup/sf-sc.yaml | sed  "s/NAME/l$i/g" | kubectl create -f -
done

