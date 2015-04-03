#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
#source Environment.sh
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
        STRING=$1
        FUNC_NAME=$2
        STORY=$3  ## STORY_NAME or STORY_URL or comment
        if [ -z "$STRING" ];then
            echo "[INFO] $STORY - Failed on : $FUNC_NAME"
            exit
        fi
}

## Error trapper
file_is_blank(){
        FILE_PATH=$1
        FUNC_NAME=$2
        STORY=$3  ## STORY_NAME or STORY_URL or comment
        if [ ! -s "$FILE_PATH" ];then
            echo "[INFO]  $STORY - Failed on : $FUNC_NAME"
            exit
        fi
}


get_domain_short_name(){
        STORY_URL=$1

        DOMAIN_LONG_NAME=$(echo $STORY_URL | cut -d'/' -f3)
        SiteURL=$(source lib/domain-name.sh "$DOMAIN_LONG_NAME")
        string_is_null "$SiteURL"   "${FUNCNAME[0]}"   "$STORY_URL"
}

get_domain_long_name(){
        STORY_NAME=$1
		SiteURL=$2
		###Ensure that SiteURL is right format

		DOMAIN_LONG_NAME=$(source lib/domain-name.sh "$SiteURL")
		string_is_null "$(cat $UDIR/lib/domain-name.txt | grep "^$SiteURL\s")" "Wrong SiteURL value" "$STORY_NAME"

		STORY_URL=$( cat $ProjectList | grep "^$STORY_NAME\s" | sed 's/\s/\n/g' | grep "$DOMAIN_LONG_NAME" )
        string_is_null "$STORY_URL" "${FUNCNAME[0]}" "$STORY_NAME"
}

get_story_name() {
	STORY_URL=$1

	STORY_NAME=$(cat $ProjectList | grep "$STORY_URL*\b" | awk '{print $1}' )

    string_is_null "$STORY_NAME"   "${FUNCNAME[0]}"  "$STORY_URL"
}

story_var_init(){
    STORY_URL=$1
    get_story_name "$STORY_URL"
    get_domain_short_name "$STORY_URL"
    get_chapter_list "$STORY_URL"
    SAVE_TO="$USTORAGE/$STORY_NAME"
}

chapter_var_init(){
    STORY_URL=$1
    CHAPTER_URL=$2
    get_domain_short_name "$STORY_URL"
    get_page_list "$CHAPTER_URL"  "$SiteURL"
}

############ Verification funtions  ############

