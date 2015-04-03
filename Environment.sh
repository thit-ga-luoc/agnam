#!/usr/bin/env bash
UNAME="testscript"
UDIR="/home/sharepoint/$UNAME"
ProjectList="/home/sharepoint/project-list"
IMGDIR="/Data/www/images"

### Logging dirs
ChapListLog="$UDIR/log/ChapListLog"
mkdir -p $ChapListLog

WgetLog="$UDIR/log/WgetLog"
mkdir -p $WgetLog

DeletedLog="$UDIR/log/DeletedLog"
mkdir -p $DeletedLog

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

