#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source Download.sh
### If this file is running, do not trigger it again
#[ "$(ps aux | grep -e Update.sh | grep -v "grep")" ] || exit

update_normal_story_to_newest_chapter(){
    source Import_db.sh
    StoryToUpdateList="$TempDir/StoryToUpdateList-$(openssl rand -hex 10)"

    if [ -s "$StoryToUpdate" ];then ### Use $StoryToUpdate as default
        cat $StoryToUpdate | tr '\r' '\n' | sed -re 's/^(.*)/\1\n/g' | grep -v "^$" | grep -v "$STORIES_TO_UPDATE_EXCLUDE" > $StoryToUpdateList
        #echo -n > $StoryToUpdate  ## Hardcore List
    else   ## If $StoryToUpdate doesn't exist or null : Using $NormalStoryList (Optional)
        if [ "$1" == "do-filter" ];then
            rm -f $NormalStoryList $AbnormalStoryList $StoryFilteredList && source Environment.sh
            filter_stories  ## Trigger filter_stories
        fi
        cat $NormalStoryList | awk '{print $1}'> $StoryToUpdateList
    fi

    local STORY_NAME
    while read STORY_NAME
    do
        echo -e "\n\n\n"
        echo_color "$color_GREEN" "############# Running Update - $STORY_NAME  #############"

        ## If story is ended : Story process - go to next story
        if [ "$(mongo_get_story_data "$STORY_NAME" "stoken")" == "StoryIsEnded" ];then
            echo_color "$color_RED" "[INFO][$(date +"%y%m%d.%H%M%S")] $STORY_NAME Story is ENDED" | tee -a $ErrorLog
            continue
        fi

        mongo_get_all_chapter "$STORY_NAME"
        LOCAL_LASTEST=$(cat $MongoChapterList | sort -V | tail -n1 | sed 's/chapter-//g')
        MONGO_MD5_SUM=$(mongo_get_chapter_data  "$STORY_NAME"  "$LOCAL_LASTEST"  "md5")
        MONGO_CTOKEN=$(mongo_get_chapter_data  "$STORY_NAME"  "$LOCAL_LASTEST"  "ctoken")
        get_domain_long_name "$STORY_NAME" "$MONGO_CTOKEN"   #Output : $STORY_URL
        story_var_init "$STORY_URL"

        #local SAVE_TO="$USTORAGE/$STORY_NAME" => deprecated
        ChapterToUpdateList="$TempDir/ChapterToUpdateList-$(openssl rand -hex 10)"
        local UPDATE_FLAG=$(cat $ChapterList | grep -n "#$LOCAL_LASTEST#" | cut -d":" -f1)
        ## If UPDATE_FLAG is Null - go to next story
        if [ ! "$UPDATE_FLAG" ];then
            echo_color "$color_RED" "[INFO][$(date +"%y%m%d.%H%M%S")] $STORY_NAME Can not determinate UPDATE_FLAG" | tee -a $ErrorLog
            continue
        fi

        cat $ChapterList | head -n $UPDATE_FLAG | sort -V > $ChapterToUpdateList ###
        echo "############# Download Stage - $STORY_NAME - Start from chapter-$LOCAL_LASTEST #############"
        local CHAPTER
        while read CHAPTER
        do
            local CHAPTER_NAME=$(echo $CHAPTER | awk '{print $1}' | sed 's/#//g')
            local CHAPTER_URL=$(echo $CHAPTER | awk '{print $2}')
            echo $STORY_NAME $CHAPTER_NAME
            if [ "$CHAPTER_NAME" ==  "$LOCAL_LASTEST" ]; then
                get_page_list  "$CHAPTER_URL"  "$SiteURL"
                local MD5_SUM=$(md5sum $PageList | cut -d" " -f1)
                if [ "$MONGO_MD5_SUM" != "$MD5_SUM" ];then
                    echo "[INFO][$(date +"%y%m%d.%H%M%S")] $STORY_NAME chapter-$CHAPTER_NAME on $IMGDIR will be updated" | tee -a $ErrorLog
#                    download_single_chapter "$CHAPTER_NAME"
                else
                    echo_color "$color_RED" "[INFO][$(date +"%y%m%d.%H%M%S")] $STORY_NAME chapter-$CHAPTER_NAME is lastest Chapter" | tee -a $ErrorLog
                fi
            else
                echo "DOWNLOADING........PASS $CHAPTER_NAME"
#                download_single_chapter "$CHAPTER_NAME"   #Output $MD5_SUM
            fi
        done < $ChapterToUpdateList
        if [ -d "$USTORAGE/$STORY_NAME" ]; then
            echo "###### Verification Stage ###### $STORY_NAME"
#            download_stage_verify "$STORY_NAME"
            echo "###### Move to IMGDIR Stage ###### $STORY_NAME"
#            do_move_story_to_imgdir_list "$STORY_NAME"
        fi

        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $MongoChapterList
    done < $StoryToUpdateList
    echo "############# IMPORT DATABASE #############"
#    import_chapter_to_db  import chapter normal old
#    rm -f $ImportDBList
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $StoryToUpdateList

}

