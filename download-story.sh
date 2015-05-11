#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
#source Environment.sh
source Download.sh
#source Common.sh
source Import_db.sh

### Enable proxy for downloading
enable_proxy

MOVE_TO_IMG_MODE="Normal"
##### RUN var_init for all story before main job
StoryToDownloadList="$TempDir/StoryToDownloadList-$(openssl rand -hex 10)"
StoryDownloadedList="$TempDir/StoryToDownloadList-$(openssl rand -hex 10)"
MoveToIMGFailedList="$TempDir/MoveToIMGFailedList-$(openssl rand -hex 10)"

### echo "$1" > $StoryToDownloadList
[ "$1" ] || cat $UDIR/list/download-story.list | tr '\r' '\n' | sed -re 's/^(.*)/\1\n/g' | grep -v "^$" > $StoryToDownloadList

download_stage_prerun $StoryToDownloadList
while read STORY_URL
do
    echo -e "\n\n\n"
    echo_color "$color_RED" "################ DOWNLOAD STAGE  $STORY_URL ################"
    download_full_story $STORY_URL
    echo -e "\n\n\n"
    echo_color "$color_RED" "################ VERIFICATION STAGE $STORY_URL ################"
    # Only enable when use download_stage_verify  - Temporary
    #story_var_init "$STORY_URL"
    download_stage_verify "$STORY_NAME"
    echo -e "\n\n\n"
    echo_color "$color_RED" "############# Move to IMGDIR Stage - $STORY_NAME #############"
    do_move_story_to_imgdir_list "$STORY_NAME"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadFromWgetLogList
    echo "$STORY_NAME" >> $StoryDownloadedList

    FAILED_TO_MOVE=$([ -d "$USTORAGE/$STORY_NAME" ] && ls "$USTORAGE/$STORY_NAME" | grep -v "$CHAPTER_LIST_EXCLUDE_FILE")
    echo_color "$color_LIGHT_CYAN" "$STORYNAME $FAILED_TO_MOVE" >> $MoveToIMGFailedList
done < $StoryToDownloadList
import_chapter_to_db  "import" "story" "normal" "new" "$StoryDownloadedList"

### print story status summary to screen
cat $MoveToIMGFailedList

[ "$DELETE_TEMP_FILES" == "True" ] && rm -f $StoryToDownloadList $MoveToIMGFailedList
### Disable proxy after downloading
unset http_proxy
