#!/bin/bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source environment.sh
source common.sh

## Trick
# a_command || b_command : b_command will be executed when a_command FAILED
# a_command && b_command : b_command will be executed when a_command SUCCEEDED
# ${STORY_NAME,,}  : Lower case $STORY_NAME (case insensitive)

## Not use now
#get_status_from_status_code(){
#    STATUS_CODE=$1
#    echo $(cat lib/status-codes.txt | grep "^$STATUS_CODE\s" | sed "s/^$STATUS_CODE//g")
#}

mark_as_finished(){
VAR="$#"  ## Number of parameter
    for (( i=1 ; i<=$VAR ; i++  ))
    do
        STORY_NAME="$1"
        [ "$(echo "$1" | grep "^http" )" ] && get_story_name "$1"
        #if ctoken.end exist
        if [ -f "$STORAGE/${STORY_NAME,,}/ctoken.end"  ];then
            echo "[INFO] Story ALREADY marked as \"Finished Story\" : $STORY_NAME "
        elif [ -d "$STORAGE/${STORY_NAME,,}" ]; then
            echo "[INFO] Story will be marked as \"Finished Story\" : $STORY_NAME "
            #echo "ctoken.end" > $STORAGE/$STORY_NAME/ctoken.end
        else
            echo "[INFO] Story  doesn't exist : \"$1\" "
        fi
        shift
    done
}

#mark_as_finished $*
###UP