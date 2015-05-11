#!/usr/bin/env bash
PROXY_SERVER="http://taebruce.zapto.org:58008"
UNAME="testscript"
UDIR="/home/sharepoint/Manga-Crawler/$UNAME"
IMGDIR="/Data/www/images"
ProjectList="/home/sharepoint/Manga-Crawler/project-list"
#ProjectList="project-list"

### List dir
mkdir -p $UDIR/list
ImportDBList="$UDIR/list/import-db.list"
ImportMongoList="$UDIR/list/import-mongo.list"

StoryToUpdate="$UDIR/list/story-to-update.list"
NormalStoryList="$UDIR/list/normal-story.list"
AbnormalStoryList="$UDIR/list/abnormal-story.list"
StoryFilteredList="$UDIR/list/story-filtered.list"
EndedStoryList="$UDIR/list/ended-story.list"

[ -f "$NormalStoryList" ] || touch $NormalStoryList
[ -f "$AbnormalStoryList" ] || touch $AbnormalStoryList
[ -f "$ImportDBList" ] || touch  $ImportDBList
[ -f "$ImportMongoList" ] || touch  $ImportMongoList
MoveToImgDirList="$UDIR/list/move-to-imgdir.list"
[ -f "$MoveToImgDirList" ] || echo "#!/usr/bin/env bash" >> $MoveToImgDirList


### Logging dirs
ErrorLog="$UDIR/log/error.log"
MoveToImgDirLog="$UDIR/log/move-to-img-dir.log"

ChapListLog="$UDIR/log/ChapListLog"
mkdir -p $ChapListLog

WgetLog="$UDIR/log/WgetLog"
mkdir -p $WgetLog

DeletedLog="$UDIR/log/DeletedLog"
mkdir -p $DeletedLog

UpdateLog="/var/log/MangaCrawler/UpdateLog/$UNAME-$(date +"%y%m%d.%H%M%S").log"
mkdir -p /var/log/MangaCrawler/UpdateLog

### Temporay dirs
TempDir="$UDIR/tmp/downloading"
mkdir -p $TempDir


### Storage
USTORAGE="/Data/www/downloading-images/$UNAME"
mkdir -p $USTORAGE

STORAGE="/Data/www/images"
# mkdir -p $USTORAGE

##### ENABLE PROXY SERVER
#export http_proxy=http://taebruce.zapto.org:58008/

##### ENABLE TEMPFILE DELETING
DELETE_TEMP_FILES="False"  # True : delete all temp files after run

##### Optional : print result of function to screen
ENABLE_ECHO="True"

##### Optional : Exit when getting error
EXIT_ON_ERROR="False"

##### Optional : Force to move story/chapter to IMG (event it's already exist on $MoveToImgDirList)
MOVE_TO_IMG_MODE="Normal"

##### UPDATE Environment variables
CHAPTER_LIST_EXCLUDE_FILE="stoken"
PAGE_LIST_EXCLUDE_FILE="ctoken\|md5sum\|cprofile"
MONGO_STORY_LIST_EXCLUDE="^dummy-1$\|^dummy-2$"
STORIES_TO_FILTER_EXCLUDE="^dummy-1$\|^Dragons-Son-Changsik$\|^kungfu$\|^o-long-vien-2$\|^good-ending$"
STORIES_TO_UPDATE_EXCLUDE="^dummy$\|^Dragons-Son-Changsik$\|^kungfu$\|^o-long-vien-2$\|^good-ending$\|^conde-konma$|\^last-bonus-key$"

#### Color ####
color_BLACK='\033[0;30m'
color_DARK_GRAY='\033[1;30m'
color_BLUE='\033[0;34m'
color_LIGHT_BLUE='\033[1;34'
color_GREEN='\033[0;32m'
color_LIGHT_GREEN='\033[1;32m'
color_CYAN='\033[0;36m'
color_LIGHT_CYAN='\033[1;36m'
color_DARK_RED='\033[0;31m'
color_RED='\033[1;31m'
color_PURPLE='\033[0;35m'
color_LIGHT_PURPLE='\033[1;35m'
color_BROWN_ORANGE='\033[0;33m'
color_YELLOW='\033[1;33m'
color_LIGHT_GRAY='\033[0;37m'
color_WHITE='\033[1;37m'
color_NONE='\033[0m'
