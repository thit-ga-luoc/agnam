#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
#source Environment.sh
source Common.sh

### Always use $1 as OPTS
### Function arguments is started from $2

#OPTS=$1

download_full_story(){
    local STORY_URL=$1
    story_var_init "$STORY_URL"
    echo -n > $WgetLog/$SiteURL-$STORY_NAME  # Purge wget_log everytime download a story
    local CHAPTER
    while read CHAPTER
    do
        if [ "$MOVE_TO_IMG_MODE" == "Force" ] || [ -z "$(cat $MoveToImgDirList | grep "$USTORAGE/$STORY_NAME/chapter-$CHAPTER_NAME$")" ] ; then
            CHAPTER_NAME=$( echo $CHAPTER | awk '{print $1}' | sed 's/#//g' )
            CHAPTER_URL=$( echo $CHAPTER | awk '{print $2}' )
            get_page_list  "$CHAPTER_URL"  "$SiteURL"
            chapter_download_using_page_list "$PageList" "$CHAPTER_NAME"
            [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $PageList
        else
            echo_color "$color_RED" "[INFO][$(date +"%y%m%d.%H%M%S")]$USTORAGE/$STORY_NAME/chapter-$CHAPTER_NAME is already on \$MoveToImgDirList"  | tee -a $ErrorLog
        fi
    done < $ChapterList
    echo stoken >  $SAVE_TO/stoken
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList
}

# story_var_init "$STORY_URL"
download_single_chapter(){
    local CHAPTER_NAME=$1
    local START_PAGE=${2:-1}

    local CHAPTER_URL="$(cat $ChapterList | grep "^#$CHAPTER_NAME#" | awk '{print $2}' )"
    if [ -z "$CHAPTER_URL" ]; then
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]$STORY_URL : Chapter number ($CHAPTER_NAME) is invalid" | tee -a $ErrorLog
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList
        continue
        #[ "$EXIT_ON_ERROR" == "True" ] && exit
    fi
    get_page_list  "$CHAPTER_URL"  "$SiteURL"
    if [ ! -s "$PageList" ]; then
        echo_color "$color_RED" "[INFO][$(date +"%y%m%d.%H%M%S")] $STORY_NAME chapter-$CHAPTER_NAME PageList is Null"
        continue
    fi
    chapter_download_using_page_list "$PageList" "$CHAPTER_NAME" "$START_PAGE"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList $PageList
}

#download_single_chapter_external_file()

### Must be improved
download_single_page(){
    local STORY_URL=$1
    local CHAPTER_NAME=$2
    local PAGE_NAME=$3
    story_var_init "$STORY_URL"
    PageList="$TempDir/PageList-$(openssl rand -hex 10)"
    local CHAPTER_URL="$(cat $ChapterList | grep "^#$CHAPTER_NAME#" | awk '{print $2}' )"
    string_is_null "$CHAPTER_URL"  "Chapter $CHAPTER_NAME is invalid"  "$STORY_URL"

    # [ -d "$SAVE_TO/chapter-$CHAPTER_NAME"  ] &&
    OLDSiteURL="$( [ -d "$SAVE_TO/chapter-$CHAPTER_NAME" ] && ls $SAVE_TO/chapter-$CHAPTER_NAME | grep "ctoken" | sed 's/ctoken\.//g')"
    if [ "$SiteURL" != "$OLDSiteURL" ];then
        get_domain_long_name "$STORY_NAME" "$OLDSiteURL"
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]$STORY_NAME : Chapter number ($CHAPTER_NAME) was downloaded from $STORY_URL" | tee -a $ErrorLog
        [ "$EXIT_ON_ERROR" == "True" ] && exit
    fi

    if [ -z "$CHAPTER_URL" ]; then
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]$STORY_URL : Chapter number ($CHAPTER_NAME) is invalid" | tee -a $ErrorLog
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList
        [ "$EXIT_ON_ERROR" == "True" ] && exit
    fi

    get_page_list  "$CHAPTER_URL"  "$SiteURL"
    ### check ctoken.$SiteURL

    cat $PageList | sed -n "$PAGE_NAME p" > "$PageList"

    if [ ! -s "$PageList" ]; then
        echo "[INFO][$(date +"%y%m%d.%H%M%S")]$STORY_URL - Chapter ($CHAPTER_NAME) : Page number ($PAGE_NAME) is invalid" | tee -a $ErrorLog
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList  $PageList
        [ "$EXIT_ON_ERROR" == "True" ] && exit
    fi

    chapter_download_using_page_list "$PageList" "$CHAPTER_NAME"  "$PAGE_NAME"
}



