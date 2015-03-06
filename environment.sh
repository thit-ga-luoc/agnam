#!/bin/sh
UNAME="testscript"
UDIR="/home/sharepoint/$UNAME"
ProjectList="/home/sharepoint/project-list"

### Logging dirs

ChapListLog="$UDIR/log/ChapListLog/"
mkdir -p $ChapListLog

WgetLog="$UDIR/log/WgetLog/"
mkdir -p $WgetLog

### Temporay dirs
TempDir="$UDIR/tmp/downloading"
mkdir -p $TempDir

### Storage
USTORAGE="/Data/www/downloading-images/$UNAME"
mkdir -p $USTORAGE




