#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
#source Environment.sh
source Download.sh
#source Common.sh
source Import_db.sh

##### RUN var_init for all story before main job

StoryToDownloadList="$TempDir/StoryToDownloadList-$(openssl rand -hex 10)"
StoryDownloadedList="$TempDir/StoryToDownloadList-$(openssl rand -hex 10)"

### echo "$1" > $StoryToDownloadList
[ "$1" ] || cat $UDIR/list/download-story.list | tr '\r' '\n' | sed -re 's/^(.*)/\1\n/g' | grep -v "^$" > $StoryToDownloadList

echo '$$$$$$$$$$$$$$$$ PRERUN VERIFICATION STAGE  $$$$$$$$$$$$$$$$'
download_stage_prerun $StoryToDownloadList

while read STORY_URL
do
    echo "################ DOWNLOAD STAGE  $STORY_URL ################"
    download_full_story $STORY_URL
    echo "################ VERIFICATION STAGE $STORY_URL ################"
    # Only enable when use download_stage_verify  - Temporary
#    story_var_init "$STORY_URL"
    ### download_stage_verify "$STORY_NAME"
    echo "############# Move to IMGDIR Stage - $STORY_NAME #############"
    #### do_move_story_to_imgdir_list "$STORY_NAME"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadFromWgetLogList
    echo "$STORY_NAME" >> $StoryDownloadedList
done < $StoryToDownloadList
#import_chapter_to_db  "import" "story" "normal" "old" "$StoryDownloadedList"
[ "$DELETE_TEMP_FILES" == "True" ] && rm -f $StoryToDownloadList

### print story status summary to screen
