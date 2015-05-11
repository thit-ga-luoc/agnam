#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source Environment.sh
source Mongo.sh
# NOTE : This is basic library file. DO NOT directly call this file
## How to use :
###  source common.sh
###  function_to_call $arg1 $arg2 ... $argN
###  function_to_call  $*

###TERM
# Variables : THIS_IS_VAR
# Cache files : ThisIsCacheFiles
# Files : this-is-files

# Site order : Blogtruyen > TruyenTranhTuan > vechai > hamtruyen > izmanga

############ Simple funtions  ############

## Error trapper
string_is_null(){
        local STRING=$1
        local FUNC_NAME=$2
        local STORY=$3  ## STORY_NAME or STORY_URL or comment
        if [ -z "$STRING" ];then
            echo "[INFO][$(date +"%y%m%d.%H%M%S")] $STORY - Failed on : $FUNC_NAME" | tee -a $ErrorLog
            [ "$EXIT_ON_ERROR" == "True" ] && exit
        fi
}

## Error trapper
file_is_blank(){
        local FILE_PATH=$1
        local FUNC_NAME=$2
        local STORY=$3  ## STORY_NAME or STORY_URL or comment
        if [ ! -s "$FILE_PATH" ];then
            echo "[INFO][$(date +"%y%m%d.%H%M%S")]  $STORY - Failed on : $FUNC_NAME" | tee -a $ErrorLog
            [ "$EXIT_ON_ERROR" == "True" ] && exit
        fi
}

echo_color(){
    Color=$1
    echo -e "${Color}$2 ${color_NONE}"
}

get_domain_short_name(){
        local STORY_URL=$1

        local DOMAIN_LONG_NAME=$(echo $STORY_URL | cut -d'/' -f3)
        SiteURL=$(source lib/domain-name.sh "$DOMAIN_LONG_NAME")
        string_is_null "$SiteURL"   "${FUNCNAME[0]}"   "$STORY_URL"
}

get_domain_long_name(){
        local STORY_NAME=$1
		local SiteURL=$2
		###Ensure that SiteURL is right format

		DOMAIN_LONG_NAME=$(source lib/domain-name.sh "$SiteURL")
		string_is_null "$SiteURL" "Wrong SiteURL value" "$STORY_NAME"

		STORY_URL=$( cat $ProjectList | grep -P "^$STORY_NAME\s" | sed 's/\s/\n/g' | grep "$DOMAIN_LONG_NAME" )
        string_is_null "$STORY_URL" "${FUNCNAME[0]}" "$STORY_NAME"
}

# (\s|\/|$)

get_story_name() {
	local STORY_URL=$1

	#STORY_NAME=$(cat $ProjectList | grep -P "$STORY_URL/?\s" | awk '{print $1}' )
    STORY_NAME=$(cat $ProjectList | grep -P "$STORY_URL(\s|\/|$)" | awk '{print $1}' )
    string_is_null "$STORY_NAME"   "${FUNCNAME[0]}"  "$STORY_URL"
}

get_chapter_list(){
    local STORY_URL=$1
##    CurlResult="$TempDir/CurlResult-$(openssl rand -hex 10)"
    ChapterList="$TempDir/ChapterList-$STORY_NAME-$(openssl rand -hex 10)"

##    curl --silent $STORY_URL > $CurlResult
##    source lib/script.$SiteURL-chapter.sh $CurlResult $ChapterList
    /usr/bin/python2.7 lib/html-parser-$SiteURL.py "ChapterList" "$STORY_URL" "$ChapterList"
    sed -i '/^$/d' $ChapterList

    [ "$ENABLE_ECHO" == "True" ] && echo_color "$color_LIGHT_PURPLE" "$ChapterList"
    file_is_blank "$ChapterList"   "${FUNCNAME[0]} - Result ChapterList is null or wrong input "  "$STORY_URL"
    #rm -f $CurlResult
}

get_page_list(){
    local CHAPTER_URL=$1
    local SiteURL=$2
##    CurlResult="$TempDir/CurlResult-$(openssl rand -hex 10)"
    PageList="$TempDir/PageList-$STORY_NAME-$CHAPTER_NAME-$(openssl rand -hex 10)"

##    curl --silent $CHAPTER_URL > $CurlResult
##    source lib/script.$SiteURL-img.sh $CurlResult $PageList
    /usr/bin/python2.7 lib/html-parser-$SiteURL.py "PageList" "$CHAPTER_URL" "$PageList"
    sed -i '/^$/d' $PageList

    [ "$ENABLE_ECHO" == "True" ] && echo_color "$color_LIGHT_PURPLE" "$PageList"
    file_is_blank $PageList   "${FUNCNAME[0]} - Result PageList is null or wrong input "  "$CHAPTER_URL"

    rm -f $CurlResult
}

story_var_init(){
    local STORY_URL=$1
    StoryVarInitResult=""
    get_domain_short_name "$STORY_URL"
    if [ "$SiteURL" ]; then
        echo "Site URL : $SiteURL"
        get_story_name "$STORY_URL"
        if [ "$STORY_NAME" ]; then
            echo "Story Name : $STORY_NAME"
            get_chapter_list $STORY_URL
            StoryVarInitResult="Passed"
        fi
    fi
    SAVE_TO="$USTORAGE/$STORY_NAME"
}

chapter_var_init(){
    local STORY_URL=$1
    local CHAPTER_URL=$2
    get_domain_short_name "$STORY_URL"
    get_page_list "$CHAPTER_URL"  "$SiteURL"
}

############ Verification funtions  ############

download_stage_prerun(){
    local STORY_LIST=$1
    VerifiedStoryList="$TempDir/VerifiedStoryList-$(openssl rand -hex 10)"
    local STORY_URL
    echo_color "$color_RED" '$$$$$$$$$$$$$$$$ DOWNLOAD PRERUN STAGE  $$$$$$$$$$$$$$$$'
    while read STORY_URL
    do
        [ "$STORY_URL" ] || continue
        echo
        echo "-------$STORY_URL"
        story_var_init "$STORY_URL"
            if [ "$StoryVarInitResult" == "Passed" ];then
                echo "Verified_OK  $STORY_URL" >> $VerifiedStoryList
                echo "$STORY_URL : Story OK "
            else
                echo "Verified_FAILED  $STORY_URL" >> $VerifiedStoryList
            fi
        rm -f $ChapterList
    done < $STORY_LIST

    cat $VerifiedStoryList | grep "Verified_OK" | awk '{print $2}'> $STORY_LIST
    cat $VerifiedStoryList | grep "Verified_FAILED" | awk '{print $2}'
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $VerifiedStoryList
    [ "$ENABLE_ECHO" == "True" ] && echo_color "$color_LIGHT_PURPLE" "$VerifiedStoryList"
}

#zero_size_files
verify_page_is_null(){
    local STORY_NAME=$1
    # Using $2 when you wanna verify a chapter on STORY_NAME (instead of whole story)
    # In case of verifying whole story with particular $USTORAGE, please use  verify_page_is_null "$STORY_NAME" "" "$USTORAGE"
    [ "$2" ] && local CHAPTER_NAME="chapter-$2"
    local USTORAGE=${3:-$USTORAGE}

    PageIsNullList="$TempDir/PageIsNullList-$(openssl rand -hex 10)"
    #Folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME/$CHAPTER_NAME" ]; then
        find $USTORAGE/$STORY_NAME/$CHAPTER_NAME -type f -size 0 | grep -Po "_\w*_\w*\." | sed -e 's/_/       /g' -e 's/\.//g' > $PageIsNullList
    else
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]"${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME/$CHAPTER_NAME " | tee -a $ErrorLog
    fi
    [ "$ENABLE_ECHO" == "True" ] && echo_color "$color_LIGHT_PURPLE" "$PageIsNullList"
}

#New feature
verify_page_is_low_quality(){
    STORY_NAME=$1
    # Using $2 when you wanna verify a chapter on Storyname (instead of whole story)
    # In case of verifying whole story with particular $USTORAGE, please use  verify_page_is_null "$STORY_NAME" "" "$USTORAGE"
    [ "$2" ] && local CHAPTER_NAME="chapter-$2"
    USTORAGE=${3:-$USTORAGE}

    TempFile="$TempDir/TempFile-$(openssl rand -hex 10)"
    PageLowQualityList="$TempDir/PageLowQualityList-$(openssl rand -hex 10)"
    #Folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME/$CHAPTER_NAME" ]; then
        find $USTORAGE/$STORY_NAME/$CHAPTER_NAME -type f -size -60k -size +0 | grep -v "$PAGE_LIST_EXCLUDE_FILE" > $TempFile
        local PAGE_NAME
        while read PAGE_NAME
        do
            WIDTH=$(identify $PAGE_NAME | grep -Po "\s\w*x\w*\s" | sed -re 's/ ([0-9]*)x[0-9]* /\1/'g)
            if [ "$WIDTH" -lt "250" ];then
                PAGE_NAME=$(echo $PAGE_NAME | grep -Po "_\w*_\w*\." | sed -e 's/_/       /g' -e 's/\.//g')
                echo "$PAGE_NAME       $WIDTH" >> $PageLowQualityList
            fi
        done < $TempFile
        [ "$ENABLE_ECHO" == "True" ] && echo_color "$color_LIGHT_PURPLE" "$PageLowQualityList"
    else
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]"${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME/$CHAPTER_NAME " | tee -a $ErrorLog
    fi
    rm -f $TempFile
}

