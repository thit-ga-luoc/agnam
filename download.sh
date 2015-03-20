#!/bin/bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source environment.sh
source common.sh

### Always use $1 as OPTS
### Function arguments is started from $2

#OPTS=$1

download_full_story(){
    STORY_URL=$1
    story_var_init "$STORY_URL"

    while read CHAPTER
    do
        CHAPTER_NUMBER=$( echo $CHAPTER | awk '{print $1}' | sed 's/#//g' )
        CHAPTER_URL=$( echo $CHAPTER | awk '{print $2}' )
        get_page_list  "$CHAPTER_URL"  "$SiteURL"
        chapter_download_using_page_list "$PageList" "$CHAPTER_NUMBER"
        rm -f $PageList
    done < $ChapterList
    rm -f $ChapterList
}

download_single_chapter(){
    STORY_URL=$1
    CHAPTER_NUMBER=$2
    story_var_init "$STORY_URL"

    CHAPTER_URL="$(cat $ChapterList | grep "^#$CHAPTER_NUMBER#" | awk '{print $2}' )"
    if [ -z "$CHAPTER_URL" ]; then
        echo "[INFO] $STORY_URL : Chapter number ($CHAPTER_NUMBER) is invalid"
        rm -f $ChapterList && exit
    fi

    get_page_list  "$CHAPTER_URL"  "$SiteURL"
    chapter_download_using_page_list "$PageList" "$CHAPTER_NUMBER"
    rm -f $ChapterList $PageList
}

#download_single_chapter_external_file()

download_single_page(){
    STORY_URL=$1
    CHAPTER_NUMBER=$2
    PAGE_NUMBER=$3
    story_var_init "$STORY_URL"
    PAGE_URL="$TempDir/$(openssl rand -hex 10)"
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
        rm -f $ChapterList && exit
    fi

    get_page_list  "$CHAPTER_URL"  "$SiteURL"
    ### check ctoken.$SiteURL

    cat $PageList | sed -n "$PAGE_NUMBER p" > "$PAGE_URL"

    if [ ! -s "$PAGE_URL" ]; then
        echo "[INFO] $STORY_URL - Chapter ($CHAPTER_NUMBER) : Page number ($PAGE_NUMBER) is invalid"
        rm -f $ChapterList  $PAGE_URL && exit
    fi

    chapter_download_using_page_list "$PAGE_URL" "$CHAPTER_NUMBER"  "$PAGE_NUMBER"
}


#### TESTING area
verify_page_per_chapter  "world-of-super-sand-box" "/Data/www/images/"

#download_single_page $1 $2 $3
#http://blogtruyen.com/truyen/world-of-super-sand-box