#zero_size_files
verify_page_is_null(){
    STORY_NAME=$1
    # Using $2 when you wanna verify a chapter on Storyname (instead of whole story)
    # In case of verifying whole story with specific $USTORAGE, please use  verify_page_is_null "$STORY_NAME" "" "$USTORAGE"
    [ "$2" ] && CHAPTER_NUMBER="chapter-$2"
    USTORAGE=${3:-$USTORAGE}

    PageIsNullList="$TempDir/PageIsNullList-$(openssl rand -hex 10)"
    #Folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME/$CHAPTER_NUMBER" ]; then
        find $USTORAGE/$STORY_NAME/$CHAPTER_NUMBER -type f -size 0 | grep -Po "_\w*_\w*\." | sed -e 's/_/       /g' -e 's/\.//g' > $PageIsNullList
    else
        echo "[INFO] "${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME/$CHAPTER_NUMBER "
        # exit
    fi
    echo "$PageIsNullList"
}

#New feature
verify_page_is_low_quality(){
    STORY_NAME=$1
    # Using $2 when you wanna verify a chapter on Storyname (instead of whole story)
    # In case of verifying whole story with specific $USTORAGE, please use  verify_page_is_null "$STORY_NAME" "" "$USTORAGE"
    [ "$2" ] && CHAPTER_NUMBER="chapter-$2"
    USTORAGE=${3:-$USTORAGE}

    TempFile="$TempDir/TempFile-$(openssl rand -hex 10)"
    PageLowQualityList="$TempDir/PageLowQualityList-$(openssl rand -hex 10)"
    #Folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME/$CHAPTER_NUMBER" ]; then
        find $USTORAGE/$STORY_NAME/$CHAPTER_NUMBER -type f -size -60k -size +0 | grep -v "ctoken" > $TempFile
        while read PAGE
        do
            WIDTH=$(identify $PAGE | grep -Po "\s\w*x\w*\s" | sed -re 's/ ([0-9]*)x[0-9]* /\1/'g)
            if [ "$WIDTH" -lt "250" ];then
                PAGE=$(echo $PAGE | grep -Po "_\w*_\w*\." | sed -e 's/_/       /g' -e 's/\.//g')
                echo "$PAGE       $WIDTH" >> $PageLowQualityList
            fi
        done < $TempFile
        echo "$PageLowQualityList"
    else
        echo "[INFO] "${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME/$CHAPTER_NUMBER "
        # exit
    fi
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $TempFile
}

#number_of_files
verify_page_per_chapter(){
    STORY_NAME=$1
    # Using $2 when you wanna verify a chapter on Storyname (instead of whole story)
    # In case of verifying whole story with specific $USTORAGE, please use  verify_page_is_null "$STORY_NAME" "" "$USTORAGE"
    [ "$2" ] && CHAPTER_NUMBER="chapter-$2"
    USTORAGE=${3:-$USTORAGE}

    TempFile="$TempDir/TempFile-$(openssl rand -hex 10)"
    PagePerChapterList="$TempDir/PagePerChapterList-$(openssl rand -hex 10)"
    #Folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME" ]; then
        # List all chapter on story
        ls $USTORAGE/$STORY_NAME | grep -v "ctoken" | sort -V > $TempFile  #List all dir on story_dir (exclude ctoken.end)
        # In case of verify a chapter only : Echo CHAPTER_NUMBER to $TempFile
        [ "$CHAPTER_NUMBER" ] && echo $CHAPTER_NUMBER > $TempFile

        while read CHAPTER_NUMBER
        do
            if [ -d "$USTORAGE/$STORY_NAME/$CHAPTER_NUMBER" ]; then
                QUANTITY=$(find $USTORAGE/$STORY_NAME/$CHAPTER_NUMBER  -type f | grep -v "ctoken" | wc -l)
                if [ "$QUANTITY" -lt "12" ]; then
                    echo "$CHAPTER_NUMBER      $QUANTITY   #" >> $PagePerChapterList
                else
                    echo "$CHAPTER_NUMBER      $QUANTITY" >> $PagePerChapterList
                fi
            else
                echo "[INFO] "${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME/$CHAPTER_NUMBER "
            fi

        done < $TempFile

    else
        echo "[INFO] "${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME "
        # exit
    fi
    echo "$PagePerChapterList"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $TempFile
}

#missing_chapter - Under contruction
verify_missing_chapter_storyurl(){
    STORY_URL=$1
    USTORAGE=${2:-$USTORAGE}
    story_var_init $STORY_URL
    sed -ri 's/#(.*)#.*/\1/g' $ChapterList

    TempFile="$TempDir/TempFile-$(openssl rand -hex 10)"
    MissingChapterList="$TempDir/MissingChapterList-$(openssl rand -hex 10)"

    #Folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME" ]; then
        ls $USTORAGE/$STORY_NAME | grep -v "ctoken" | sort -V > $TempFile  #List all dir on story_dir (exclude ctoken.end)
        while read CHAPTER_NUMBER
        do
            FLAG=$(cat $TempFile | grep "^chapter-$CHAPTER_NUMBER$")
            [  "$FLAG" ] || echo $CHAPTER_NUMBER >> $MissingChapterList
        done < $ChapterList
    else
        echo "[INFO] "${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME "
        # exit
    fi
    echo "$MissingChapterList"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $TempFile $ChapterList
}


############ Complex funtions  ############

get_chapter_list(){
    STORY_URL=$1
    CurlResult="$TempDir/CurlResult-$(openssl rand -hex 10)"
    ChapterList="$TempDir/ChapterList-$(openssl rand -hex 10)"

    curl --silent $STORY_URL > $CurlResult
    source lib/script.$SiteURL-chapter.sh $CurlResult $ChapterList

    file_is_blank "$ChapterList"   "${FUNCNAME[0]} - Result ChapterList is null or wrong input "  "$STORY_URL"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $CurlResult
}

get_page_list(){
    CHAPTER_URL=$1
    SiteURL=$2
    CurlResult="$TempDir/CurlResult-$(openssl rand -hex 10)"
    PageList="$TempDir/PageList-$(openssl rand -hex 10)"

    curl --silent $CHAPTER_URL > $CurlResult
    source lib/script.$SiteURL-img.sh $CurlResult $PageList

    file_is_blank $PageList   "${FUNCNAME[0]} - Result PageList is null or wrong input "  "$CHAPTER_URL"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $CurlResult
}

######### Funtions for DOWNLOAD  #########

chapter_download_overwrite(){
    while read PAGE
    do
        if [ "$(echo $PAGE | grep ".png")" ]; then
            wget -t 3 -T 5  -O  $SAVE_TO/chapter-$CHAPTER_NUMBER/$STORY_NAME\_$CHAPTER_NUMBER\_$START_PAGE.png $PAGE
            echo "xkdchap="$CHAPTER_NUMBER"=knspos="$START_PAGE"=@   wget -t 3 -T 5  -O  "$SAVE_TO/"chapter-"$CHAPTER_NUMBER/$STORY_NAME\_$CHAPTER_NUMBER\_$START_PAGE.png $PAGE >> $WgetLog/$SiteURL-$STORY_NAME
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
    PageList=$1
    CHAPTER_NUMBER=$2
    START_PAGE=${3:-1}

    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "[INFO] You are missing one of parameters " && exit
    fi

    mkdir -p $SAVE_TO/chapter-$CHAPTER_NUMBER
    rm -vf $SAVE_TO/chapter-$CHAPTER_NUMBER/*
    chapter_download_overwrite
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $PageList
}

## Please marked as commend :
# PageIsNullList
# PageLowQualityList
# PagePerChapterList
# MissingChapterList
