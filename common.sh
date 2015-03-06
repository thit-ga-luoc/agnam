#!/bin/bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source environment.sh
###TERM
#Variables : THIS_IS_VAR
#Cache files : ThisIsCacheFiles
#Files : this-is-files

############ Simple funtions  ############


string_is_null(){
        STRING=$1
        FUNC_NAME=$2
        STORY=$3  ## STORY_NAME or STORY_URL or comment
        if [ -z "$STRING" ];then
            echo "$STORY - Failed on : $FUNC_NAME"
            exit
        fi
}

file_is_blank(){
        FILE_PATH=$1
        FUNC_NAME=$2
        STORY=$3  ## STORY_NAME or STORY_URL or comment
        if [ ! -s "$FILE_PATH" ];then
            echo "$STORY - Failed on : $FUNC_NAME"
            exit
        fi
}

get_domain_short_name(){
        STORY_URL=$1

        DOMAIN_LONG_NAME=$(echo $STORY_URL | cut -d'/' -f3)
        SiteURL=$(cat $UDIR/lib/domain-name.txt | grep "\s$DOMAIN_LONG_NAME#" | awk {'print $1'})

        string_is_null "$SiteURL"   "${FUNCNAME[0]}"   "$STORY_URL"
}

get_domain_long_name(){
        STORY_NAME=$1
		SiteURL=$2
		###Ensure that SiteURL is right format
		string_is_null "$(cat $UDIR/lib/domain-name.txt | grep "^$SiteURL\s")" "Wrong SiteURL value" "$STORY_NAME"

		DOMAIN_LONG_NAME=$( cat $UDIR/lib/domain-name.txt | grep "^$SiteURL\s" | awk '{print $2}' )
		STORY_URL=$( cat $ProjectList | grep "^$STORY_NAME\s" | sed 's/\s/\n/g' | grep "$DOMAIN_LONG_NAME" )

        string_is_null "$STORY_URL" "${FUNCNAME[0]}" "$STORY_NAME"
}

get_story_name() {
	STORY_URL=$1

	STORY_NAME=$(cat $ProjectList | grep "$STORY_URL*\b" | awk '{print $1}' )

    string_is_null "$STORY_NAME"   "${FUNCNAME[0]}"  "$STORY_URL"
}


############ Complex funtions  ############

get_chapter_list(){
    STORY_URL=$1
    CurlResult="$TempDir/$(openssl rand -hex 10)"
    ChapterList="$TempDir/$(openssl rand -hex 10)"

    get_domain_short_name  "$STORY_URL"   ## Function get_domain_short_name is belong to utils.sh
    curl --silent $STORY_URL > $CurlResult
    source lib/script.$SiteURL-chapter.sh $CurlResult $ChapterList

    file_is_blank "$ChapterList"   "${FUNCNAME[0]} - Result ChapterList is null or wrong input "  "$STORY_URL"
    rm -f $CurlResult
}

get_page_list(){
    STORY_URL=$1
    CHAPTER_URL=$2
    CurlResult="$TempDir/$(openssl rand -hex 10)"
    PageList="$TempDir/$(openssl rand -hex 10)"

    get_domain_short_name  $STORY_URL   ## Function get_domain_short_name is belong to utils.sh
    curl --silent $CHAPTER_URL > $CurlResult
    source lib/script.$SiteURL-img.sh $CurlResult $PageList

    file_is_blank $PageList   "${FUNCNAME[0]} - Result PageList is null or wrong input "  "$STORY_URL"
    rm -f $CurlResult
}


######### Funtions for DOWNLOAD  #########
chapter_download_overwrite(){
    while read PAGE
    do
        if [ "$(echo $PAGE | grep ".png")" ]; then
            wget -t 3 -T 5  -O  $SAVE_TO/chapter-$CHAPTER_NUMBER/$STORY_NAME\_$CHAPTER_NUMBER\_$START_PAGE.png $PAGE
            echo "xkdchap="$CHAPTER_NUMBER"=knspos="$START_PAGE"=@   wget -t 3 -T 5  -O  "$SAVE_TO/"chapter-"$CHAPTER_NUMBER/$STORY_NAME\_$CHAPTER_NUMBER\_$START_PAGE.pgn $PAGE >> $WgetLog/$SiteURL-$STORY_NAME
        else
            wget -t 3 -T 5  -O  $SAVE_TO/chapter-$CHAPTER_NUMBER/$STORY_NAME\_$CHAPTER_NUMBER\_$START_PAGE.jpg $PAGE
            echo "xkdchap="$CHAPTER_NUMBER"=knspos="$START_PAGE"=@   wget -t 3 -T 5  -O  "$SAVE_TO/"chapter-"$CHAPTER_NUMBER/$STORY_NAME\_$CHAPTER_NUMBER\_$START_PAGE.jpg $PAGE >> $WgetLog/$SiteURL-$STORY_NAME
        #IF LINK-ANH-KHONG-HOP-LE => (blogtruyen)
        fi
    echo "ctoken" >  $SAVE_TO/chapter-$CHAPTER_NUMBER/ctoken.$SiteURL
    let START_PAGE=$START_PAGE+1
    done < $PageList
}

chapter_download_using_page_list(){
    STORY_URL=$1
    PageList=$2
    CHAPTER_NUMBER=$3
    SAVE_TO=$4      #/Data/www/image/$STORY_NAME
    START_PAGE=${5:-1}

    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] ; then
        echo "Null INPUT" && exit
    fi

    get_story_name "$STORY_URL"
    get_domain_short_name "$STORY_URL"

    mkdir -p $SAVE_TO/chapter-$CHAPTER_NUMBER
    rm -f $SAVE_TO/chapter-$CHAPTER_NUMBER/*
    chapter_download_overwrite
    rm -f $PageList
}


