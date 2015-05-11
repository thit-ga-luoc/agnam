#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source Download.sh
source Import_db.sh

Main(){
    local   FUNCTION=$1
    $FUNCTION ${*:2}
}
[ "$1" ] && Main $*

