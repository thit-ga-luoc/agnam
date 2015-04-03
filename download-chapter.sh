#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
source Environment.sh
source Download.sh
source Utils.sh

## DownloadChapterList format
# conan  1,3,5,6_7,15_20,51,51-5
# naruto 100,111,195-5,197_200


DownloadChapterList="$TempDir/DownloadChapterList-$(openssl rand -hex 10)"

echo "$1  $2" > $DownloadChapterList
[ "$1" ] || cat download-chapter.list | tr '\r' '\n' | sed -re 's/^(.*)/\1\n/g' | grep -v "^$" > $DownloadChapterList

while read STORY
do
    number_list_parser "$STORY"
    STORY_URL=$(echo $STORY | awk '{print $1}')  ## << continue tomorrow

    story_var_init "$STORY_URL"
    while read CHAPTER_NUMBER
    do
        echo -e "\n\n"
        echo "################ DOWNLOAD STAGE  $STORY_URL $CHAPTER_NUMBER ################"
            download_single_chapter   "$CHAPTER_NUMBER"
        echo "################ VERIFICATION STAGE $STORY_URL $CHAPTER_NUMBER ################"
        download_stage_verify "$STORY_NAME" "$CHAPTER_NUMBER" #    ## << continue tomorrow
        [ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadFromWgetLogList
    done < $ParsedList

done < $DownloadChapterList

[ "$DELETE_TEMP_FILES" == "True" ] && rm -f $DownloadChapterList