#number_of_files
verify_page_per_chapter(){
    STORY_NAME=$1
    # Using $2 when you wanna verify a chapter on Storyname (instead of whole story)
    # In case of verifying whole story with particular $USTORAGE, please use  verify_page_is_null "$STORY_NAME" "" "$USTORAGE"
    [ "$2" ] && local CHAPTER_NAME="chapter-$2"
    local USTORAGE=${3:-$USTORAGE}

    TempFile="$TempDir/TempFile-$(openssl rand -hex 10)"
    PagePerChapterList="$TempDir/PagePerChapterList-$(openssl rand -hex 10)"
    #Folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME" ]; then
        # List all chapter on story
        ls $USTORAGE/$STORY_NAME | grep -v "$CHAPTER_LIST_EXCLUDE_FILE" | sort -V > $TempFile  #List all dir on story_dir (with exclusive grep)
        # In case of verify a chapter only : Echo CHAPTER_NAME to $TempFile
        [ "$CHAPTER_NAME" ] && echo $CHAPTER_NAME > $TempFile

        while read CHAPTER_NAME
        do
            if [ -d "$USTORAGE/$STORY_NAME/$CHAPTER_NAME" ]; then
                QUANTITY=$(find $USTORAGE/$STORY_NAME/$CHAPTER_NAME  -type f | grep -v "$PAGE_LIST_EXCLUDE_FILE" | wc -l)
                if [ "$QUANTITY" -lt "12" ]; then
                    echo "$CHAPTER_NAME      $QUANTITY   #" >> $PagePerChapterList
                else
                    echo "$CHAPTER_NAME      $QUANTITY" >> $PagePerChapterList
                fi
            else
                echo "[INFO][$(date +"%y%m%d.%H%M%S")]"${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME/$CHAPTER_NAME " | tee -a $ErrorLog
            fi

        done < $TempFile

    else
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]"${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME " | tee -a $ErrorLog
        # exit
    fi
    [ "$ENABLE_ECHO" == "True" ] && echo_color "$color_LIGHT_PURPLE" "$PagePerChapterList"
    rm -f $TempFile
}

#missing_chapter - Under contruction
### Must use condition on story_var_init => passed story
verify_missing_chapter_storyurl(){
    STORY_URL=$1
    USTORAGE=${2:-$USTORAGE}
    story_var_init $STORY_URL
    sed -ri 's/#(.*)#.*/\1/g' $ChapterList

    TempFile="$TempDir/TempFile-$(openssl rand -hex 10)"
    MissingChapterList="$TempDir/MissingChapterList-$(openssl rand -hex 10)"

    #Folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME" ]; then
        ls $USTORAGE/$STORY_NAME | grep -v "$CHAPTER_LIST_EXCLUDE_FILE" | sort -V > $TempFile  #List all dir on story_dir (exclude ctoken.end)
        local CHAPTER_NAME
        while read CHAPTER_NAME
        do
            FLAG=$(cat $TempFile | grep "^chapter-$CHAPTER_NAME$")
            [  "$FLAG" ] || echo $CHAPTER_NAME >> $MissingChapterList
        done < $ChapterList
    else
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]"${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME "  | tee -a $ErrorLog
        # exit
    fi
    [ "$ENABLE_ECHO" == "True" ] && echo_color "$color_LIGHT_PURPLE" "$MissingChapterList"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $TempFile $ChapterList
    CHAPTER_NAME=$2  # Reassign value to $CHAPTER_NAME => Bash script bug
}

