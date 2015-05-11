#!/usr/bin/env bash
#source Environment.sh
mongo_get_all_story(){
    MongoStoryList="$TempDir/MongoStoryList-$(openssl rand -hex 10)"
    curl -s  "http://127.0.0.1:4446/mongo/get_data?job=story" | tr ' ' '\n' | sort -V  | grep -v "$MONGO_STORY_LIST_EXCLUDE" > $MongoStoryList
}

mongo_get_all_chapter(){
    local STORY_NAME=$1
    MongoChapterList="$TempDir/MongoChapterList-$(openssl rand -hex 10)"
    curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=$STORY_NAME&job=chapter" | tr ' ' '\n' | sort -V > $MongoChapterList
}

mongo_view_all_story(){
    curl -s  "http://127.0.0.1:4446/mongo/get_data?job=story" | tr ' ' '\n' | sort -V  | grep -v "$MONGO_STORY_LIST_EXCLUDE"
}

mongo_view_all_chapter(){
    local STORY_NAME=$1
    curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=$STORY_NAME&job=chapter" | tr ' ' '\n' | sort -V
}

mongo_view_story_data(){
    local STORY_NAME=$1
    local JOB=$2
    echo $(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=$STORY_NAME&job=$JOB")
}
# MONGO_STOKEN=$(mongo_view_story_data "$STORY_NAME" "stoken")


mongo_view_chapter_data(){
    local STORY_NAME=$1
    local CHAPTER_NAME=$2
    local JOB=$3
    echo $(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=$STORY_NAME&chapter_name=chapter-$CHAPTER_NAME&job=$JOB")
}

mongo_get_story_data(){
    local STORY_NAME=$1
    local JOB=$2
    echo $(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=$STORY_NAME&job=$JOB")
}
# MONGO_STOKEN=$(mongo_get_story_data "$STORY_NAME" "stoken")


mongo_get_chapter_data(){
    local STORY_NAME=$1
    local CHAPTER_NAME=$2
    local JOB=$3
    echo $(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=$STORY_NAME&chapter_name=chapter-$CHAPTER_NAME&job=$JOB")
}
# MONGO_MD5=$(mongo_get_chapter_data  "$STORY_NAME"  "$CHAPTER_NAME"  "md5")
# MONGO_CTOKEN=$(mongo_get_chapter_data  "$STORY_NAME"  "$CHAPTER_NAME"  "ctoken")
# MONGO_CPROFILE=$(mongo_get_chapter_data  "$STORY_NAME"  "$CHAPTER_NAME"  "cprofile")
# MONGO_PAGE_QUALITY=$(mongo_get_chapter_data  "$STORY_NAME"  "$CHAPTER_NAME"  "page")


mongo_import_story(){
    local STORY_NAME=$1
    curl -s  "http://127.0.0.1:4446/mongo/import_data?story_name=$STORY_NAME&job=story" 2>&1 > /dev/null
    echo "[INFO] $STORY_NAME is Imported"
}
## mongo_import_story  "$STORY_NAME"

mongo_import_chapter(){
    local STORY_NAME=$1
    local CHAPTER_NAME=$2
    #[ "$(curl -s  "http://127.0.0.1:4446/mongo/get_data?job=story" | grep -o "$STORY_NAME")"  ] || mongo_import_story $STORY_NAME
    curl -s "http://127.0.0.1:4446/mongo/import_data?story_name=$STORY_NAME&chapter_name=chapter-$CHAPTER_NAME&job=chapter" 2>&1 > /dev/null
    echo "[INFO] $STORY_NAME - chapter-$CHAPTER_NAME is Imported"
}
## mongo_import_chapter "$STORY_NAME" "$CHAPTER_NAME"


mongo_import_story_data(){
    local STORY_NAME=$1
    local JOB=$2
    local VALUE=$3
    #[ "$(curl -s  "http://127.0.0.1:4446/mongo/get_data?job=story" | grep -o "$STORY_NAME")"  ] || mongo_import_story $STORY_NAME
    curl -s "http://127.0.0.1:4446/mongo/import_data?story_name=$STORY_NAME&$JOB=$VALUE&job=$JOB" 2>&1 > /dev/null
    echo "[INFO] $STORY_NAME - $JOB=$VALUE is Imported"
}
## mongo_import_story_data "$STORY_NAME" "stoken" "Stoken-Value"

mongo_import_chapter_data(){
    local STORY_NAME=$1
    local CHAPTER_NAME=$2
    local JOB=$3
    local VALUE=$4
    #[ "$(curl -s  "http://127.0.0.1:4446/mongo/get_data?story_name=$STORY_NAME&job=chapter" | grep -o "chapter-$CHAPTER_NAME\b")" ] || mongo_import_chapter "$STORY_NAME" "$CHAPTER_NAME"
    curl -s "http://127.0.0.1:4446/mongo/import_data?story_name=$STORY_NAME&chapter_name=chapter-$CHAPTER_NAME&$JOB=$VALUE&job=$JOB" 2>&1 > /dev/null
    echo "[INFO] $STORY_NAME - chapter-$CHAPTER_NAME - $JOB=$VALUE is Imported"
}
## mongo_import_story_data "$STORY_NAME" "$CHAPTER_NAME" "md5" "MD5-Value"
## mongo_import_story_data "$STORY_NAME" "$CHAPTER_NAME" "cprofile" "cprofile-Value"
## mongo_import_story_data "$STORY_NAME" "$CHAPTER_NAME" "page" "number-of-page"
## mongo_import_story_data "$STORY_NAME" "$CHAPTER_NAME" "ctoken" "ctoken-Value"

mongo_delete_story(){
    local STORY_NAME=$1
    curl -s  "http://127.0.0.1:4446/mongo/del_data?story_name=$STORY_NAME&job=story" 2>&1 > /dev/null
    echo "[INFO] $STORY_NAME is Deleted"
}
## mongo_delete_story "$STORY_NAME"

mongo_delete_chapter(){
    local STORY_NAME=$1
    local CHAPTER_NAME=$2
    curl -s "http://127.0.0.1:4446/mongo/del_data?story_name=$STORY_NAME&chapter_name=chapter-$CHAPTER_NAME&job=chapter" 2>&1 > /dev/null
    echo "[INFO] $STORY_NAME - chapter-$CHAPTER_NAME is Deleted"
}
## mongo_delete_chapter "$STORY_NAME" "$CHAPTER_NAME"

