### Old solution hxnormalize  -x $temp1 | hxselect "#innerContent" | tr "\n" " " | sed 's/http/\nhttp/g' | grep "vechai.info" | sed -re 's/<\/(.*)//g' | sed 's/"/   /g' | awk '{gsub( /\./,"-",$NF);gsub( "_","-",$NF); print "#"$NF"#""    "  $1}' | grep "#[0-9]*#" > $output1
ChapterList=$2
## hx "#content" | delete all newline \n | replace http with \nhttp | grep "vechai.info" | delete all character behind </
## Delete all character between {/"} {\"} or {html"} {\"} or {htm"} {\"} |  exclude all unnecessary line | remove all text behind chapter number (very rare case) | AWK to print $NF $1
hxnormalize  -x $1 | hxselect "#zoomtext" | tr '\n' ' ' |
sed 's/http/\nhttp/g' | grep "vechai.info" | sed -re 's/<\/(.*)//g' |
sed -e 's/\/\".*\">/\/  /g' -e 's/html\".*\">/html  /g' -e 's/htm\".*\">/htm  /g' -e 's/<strong>//g' -e  's/\">.*\">/\/  /g'  |
grep -v -e "hoi-nhung-nguoi-thich-doc-truyen-tranh\|hihuhi\|.asia\|<div\|class\|\"\|>\|<" |
sed -re 's/-    (.*)//g;s/]//g;s/\[//g;s/tv(.*)//gI;s/\(//g;s/\)//g;s/ :(.*)//g;s/: (.*)//g' |
sed -re 's/([0-9]*[0-9]+)/#\1#/g' | sed -re 's/(^.*#).*/\1/g' | sed 's/#//g' |
awk '{gsub( /\./,"-",$NF);gsub( "_","-",$NF); print "#"$NF"#", $1}' |
 awk '{gsub("^#0*","#",$1); gsub("^##","#0#",$1); print $0}'  | grep -v -e "#http:\/\/"  > $ChapterList
#grep -v -e "hoi-nhung-nguoi-thich-doc-truyen-tranh" -e "hihuhi" -e ".asia" -e "<div" -e "class" -e "<" -e ">" -e "\""
#Command ABOVE and BELOVE are the same (Exclusive all unnecessary cases)
#grep -v -e "hoi-nhung-nguoi-thich-doc-truyen-tranh\|hihuhi\|.asia\|<div\|class\|\"\|>\|<"
# Add line below to your script (In the end, before awk command) to remove all unnecessary character after chapter number
# sed -re 's/ ([a-Z]+) //g' | sed -re 's/([a-Z]+)([0-9]+)([a-Z]+)/\2/g' | sed -re 's/([a-Z]+)([0-9]+)/\2/g' | sed -re 's/htm ([a-Z]+)*/htm /g' | sed -re 's/htm( *)/htm /g' | sed 's/htm l/html/g'
# sed -re 's/([0-9]*[0-9]+)/#\1#/g' | sed -re 's/(^.*#).*/\1/g' | sed 's/#//g'
# sed -re 's/([0-9]*[0-9]+)/#\1#/g'   ## replace all numeric character in line
# sed -r 's/^([^0-9]*[0-9]+)[^0-9]*([0-9]+).*/\1 \2/'  ## Remove all character after second block of number in line
