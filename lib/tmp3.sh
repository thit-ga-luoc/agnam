TTT chap


cat html | hxnormalize -x | hxselect "#manga-chapter" | hxunent |
sed -re 's/(.*)ahref="//g' | tr '\n' ' ' |  sed 's/http/\nhttp/g' |
sed -re 's/<\/a>(.*)//g' | awk '{gsub( /\./,"-",$NF);gsub( "_","-",$NF); print "#"$NF"#", $1}' |
awk '{gsub("^#0*","#",$1); gsub("^##","#0#",$1); print $0}' |
sed -re 's/\/\">(.*)//g' | grep "truyentranhtuan.com"



cat html | hxnormalize -x | hxselect "#manga-chapter" | hxunent |
tr '\n' ' ' | sed -re 's#href="http#\nhttp#g' |
grep -Po "^http.*<\/a>" | sed -re 's/<\/a>(.*)//g' |
awk '{gsub( /\./,"-",$NF);gsub( "_","-",$NF); print "#"$NF"#", $1}' |
