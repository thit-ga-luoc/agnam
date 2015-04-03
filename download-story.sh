#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source Environment.sh
source Download.sh

DownloadStoryList="$TempDir/DownloadStoryList-$(openssl rand -hex 10)"

echo "$1" > $DownloadStoryList
[ "$1" ] || cat download-story.list | tr '\r' '\n' | sed -re 's/^(.*)/\1\n/g' | grep -v "^$" > $DownloadStoryList

while read STORY_URL
do
    echo "################ DOWNLOAD STAGE  $STORY_URL ################"
    download_full_story $STORY_URL
    echo "################ VERIFICATION STAGE $STORY_URL ################"
    # Only enable when use download_stage_verify  - Temporary
#    story_var_init "$STORY_URL"
    download_stage_verify "$STORY_NAME"
    [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadFromWgetLogList
done < $DownloadStoryList

[ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadStoryList

