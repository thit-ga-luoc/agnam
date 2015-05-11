#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
#source Environment.sh
source Download.sh
source Import_db.sh
## DownloadChapterList format
# conan  1,3,5,6_7,15_20,51,51-5
# naruto 100,111,195-5,197_200
MOVE_TO_IMG_MODE="Normal"

enable_proxy


##### RUN var_init for all story before main job

DownloadChapterList="$TempDir/DownloadChapterList-$(openssl rand -hex 10)"

echo "$1  $2" > $DownloadChapterList
[ "$1" ] || cat $UDIR/list/download-chapter.list | tr '\r' '\n' | sed -re 's/^(.*)/\1\n/g' | grep -v "^$" > $DownloadChapterList

while read STORY
do
    number_list_parser "$STORY"
    STORY_URL=$(echo $STORY | awk '{print $1}')  ## << continue tomorrow

    story_var_init "$STORY_URL"
    while read CHAPTER_NAME
    do
        if [ "$MOVE_TO_IMG_MODE" == "Force" ] || [ -z "$(cat $MoveToImgDirList | grep "$USTORAGE/$STORY_NAME/chapter-$CHAPTER_NAME$")" ] ; then
            echo -e "\n\n"
            echo "################ DOWNLOAD STAGE  $STORY_URL $CHAPTER_NAME ################"
                download_single_chapter   "$CHAPTER_NAME"
            echo "################ VERIFICATION STAGE $STORY_URL $CHAPTER_NAME ################"
            download_stage_verify "$STORY_NAME" "$CHAPTER_NAME" #    ## << continue tomorrow
            [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadFromWgetLogList
        else
            echo_color "$color_RED" "[INFO][$(date +"%y%m%d.%H%M%S")]$USTORAGE/$STORY_NAME/chapter-$CHAPTER_NAME is already on \$MoveToImgDirList"  | tee -a $ErrorLog
        fi
    done < $ParsedList
    do_move_story_to_imgdir_list "$STORY_NAME"
    #[ -d "$USTORAGE/$STORY_NAME/chapter-$CHAPTER_NAME" ] && echo_color "$color_GREEN" "$USTORAGE/$STORY_NAME/chapter-$CHAPTER_NAME"
    import_chapter_to_db  import chapter normal old
    MoveToIMGFailedList="$TempDir/MoveToIMGFailedList-$(openssl rand -hex 10)"
    FAILED_TO_MOVE=$( [ -d "$USTORAGE/$STORY_NAME" ] && ls "$USTORAGE/$STORY_NAME" | grep -v "$CHAPTER_LIST_EXCLUDE_FILE")
    echo_color "$color_LIGHT_CYAN" "$FAILED_TO_MOVE" >> $MoveToIMGFailedList
done < $DownloadChapterList
### print story status summary to screen
cat $MoveToIMGFailedList

[ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadChapterList $MoveToIMGFailedList

unset http_proxy