# Run verify before run this script
# Require :     $STORY_NAME and  $CHAPTER_NAME
do_move_chapter_to_imgdir_list(){
    local STORY_NAME=$1
    local CHAPTER_NAME=$2
    local CHAPTER_PATH="$USTORAGE/$STORY_NAME/chapter-$CHAPTER_NAME"
    mkdir -p $IMGDIR/$STORY_NAME
    if [ -d "$CHAPTER_PATH" ] && [ "$(ls $CHAPTER_PATH | grep -v "$PAGE_LIST_EXCLUDE_FILE" )" ]; then
        verify_page_is_null  "$STORY_NAME" "$CHAPTER_NAME"
        verify_page_is_low_quality "$STORY_NAME" "$CHAPTER_NAME"
        if [ ! -s "$PageIsNullList" ] && [ ! -s "$PageLowQualityList" ]; then
            #if [ "$MOVE_OPT" == "FORCE" ] || [ -z "$(cat $MoveToImgDirList | grep "$CHAPTER_PATH$")" ] ; then
            if [ "$MOVE_TO_IMG_MODE" == "Force" ] || [ -z "$(cat $MoveToImgDirList | grep "$CHAPTER_PATH$")" ] ; then
                mongo_import_story "$STORY_NAME"
                mongo_import_chapter "$STORY_NAME" "$CHAPTER_NAME"
                mongo_import_chapter_data "$STORY_NAME" "$CHAPTER_NAME" "md5" "$(cat $CHAPTER_PATH/md5sum)"
                mongo_import_chapter_data "$STORY_NAME" "$CHAPTER_NAME" "ctoken" "$(cat $CHAPTER_PATH/ctoken)"
                mongo_import_chapter_data "$STORY_NAME" "$CHAPTER_NAME" "cprofile" "$(cat $CHAPTER_PATH/cprofile)"

                rm -rfv $IMGDIR/$STORY_NAME/chapter-$CHAPTER_NAME
                mv $CHAPTER_PATH      $IMGDIR/$STORY_NAME/
                echo_color "$color_YELLOW" "$CHAPTER_PATH moved"
                #rm -rfv $CHAPTER_PATH
                echo "$CHAPTER_PATH" >> $MoveToImgDirList
                echo "$STORY_NAME  $CHAPTER_NAME" | tee -a $ImportDBList $ImportMongoList $UpdateLog
            else
                echo_color "$color_RED" "[INFO][$(date +"%y%m%d.%H%M%S")]$CHAPTER_PATH is already on \$MoveToImgDirList"  | tee -a $ErrorLog
            fi
        else
            echo "[INFO][$(date +"%y%m%d.%H%M%S")]$CHAPTER_PATH : Containt Null Page or Low Quality File"  | tee -a $ErrorLog
            echo "PageIsNullList" && cat "$PageIsNullList"
            echo "PageLowQualityList" && cat "$PageLowQualityList"
        fi
        #rm -f $PageIsNullList $PageLowQualityList  # Force to remove temporary files
    else
            echo "[INFO][$(date +"%y%m%d.%H%M%S")]$CHAPTER_PATH : no such directory or directory is empty"  | tee -a $ErrorLog
    fi
    # do not add if this exist on $MoveToImgDirList
    # log all chapter moved => import mongo using ...

}

do_move_story_to_imgdir_list(){
    local STORY_NAME=$1
    NewChapters="$TempDir/TempFile-$(openssl rand -hex 10)"
    ls "$USTORAGE/$STORY_NAME" | grep -v "$CHAPTER_LIST_EXCLUDE_FILE" | sort -V | sed 's/chapter-//g'> $NewChapters
    local CHAPTER_NAME
    while read CHAPTER_NAME
    do
        do_move_chapter_to_imgdir_list "$STORY_NAME" "$CHAPTER_NAME"
    done < $NewChapters
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $NewChapters
    FAILED_CHAPTERS=$( [ -d "$USTORAGE/$STORY_NAME" ] && ls "$USTORAGE/$STORY_NAME" | grep -v "$CHAPTER_LIST_EXCLUDE_FILE" | sort -V)
    ##### Verify after moving
    if [ ! "$FAILED_CHAPTERS" ]; then
    #    ### If Story has chapters that didn't move => log to $MoveToImgDirLog
    #    echo "[INFO][$(date +"%y%m%d.%H%M%S")]$STORY_NAME: $FAILED_CHAPTERS" | tee -a $MoveToImgDirLog
    #else  ### Else : Remove story folder on $USTORAGE => log to $MoveToImgDirLog
        echo -e "\n[INFO][$(date +"%y%m%d.%H%M%S")]$STORY_NAME\n $(rm -rfv "$USTORAGE/$STORY_NAME")" | tee -a $MoveToImgDirLog
    fi
}

######### Funtions for DOWNLOAD  #########

