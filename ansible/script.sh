#!/bin/bash

cd /home/muxun/otus/hw9/muxun_infra/terraform/stage

APPSERVER_NAME=$( terraform output | cut -d"_" -f1)
APPSERVER_IP=$( terraform output | cut -d"=" -f2 | cut -d" " -f2)

echo "
{
"\"$APPSERVER_NAME\"": {
			"\"hosts\"": ["\"$APPSERVER_IP\""]
			       }
}" > ../../ansible/inventory.json 
