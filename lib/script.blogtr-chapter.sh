#!/bin/bash
#hxnormalize -x $temp1 | hxselect "#list-chapters" | sed -re 's/(.*)a href="\/truyen/http:\/\/blogtruyen.com\/truyen/g' -e 's/\">(.*)//g' -e 's/"/ /g' | grep "http://blogtruyen.com/truyen" |  awk '{gsub( /\./,"-",$NF);gsub( "_","-",$NF); print "#"$NF"#", $1}' | awk '{gsub("^#0*","#",$1); gsub("^##","#0#",$1); print $0}'  > $output1

ChapterList=$2

cat $1  | hxnormalize -x | hxselect "#list-chapters" | hxunent|
tr '\n' ' ' | sed -re 's/<span class="title"/\n/g' |
grep -Po "<a href=\"\/truyen.*?\">" |
sed 's#.*href="/truyen#http://blogtruyen.com/truyen#g' |
sed -re 's/([0-9]*[0-9]+)/#\1#/g' | sed -re 's/(^.*#).*/\1/g' | sed 's/#\|"//g' |
awk '{gsub( /\./,"-",$NF);gsub( "_","-",$NF); print "#"$NF"#", $1}'|
awk '{gsub("^#0*","#",$1); gsub("^##","#0#",$1); print $0}' > $ChapterList
