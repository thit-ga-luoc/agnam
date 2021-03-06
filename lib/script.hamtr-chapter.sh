#!/usr/bin/env bash
ChapterList=$2
hxnormalize -x $1 | hxselect "#wrapper_listchap" | tr '\n' ' ' | sed 's/href="/\nhttp:\/\/hamtruyen.com/g' |
sed -re 's/<\/a>(.*)//g' | sed 's/">Chapter//g' |
awk '{ gsub( /\./,"-",$2);gsub( "_","-",$2) ; gsub( ":","",$2) ; print "#"$2"#" "   " $1 }' |
grep  "hamtruyen.com"  > $ChapterList
