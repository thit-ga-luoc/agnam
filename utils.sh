#!/bin/bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source environment.sh

##
#get_status_from_status_code(){
#    STATUS_CODE=$1
#    echo $(cat lib/status-codes.txt | grep "^$STATUS_CODE\s" | sed "s/^$STATUS_CODE//g")
#}