#!/usr/bin/env bash
ChapterList=$2
hxnormalize -x $1 | hxselect ".chapter-list" | tr '\n' ' ' | sed -re 's/http:\/\//\nhttp:\/\//g' |
grep "izmanga.com"  |  sed -re 's/<\/a>(.*)//g;s/\"/ /g;s/( -|- | :|: ).*//g' | sed -re 's/([0-9]*[0-9]+)/#\1#/g' |
sed -re 's/(^.*#).*/\1/g' | sed 's/#//g' | awk '{gsub( /\./,"-",$NF);gsub( "_","-",$NF); print "#"$NF"#", $1}' |
awk '{gsub("^#0*","#",$1); gsub("^##","#0#",$1); print $0}'  >  $ChapterList
