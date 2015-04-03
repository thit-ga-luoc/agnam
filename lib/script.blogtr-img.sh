#old - hxnormalize -x $temp1 | hxselect "#content" | sed 's/img src="/\n/g' | sed 's/ //g' | sed -e 's/"\/>//g' -e 's/<//g' -e 's/br\/>//g' | grep "http://" | sed '/^$/d' | sed -re 's/br\/(.*) //g'   > $output2
#hxnormalize -x $temp1 | hxselect "#content" | sed -re 's/http:\/\//\nhttp:\/\//g' -e 's/"\/>//g' -e 's/br\/>//g' -e 's/br\/(.*) //g'| grep -i -e "http:" -e ".png" -e ".jpg" -e ".jpeg" | grep -v "photo\.zing\.vn" | sed -re 's/\[.*//g' -e 's/<img (.*)//g' | sed -re 's/Dukh8Dqy6No\/VFZuDj34QMI\/AAAAAAAAYKI\/mhu54A-mDfQ.*/LINK-ANH-KHONG-HOP-LE/gI'  > $output2
#hxnormalize -x $temp1 | hxselect "#content" | sed -re 's/http(s)?:\/\//\nhttp\1:\/\//g' -e 's/"\/>//g' -e 's/br\/>//g' -e 's/br\/(.*) //g'| grep -i -e "http" -e ".png" -e ".jpg" -e ".jpeg" | grep -v "photo\.zing\.vn" | sed -re 's/\[.*//g' -e 's/<img (.*)//g' | sed -re 's/Dukh8Dqy6No\/VFZuDj34QMI\/AAAAAAAAYKI\/mhu54A-mDfQ.*/LINK-ANH-KHONG-HOP-LE/gI' > $output2
# hxnormalize -x $temp1 | hxselect "#content" | sed -re 's/http/\nhttp/g' -e 's/"\/>//g' -e 's/br\/>//g' -e 's/br\/(.*) //g'| grep -i -e "http" -e ".png" -e ".jpg" -e ".jpeg" | grep -v "photo\.zing\.vn" | sed -re 's/\[.*//g' -e 's/<img (.*)//g' | sed -re 's/Dukh8Dqy6No\/VFZuDj34QMI\/AAAAAAAAYKI\/mhu54A-mDfQ.*/LINK-ANH-KHONG-HOP-LE/gI'  > $output2 ### changed on Feb 9th 2015

PageList=$2
hxnormalize -x $1 | hxselect "#content" |
hxwls | grep -v "photo\.zing\.vn" |
sed -re 's/Dukh8Dqy6No\/VFZuDj34QMI\/AAAAAAAAYKI\/mhu54A-mDfQ.*/LINK-ANH-KHONG-HOP-LE/gI' > $PageList
