#!/bin/bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
#source environment.sh
# NOTE : This is basic library file. DO NOT directly call this file
## How to use :
###  source common.sh
###  function_to_call $arg1 $arg2 ... $argN
###  function_to_call  $*

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
            echo "[INFO] $STORY - Failed on : $FUNC_NAME"
            exit
        fi
}

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

############ Verification ############

#zero_size_files
verify_page_is_null(){
    STORY_NAME=$1
    USTORAGE=${2:-$USTORAGE}
    PageIsNullList="$TempDir/$(openssl rand -hex 10)"
    #folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME" ]; then
        find $USTORAGE/$STORY_NAME -type f -size 0 | grep -Po "_\w*_\w*\." | sed -e 's/_/       /g' -e 's/\.//g' > $PageIsNullList
    else
        echo "[INFO] "${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME "
        exit
    fi
    echo $PageIsNullList
}

#New feature
verify_page_is_low_quality(){
    STORY_NAME=$1
    USTORAGE=${2:-$USTORAGE}
    TempFile="$TempDir/$(openssl rand -hex 10)"
    PageLowQualityList="$TempDir/$(openssl rand -hex 10)"
    #folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME" ]; then
        find $USTORAGE/$STORY_NAME -type f -size -60k -size +0 | grep -v "ctoken" > $TempFile
        while read PAGE
        do
            WIDTH=$(identify $PAGE | grep -Po "\s\w*x\w*\s" | sed -re 's/ ([0-9]*)x[0-9]* /\1/'g)
            if [ "$WIDTH" -lt "250" ];then
                PAGE=$(echo $PAGE | grep -Po "_\w*_\w*\." | sed -e 's/_/       /g' -e 's/\.//g')
                echo "$PAGE       $WIDTH" >> $PageLowQualityList
            fi
        done < $TempFile
        echo $PageLowQualityList
    else
        echo "[INFO] "${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME "
        exit
    fi
    rm -f $TempFile
}

#number_of_files
verify_page_per_chapter(){
    STORY_NAME=$1
    USTORAGE=${2:-$USTORAGE}
    TempFile="$TempDir/$(openssl rand -hex 10)"
    PagePerChapterList="$TempDir/$(openssl rand -hex 10)"
    #folder exist or not?
    if [ -d "$USTORAGE/$STORY_NAME" ]; then
        ls $USTORAGE/$STORY_NAME | grep -v "ctoken" | sort -V > $TempFile  #List all dir on story_dir (exclude ctoken.end)
        while read CHAPTER
        do
            QUANTITY=$(ls $USTORAGE/$STORY_NAME/$CHAPTER | grep -v "ctoken" | wc -l)
            if [ "$QUANTITY" -lt "12" ]; then
                echo "$CHAPTER      $QUANTITY   #" >> $PagePerChapterList
            else
                echo "$CHAPTER      $QUANTITY" >> $PagePerChapterList
            fi
        done < $TempFile
    else
        echo "[INFO] "${FUNCNAME[0]}" - No such directory $USTORAGE/$STORY_NAME "
        exit
    fi
    echo $PagePerChapterList
    rm -f $TempFile
}


#missing_chapter

############ Complex funtions  ############

get_chapter_list(){
    STORY_URL=$1
    CurlResult="$TempDir/$(openssl rand -hex 10)"
    ChapterList="$TempDir/$(openssl rand -hex 10)"

    curl --silent $STORY_URL > $CurlResult
    source lib/script.$SiteURL-chapter.sh $CurlResult $ChapterList

    file_is_blank "$ChapterList"   "${FUNCNAME[0]} - Result ChapterList is null or wrong input "  "$STORY_URL"
    rm -f $CurlResult
}

get_page_list(){
    CHAPTER_URL=$1
    SiteURL=$2
    CurlResult="$TempDir/$(openssl rand -hex 10)"
    PageList="$TempDir/$(openssl rand -hex 10)"

    curl --silent $CHAPTER_URL > $CurlResult
    source lib/script.$SiteURL-img.sh $CurlResult $PageList

    file_is_blank $PageList   "${FUNCNAME[0]} - Result PageList is null or wrong input "  "$CHAPTER_URL"
    rm -f $CurlResult
}

######### Funtions for DOWNLOAD  #########

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
    PageList=$1
    CHAPTER_NUMBER=$2
    START_PAGE=${3:-1}

    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "[INFO] You are missing one of parameters " && exit
    fi

    mkdir -p $SAVE_TO/chapter-$CHAPTER_NUMBER
    rm -f $SAVE_TO/chapter-$CHAPTER_NUMBER/*
    chapter_download_overwrite
    rm -f $PageList
}

#### TESTING area