filter_do_add_abnormal(){
    local STORY_NAME=$1
    local CHAPTER_NAME=$2
    if [ -z "$(cat $AbnormalStoryList | grep "^$STORY_NAME*\s")" ];then
        cat $ProjectList | grep "^$STORY_NAME*\s" >> $AbnormalStoryList
        echo "[$(date +"%y%m%d.%H%M%S")] [ABnormal.list]  \"$STORY_NAME\"  is failed at $CHAPTER_NAME" | tee -a $StoryFilteredList
    fi
}

filter_do_add_normal(){
    local STORY_NAME=$1
#    local CHAPTER_NAME=$2
    if [ -z "$(cat $NormalStoryList | grep "^$STORY_NAME*\s")" ];then
        cat $ProjectList | grep "^$STORY_NAME*\s" >> $NormalStoryList
        echo "[$(date +"%y%m%d.%H%M%S")] [NORMAL.list]    \"$STORY_NAME\" " | tee -a $StoryFilteredList
    fi
}


### search story on normal, abnormal before pass through this function
filter_a_story(){
    local STORY_NAME=$1
### Make a MongoChapterList
### If first chapter is chapter-0 => CHAPTER_FLAG=0
### If first chapter is chapter-1 => CHAPTER_FLAG=1
### If first chapter neither chapter-0 nor chapter-1 => CHAPTER_FLAG=2 Failed case
    mongo_get_all_chapter  "$STORY_NAME"  # Output : $MongoChapterList
    local CHAPTER_FLAG="-1"
    if [  "$(cat $MongoChapterList | grep "chapter-0\$" )" ]; then
        CHAPTER_FLAG=0
    elif [ "$(cat $MongoChapterList | grep "chapter-1\$" )" ]; then
        CHAPTER_FLAG=1
    fi
    local STATUS=""
    local CHAPTER_NAME
    while read CHAPTER_NAME
    do
        # If $CHAPTER_NAME not equal $CHAPTER_FLAG => Abnormal
        # if $CHAPTER_FLAG == "-1" => Abnormal
        if [ "$CHAPTER_NAME" != "chapter-$CHAPTER_FLAG" ] || [ "$CHAPTER_FLAG" == "-1" ]; then
            ### Add story to Abormal.list
            # Check "chapter-end" error => Abnormal
            if [ "${CHAPTER_NAME,,}" == "chapter-end" ]; then
                filter_do_add_abnormal "$STORY_NAME" "$CHAPTER_NAME"
                # do_fix_chapter-end
                STATUS="FAILURE"
                break
            else
                filter_do_add_abnormal "$STORY_NAME" "$CHAPTER_NAME"
                STATUS="FAILURE"
                break
            fi
        fi
        #[ "$ENABLE_ECHO" == "True" ] && echo  " i =  $i ---- line =   $line"
        let CHAPTER_FLAG=$CHAPTER_FLAG+1
    STATUS="SUCCESS"
    done < $MongoChapterList

    if [ "$STATUS" == "SUCCESS" ]; then
        ### Add story to Normal.list
        filter_do_add_normal "$STORY_NAME"
fi

}

filter_stories(){
    StoriesToFilterList="$TempDir/StoriesToFilterList-$(openssl rand -hex 10)"
    FailedOnFilterList="$TempDir/FailedOnFilterList-$(openssl rand -hex 10)"
    if  [ ! -s "stories-to-filter.list" ];then
        mongo_get_all_story
        cat $MongoStoryList | grep -v "$STORIES_TO_FILTER_EXCLUDE"> $StoriesToFilterList
    else
        cat lib/stories-to-filter.list > $StoriesToFilterList   ## Hardcore List
        echo -n > lib/stories-to-filter.list
    fi

    while read STORY_NAME
    do
        if [ "$(cat $ProjectList | grep "^$STORY_NAME\s")" ];then
            MONGO_STOKEN=$(mongo_get_story_data "$STORY_NAME" "stoken")
            if [ ! "$(echo $MONGO_STOKEN | grep -i "StoryIsEnded")" ];then
                if [ ! "$(cat $AbnormalStoryList | grep "^$STORY_NAME\s")" ] && [ ! "$(cat $NormalStoryList | grep "^$STORY_NAME\s")" ];then
                    filter_a_story $STORY_NAME
                else
                    echo "[$(date +"%y%m%d.%H%M%S")] $STORY_NAME :    This story is Filtered " | tee -a $FailedOnFilterList
                fi
            else
                echo "[$(date +"%y%m%d.%H%M%S")] $STORY_NAME :    This story is Ended " | tee -a $FailedOnFilterList
            fi
        else
            echo "[$(date +"%y%m%d.%H%M%S")] $STORY_NAME :    This story doesn't exist on ProjectList " | tee -a $FailedOnFilterList
        fi

    done < $StoriesToFilterList
    echo "###### Story Failed on Filtering ######"
    cat $FailedOnFilterList
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $StoriesToFilterList $FailedOnFilterList
}


#StoryToFilterList="$TempDir/StoryToFilterList-$(openssl rand -hex 10)"
#ls $IMGDIR > $StoryToFilterList

#while read STORY_NAME
#do
#    filter_a_story "$STORY_NAME"
#done < /Data/www/images/1-donotdelete/A
#update_normal_story_to_newest_chapter "world-of-super-sand-box"
# filter_stories
update_normal_story_to_newest_chapter $1
##########
