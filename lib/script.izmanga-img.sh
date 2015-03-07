hxnormalize -x $temp1 | grep "data = " | sed -re "s/http:\/\//\nhttp:\/\//g;s/\||\;//g" -e "s/'//g" | grep -i -e "http:\|.png\|.jpg" > $output2