chapter_download_overwrite(){

    echo "----- DOWNLOADING : $STORY_NAME - chapter-$CHAPTER_NAME "
    mkdir -p $SAVE_TO/chapter-$CHAPTER_NAME
    rm -vf $SAVE_TO/chapter-$CHAPTER_NAME/*
    local PAGE_NAME
    while read PAGE_NAME
    do
        if [ "$(echo $PAGE_NAME | grep ".png")" ]; then
            wget -t 5 -T 7 -nv -O  $SAVE_TO/chapter-$CHAPTER_NAME/$STORY_NAME\_$CHAPTER_NAME\_$START_PAGE.png $PAGE_NAME
            echo "xkdchap="$CHAPTER_NAME"=knspos="$START_PAGE"=@   wget -t 5 -T 7 -nv -O  "$SAVE_TO/"chapter-"$CHAPTER_NAME/$STORY_NAME\_$CHAPTER_NAME\_$START_PAGE.png $PAGE_NAME >> $WgetLog/$SiteURL-$STORY_NAME
        else
            wget -t 5 -T 7 -nv -O  $SAVE_TO/chapter-$CHAPTER_NAME/$STORY_NAME\_$CHAPTER_NAME\_$START_PAGE.jpg $PAGE_NAME
            echo "xkdchap="$CHAPTER_NAME"=knspos="$START_PAGE"=@   wget -t 5 -T 7 -nv -O  "$SAVE_TO/"chapter-"$CHAPTER_NAME/$STORY_NAME\_$CHAPTER_NAME\_$START_PAGE.jpg $PAGE_NAME >> $WgetLog/$SiteURL-$STORY_NAME
        #IF LINK-ANH-KHONG-HOP-LE => (blogtruyen)
        fi
    let START_PAGE=$START_PAGE+1
    #echo $START_PAGE
    done < $PageList
    echo "$SiteURL" >  $SAVE_TO/chapter-$CHAPTER_NAME/ctoken
    local MD5_SUM=$(md5sum $PageList | cut -d" " -f1)
    echo $MD5_SUM > $SAVE_TO/chapter-$CHAPTER_NAME/md5sum
    echo cprofile > $SAVE_TO/chapter-$CHAPTER_NAME/cprofile
}

chapter_download_using_page_list(){
    local PageList=$1
    local CHAPTER_NAME=$2
    local START_PAGE=${3:-1}

    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]chapter_download_using_page_list You are missing one of parameters " | tee -a $ErrorLog 
        continue  ### change from exit
    fi

    chapter_download_overwrite
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $PageList
}


##### UTILS
mark_as_finished(){
local VAR="$#"  ## Number of parameter
    for (( i=1 ; i<=$VAR ; i++  ))
    do
        local STORY_NAME="$1"
        [ "$(echo "$1" | grep "^http" )" ] && get_story_name "$1"
        mongo_import_story_data "$STORY_NAME" "stoken" "StoryIsEnded"
#        #if ctoken.end exist
#        if [ -f "$STORAGE/${STORY_NAME,,}/ctoken.end"  ];then
#            echo "[INFO][$(date +"%y%m%d.%H%M%S")]Story ALREADY marked as \"Finished Story\" : $STORY_NAME " | tee -a $ErrorLog
#        elif [ -d "$STORAGE/${STORY_NAME,,}" ]; then
#            echo "[INFO][$(date +"%y%m%d.%H%M%S")]Story will be marked as \"Finished Story\" : $STORY_NAME " | tee -a $ErrorLog
#            #echo "ctoken.end" > $STORAGE/$STORY_NAME/ctoken.end
#        else
#            echo "[INFO][$(date +"%y%m%d.%H%M%S")]Story  doesn't exist : \"$1\" "  | tee -a $ErrorLog
#        fi
        shift
    done
}
## INPUT is ONE line with format "story 1,2,3,4,56,6-5,6-6,11_15,17_21"
number_list_parser(){
    local INPUT=$1
    InputFile="$TempDir/InputFile-$(openssl rand -hex 10)"
    ParsedList="$TempDir/ParsedList-$(openssl rand -hex 10)"

    #Remove first column (Usually is STORY_NAME,STORY_URL...)
    echo $INPUT | sed -re 's/^.* (.*$)/\1/g' -e 's/,/\n/g' > $InputFile
    local LINE
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

enable_proxy(){
    echo_color "$color_GREEN" "ENABLE proxy server : $PROXY_SERVER - Move Mode : $MOVE_TO_IMG_MODE"
    for i in {1..3}
    do
        CURL_RESULT="$(curl -s -m 5 $PROXY_SERVER | grep -o "Invalid URL")"
        if [ "$CURL_RESULT" == "Invalid URL" ];then
            echo_color "$color_YELLOW" "Proxy ENABLED"
            export http_proxy=$PROXY_SERVER
            export no_proxy="127.0.0.1,bp.blogspot.com"
            break
        else
            echo "Connection error n=$i"
            sleep 5
        fi
        [ "$i" == "3" ] && echo_color "$color_RED" "Unable to connect to Proxy_Server $PROXY_SERVER, Running without proxy"  | tee -a $ErrorLog
    done
}
