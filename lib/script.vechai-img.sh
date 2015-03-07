#Old solution   hxnormalize  -x $temp1 | hxselect "#content" | sed  's/ //g'| grep -i -e "src=" -e "blogspot" | tr '\n' ' ' | sed 's/http/\nhttp/g' | sed -re 's/"\/>(.*)//g' | grep -v -e "img alt=" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc" | sed -re 's/<(.*)//g'  | sed '/^$/d' > $output2

if [ "$(echo $line | cut -d"/" -f3)" == "doctruyen.vechai.info" ]; then
	## doctruyen.vechai.info
	#old hxnormalize -x $temp1 | hxselect ".entry2" | sed -re 's/(.*)http/http/g' | sed -re 's/"\/(.*)//g' | grep -i -e ".png" -e ".jpg" -e ".blogspot.com" | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2
	hxnormalize -x $temp1 | hxselect ".entry2" | tr '\n' ' '  | sed 's/http/\nhttp/g' | sed -re 's/"\/(.*)//g' | grep -i -e ".png" -e ".jpg" -e ".blogspot.com" | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2

elif [ "$(echo $line | cut -d"/" -f3)" == "ecchi.vechai.info" ]; then
	## ecchi.vechai.info
	#old hxnormalize -x $temp1  | hxselect ".post" | sed -re 's/(.*)http/http/g' | sed -re 's/"\/(.*)//g' |  grep -i -e ".png" -e ".jpg" -e ".blogspot.com"  | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2
	hxnormalize -x $temp1  | hxselect ".post" | tr '\n' ' '  | sed 's/http/\nhttp/g' | sed -re 's/"\/(.*)//g' |  grep -i -e ".png" -e ".jpg" -e ".blogspot.com"  | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2

elif [ "$(echo $line | cut -d"/" -f3)" == "vc1.vechai.info" ]; then
	## vc1.vechai.info	## vc2.vechai.info
	#old hxnormalize -x $temp1  | hxselect ".post-body" | sed -re 's/(.*)http/http/g' | sed -re 's/"\/(.*)//g' |  grep -i -e ".png" -e ".jpg" -e ".ggpht.com" | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2
	hxnormalize -x $temp1  | hxselect ".post-body" | tr '\n' ' '  | sed 's/http/\nhttp/g' | sed -re 's/"\/(.*)//g' |  grep -i -e ".png" -e ".jpg" -e ".ggpht.com" | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2
	
elif [ "$(echo $line | cut -d"/" -f3)" == "vc2.vechai.info" ]; then
	## vc1.vechai.info	## vc2.vechai.info
	#old hxnormalize -x $temp1  | hxselect ".post-body" | sed -re 's/(.*)http/http/g' | sed -re 's/"\/(.*)//g' |  grep -i -e ".png" -e ".jpg" -e ".ggpht.com" | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2
	hxnormalize -x $temp1  | hxselect ".post-body" | tr '\n' ' '  | sed 's/http/\nhttp/g' | sed -re 's/"\/(.*)//g' |  grep -i -e ".png" -e ".jpg" -e ".ggpht.com" | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2
	
elif [ "$(echo $line | cut -d"/" -f3)" == "vechai.info" ]; then
	## vechai.info
	#old hxnormalize -x $temp1 | hxselect "#zoomtext" | sed -re 's/(.*)http/http/g' | sed -re 's/"\/(.*)//g' |  grep -i -e ".png" -e ".jpg" -e ".blogspot.com" | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2
	hxnormalize -x $temp1 | hxselect "#zoomtext" | tr '\n' ' '  | sed 's/http/\nhttp/g' | sed -re 's/"\/(.*)//g' |  grep -i -e ".png" -e ".jpg" -e ".blogspot.com" | grep -v -e "topphimhay.com" -e "hihuhi" -e ".asia" -e "picasaweb" -e "imgabc"  > $output2
	
fi
