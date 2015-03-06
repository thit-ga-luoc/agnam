#!/bin/bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source environment.sh
source common.sh

download_full_story(){
    STORY_URL=$1
    get_story_name "$STORY_URL"
    get_chapter_list "$STORY_URL"
    while read CHAPTER
    do
        CHAPTER_NUMBER=$( echo $CHAPTER | awk '{print $1}' | sed 's/#//g' )
        CHAPTER_URL=$( echo $CHAPTER | awk '{print $2}' )
        SAVE_TO="$USTORAGE/$STORY_NAME"
        get_page_list  "$STORY_URL"  "$CHAPTER_URL"
        chapter_download_using_page_list "$STORY_URL" "$PageList" "$CHAPTER_NUMBER" "$SAVE_TO"
        rm -f $PageList
    done < $ChapterList

    rm -f $ChapterList
}

#download_single_chapter(){
#}

download_full_story $1