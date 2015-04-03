#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source Environment.sh
source Common.sh

### Always use $1 as OPTS
### Function arguments is started from $2

#OPTS=$1

download_full_story(){
    STORY_URL=$1
    story_var_init "$STORY_URL"
    echo -n > $WgetLog/$SiteURL-$STORY_NAME  # Purge wget_log everytime down a story

    while read CHAPTER
    do
        CHAPTER_NUMBER=$( echo $CHAPTER | awk '{print $1}' | sed 's/#//g' )
        CHAPTER_URL=$( echo $CHAPTER | awk '{print $2}' )
        get_page_list  "$CHAPTER_URL"  "$SiteURL"
        chapter_download_using_page_list "$PageList" "$CHAPTER_NUMBER"
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $PageList
    done < $ChapterList
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList
}

# story_var_init "$STORY_URL"
download_single_chapter(){
    CHAPTER_NUMBER=$1
    START_PAGE=${2:-1}

#    story_var_init "$STORY_URL"   => REMOVE TO PREVENT REPEAT

    CHAPTER_URL="$(cat $ChapterList | grep "^#$CHAPTER_NUMBER#" | awk '{print $2}' )"
    if [ -z "$CHAPTER_URL" ]; then
        echo "[INFO] $STORY_URL : Chapter number ($CHAPTER_NUMBER) is invalid"
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList
        exit
    fi
    get_page_list  "$CHAPTER_URL"  "$SiteURL"
    chapter_download_using_page_list "$PageList" "$CHAPTER_NUMBER" "$START_PAGE"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList $PageList
}

#download_single_chapter_external_file()

download_single_page(){
    STORY_URL=$1
    CHAPTER_NUMBER=$2
    PAGE_NUMBER=$3
    story_var_init "$STORY_URL"
    PAGE_URL="$TempDir/PAGE_URL-$(openssl rand -hex 10)"
    CHAPTER_URL="$(cat $ChapterList | grep "^#$CHAPTER_NUMBER#" | awk '{print $2}' )"
    string_is_null "$CHAPTER_URL"  "Chapter $CHAPTER_NUMBER is invalid"  "$STORY_URL"

    # [ -d "$SAVE_TO/chapter-$CHAPTER_NUMBER"  ] &&
    OLDSiteURL="$(ls $SAVE_TO/chapter-$CHAPTER_NUMBER | grep "ctoken" | sed 's/ctoken\.//g')"
    if [ "$SiteURL" != "$OLDSiteURL" ];then
        get_domain_long_name "$STORY_NAME" "$OLDSiteURL"
        echo "[INFO] $STORY_NAME : Chapter number ($CHAPTER_NUMBER) was downloaded from $STORY_URL"
        exit
    fi

    if [ -z "$CHAPTER_URL" ]; then
        echo "[INFO] $STORY_URL : Chapter number ($CHAPTER_NUMBER) is invalid"
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList
        exit
    fi

    get_page_list  "$CHAPTER_URL"  "$SiteURL"
    ### check ctoken.$SiteURL

    cat $PageList | sed -n "$PAGE_NUMBER p" > "$PAGE_URL"

    if [ ! -s "$PAGE_URL" ]; then
        echo "[INFO] $STORY_URL - Chapter ($CHAPTER_NUMBER) : Page number ($PAGE_NUMBER) is invalid"
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ChapterList  $PAGE_URL
        exit
    fi

    chapter_download_using_page_list "$PAGE_URL" "$CHAPTER_NUMBER"  "$PAGE_NUMBER"
}



download_stage_verify(){
    STORY_NAME=$1
    CHAPTER_NUMBER=$2
    TRY=3

    while [ "$TRY" -gt 0 ]
    do
        echo "------------------ Try at $TRY  ------------------"
        verify_page_is_null  "$STORY_NAME" "$2"
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
        CHAPTER_ERROR=$(echo $LINE | awk '{print $1}')
        PAGE_ERROR=$(echo $LINE | awk '{print $2}')
        [ "$PAGE_ERROR" ] || PAGE_ERROR=".*"  # In case of PAGE_ERROR is NULL : Select ALL page in CHAPTER_ERROR
        cat $WgetLog/$SiteURL-$STORY_NAME | grep "xkdchap=$CHAPTER_ERROR=knspos=$PAGE_ERROR=@" >> $DownloadFromWgetLogList
    done < $ErrorList
    cat $DownloadFromWgetLogList | sort -V | uniq > $ErrorList
    cat $ErrorList > $DownloadFromWgetLogList
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $ErrorList
    echo "$DownloadFromWgetLogList"
}


# Permanant remove Null page at first page or last page of chapter
# Only use this function on "Download.sh/download_stage_verify"
# Only run ONCE
download_remove_first_last_null_page(){
    RemoveFirstLastNullPageList="$TempDir/RemoveFirstLastNullPageList-$(openssl rand -hex 10)"
    cat $PageIsNullList | grep -v "^$" | awk '{print $1}' | uniq > $RemoveFirstLastNullPageList
    while read CHAPTER
    do

        FIRST=$(find  $SAVE_TO/"chapter-"$CHAPTER/* -type f | grep "_1\." )
        [ "$(cat $SAVE_TO/"chapter-"$CHAPTER/ctoken* | grep "LastPageRemoved" | uniq )" ] || LAST=$( find  $SAVE_TO/"chapter-"$CHAPTER/* -type f | grep -v "ctoken" | sort -V | tail -n1)

        [ ! -s "$FIRST" ] && rm -rfv $FIRST | tee -a
        [ ! -s "$LAST"  ] && rm -rfv $LAST | tee -a && echo "LastPageRemoved" >>  $SAVE_TO/"chapter-"$CHAPTER/ctoken*
    done < $RemoveFirstLastNullPageList
}

