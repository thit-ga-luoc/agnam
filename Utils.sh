#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source Common.sh
source Environment.sh
## Trick
# a_command || b_command : b_command will be executed when a_command FAILED
# a_command && b_command : b_command will be executed when a_command SUCCEEDED

# ${STORY_NAME,,}  : Lower case $STORY_NAME (case insensitive)

# ls  chapter-1/ | sort -V | grep  -v ctoken | awk 'NR==1; END{print}'  =>  grep the first and the last result from command

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
## INPUT is ONE line with format "story 1,2,3,4,56,6-5,6-6,11_15,17_21"
number_list_parser(){
    INPUT=$1
    InputFile="$TempDir/InputFile-$(openssl rand -hex 10)"
    ParsedList="$TempDir/ParsedList-$(openssl rand -hex 10)"

    #Remove first column (Usually is STORY_NAME,STORY_URL...)
    echo $INPUT | sed -re 's/^.* (.*$)/\1/g' -e 's/,/\n/g' > $InputFile

    while read LINE
    do
        #Search for sequence: 5_10 will become 5,6,7,8,9,10
        if [ "$(echo $LINE | grep "_")" ];then
            START=$(echo $LINE | cut -d"_" -f1)
            END=$(echo $LINE | cut -d"_" -f2)
            for (( i=START ; i<=$END ; i++  ))
            do
                echo $i >> $ParsedList
            done
        else
            echo $LINE >> $ParsedList
        fi
    done < $InputFile
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $InputFile
    echo $ParsedList
}


#number_list_parser "$1"
#mark_as_finished $*
###UP

#get_storyname_or_storyurl(){
#    STORY=$1
#    if [ "$(echo $story | grep "http" )" ]; then
#        get_story_name "$STORY"
#    else
#        get_domain_long_name "$STORY"
#    fi
#}
############ Verification ############