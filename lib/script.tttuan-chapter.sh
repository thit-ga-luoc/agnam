#!/bin/bash
ChapterList=$2

hxnormalize -x $1 | hxselect "#manga-chapter" | hxunent |
sed -re 's/(.*)ahref="//g' | tr '\n' ' ' |  sed 's/http/\nhttp/g' |
sed -re 's/<\/a>(.*)//g' | awk '{gsub( /\./,"-",$NF);gsub( "_","-",$NF); print "#"$NF"#", $1}' |
awk '{gsub("^#0*","#",$1); gsub("^##","#0#",$1); print $0}' |
sed -re 's/\/\">(.*)//g' | grep "truyentranhtuan.com"  > $ChapterList
