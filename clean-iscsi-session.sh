#!/bin/bash

SVIP=192.168.2.13
SERVER=$SVIP:3260
iscsiadm -m discoverydb -t sendtargets -p $SERVER -I default --discover | awk '{print $2}' | sort  > all
iscsiadm -m session | awk '{print $4}' | sort > curr
comm -13 all curr | xargs -n 1 -i iscsiadm -m node -p $SERVER -T {} -I default --logout
comm -13 all curr | xargs -n 1 -i iscsiadm -m node -p $SERVER -T {} -I default -o delete

