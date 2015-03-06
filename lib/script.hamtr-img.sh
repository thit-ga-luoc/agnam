hxnormalize -x $temp1 | hxselect "#content_chap" | tr '\n' ' ' | sed 's/src="http/\nhttp/g' | sed -re 's/"(.*)//'g | grep -v -e "bestmedia" -e "div class"  | sed '/^$/d' > $output2