download_stage_verify(){
    local STORY_NAME=$1
    local CHAPTER_NAME=$2
    local TRY=5

    while [ "$TRY" -gt 0 ]
    do
        echo "------------------ Try at $TRY  ------------------"
        verify_page_is_null  "$STORY_NAME" "$CHAPTER_NAME"
        if [ -s "$PageIsNullList" ]; then
            download_from_wget_log "$PageIsNullList"
            chmod +x $DownloadFromWgetLogList
            /bin/bash $DownloadFromWgetLogList
             [ "$TRY" == "1" ] && download_remove_first_last_null_page
            [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadFromWgetLogList
            let TRY=$TRY-1
        else
            echo "There is no PageIsNull" 
            TRY=0
        fi
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $PageIsNullList
    done
}

#Errorlist format
# 5 16   => chapter 5 - page 16
# 5 17   => chapter 5 - page 17
# 8      => All chapter 8
download_from_wget_log(){
    ErrorList="$TempDir/ErrorList-$(openssl rand -hex 10)"
    DownloadFromWgetLogList="$TempDir/DownloadFromWgetLogList-$(openssl rand -hex 10)"
    cat $1 > $ErrorList

    while read LINE
    do
        local CHAPTER_ERROR=$(echo $LINE | awk '{print $1}')
        local PAGE_ERROR=$(echo $LINE | awk '{print $2}')
        [ "$PAGE_ERROR" ] || PAGE_ERROR=".*"  # In case of PAGE_ERROR is NULL : Select ALL page in CHAPTER_ERROR
        cat $WgetLog/$SiteURL-$STORY_NAME | grep "xkdchap=$CHAPTER_ERROR=knspos=$PAGE_ERROR=@" >> $DownloadFromWgetLogList
    done < $ErrorList
    cat $DownloadFromWgetLogList | sort -V | uniq > $ErrorList
    cat $ErrorList > $DownloadFromWgetLogList
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ErrorList
    [ "$ENABLE_ECHO" == "True" ] && echo_color "$color_LIGHT_PURPLE" "$DownloadFromWgetLogList"
}


# Permanant remove Null page at first page or last page of chapter
# Only use this function on "Download.sh/download_stage_verify"
# Only run ONCE
download_remove_first_last_null_page(){
    RemoveFirstLastNullPageList="$TempDir/RemoveFirstLastNullPageList-$(openssl rand -hex 10)"
    cat $PageIsNullList | grep -v "^$" | awk '{print $1}' | uniq > $RemoveFirstLastNullPageList
    local CHAPTER_NAME
    while read CHAPTER_NAME
    do

        local FIRST=$(find  $SAVE_TO/"chapter-"$CHAPTER_NAME/* -type f | grep "_1\." )
        [ "$(cat $SAVE_TO/"chapter-"$CHAPTER_NAME/cprofile | grep "LastPageRemoved" | uniq )" ] || local LAST=$( find  $SAVE_TO/"chapter-"$CHAPTER_NAME/* -type f | grep -v "ctoken" | sort -V | tail -n1)

        [ ! -s "$FIRST" ] && rm -rfv $FIRST | tee -a
        [ ! -s "$LAST"  ] && rm -rfv $LAST | tee -a && echo "LastPageRemoved" >>  $SAVE_TO/"chapter-"$CHAPTER_NAME/cprofile
    done < $RemoveFirstLastNullPageList
}

