#!/usr/bin/python2.7
# -*- coding: utf-8 -*-
from sys import argv
import re
import urllib2
from BeautifulSoup import BeautifulSoup

Enale_Review = "False"
key_check = ['Chương', 'chương', 'Tập', 'tập', 'Chapter', 'chapter', 'chap', 'Chap']
key_check_advert=['goccay.vn/zzzz.jpg','googleusercontent.com/gadgets/proxy?container']
Output_Type = "Append"

def append_to_file(FilePath, Content):
    file=open(FilePath,"w")
    file.write(Content)
    file.close()

def remove_advert_images(PageList):
    PageList_New=""
    for Page in PageList.split(" "):
        flag=0
        for Key in key_check_advert:
            if Key in Page:
                flag=1
                break
        if flag == 1:
            #print "AAA"
            continue
        PageList_New+=Page + "\n"
    return PageList_New


###Check phan unicode in CHAPTER-NAME
def check_unicode_chapter_name(CHAPTER_NAME):
    # print CHAPTER_NAME
    CHAPTER_NAME_TMP = []
    # print CHAPTER_NAME
    if len(CHAPTER_NAME) != 0:
        # print CHAPTER_NAME
        # print CHAPTER_NAME
        for i in range(len(CHAPTER_NAME)):
            check_unicode = CHAPTER_NAME[i][1]

            a = "phần"
            a = a.decode('utf-8')
            # print check_unicode
            ###Check Unicode (Phan x) --> by pass this value
            if check_unicode == a or check_unicode == "phan":
                pass
            else:
                p_tmp = re.compile('[0-9]+[a-zA-Z]?')
                CHAPTER_NAME_LOCAL = p_tmp.findall(CHAPTER_NAME[i][0])
                # print CHAPTER_NAME_LOCAL
                # If not Unicode (Phan x), append to list, chapter
                CHAPTER_NAME_TMP.append(CHAPTER_NAME_LOCAL[0])
                # print chapter_name
        # print CHAPTER_NAME_TMP
        return CHAPTER_NAME_TMP

###Detect abnormal chapter-name but have digit in chapter-name (Tạm Ngưng 4 Tuần)
def detect_abnomal_chapter_name(CHAPTER_NAME, CHECK):
    check = CHECK
    for i in range(len(CHAPTER_NAME)):
        for x in range(len(key_check)):
            a = key_check[x]
            try:
                a = a.decode('utf-8')
            except:
                pass
            if CHAPTER_NAME[i][1] == a:
                check = 1
                break
            else:
                pass

            # if check == 1:
            #     break
            if check != 1:
                if len(CHAPTER_NAME[i][1]) == 0:
                    check = 1

        if check == 1:
            break

    return check

###Process if CHAPTER-NAME length > 3
def chapter_name_length_gt_3(CHAPTER_NAME,CHAPTER_URL,CHAPTER_INFO):
    chapter_info = CHAPTER_INFO
    ext = 0
    try:
        CHAPTER_NAME = str(int(CHAPTER_NAME[0]))
    except:
        CHAPTER_NAME = str(CHAPTER_NAME[0])
    CHAPTER_NAME_ORGIN = "%s-0" % CHAPTER_NAME
    if not re.search(r'^%s-' % CHAPTER_NAME, chapter_info):
        print "hello"
        CHAPTER_NAME = "%s-%s" % (CHAPTER_NAME, ext)
        # ext += 1
    # print CHAPTER_NAME
    while re.search(r'%s' % CHAPTER_NAME_ORGIN, chapter_info):
        print "Hllo Tan,"
        try:
            CHAPTER_NAME = str(int(CHAPTER_NAME[0]))
        except:
            CHAPTER_NAME = str(CHAPTER_NAME[0])
        leng_replace = 2
        for num in range(3):
            print num
            num_temp = leng_replace - num
            CHAPTER_CHECK = "%s-%s" % (CHAPTER_NAME, num_temp)
            print CHAPTER_CHECK
            if re.search(r'%s' % CHAPTER_CHECK, chapter_info):
                CHAPTER_NAME_BE_REPLACE = "%s-%s" % (CHAPTER_NAME, num_temp)
                # print CHAPTER_NAME_BE_REPLACE
                num_temp += 1
                CHAPTER_NAME_REPLACE = "%s-%s" % (CHAPTER_NAME, num_temp)
                # print CHAPTER_NAME_REPLACE
                try:
                    chapter_info = re.sub('%s,' % CHAPTER_NAME_BE_REPLACE, '%s,' % CHAPTER_NAME_REPLACE, chapter_info)
                    # print chapter_info
                except:
                    pass
            else:
                pass
            ext += 1

    print CHAPTER_NAME_ORGIN
    chapter_info = "%s %s,%s" % (chapter_info, CHAPTER_NAME_ORGIN, CHAPTER_URL)
    return chapter_info

###Process if CHAPTER-NAME length != and < 3
def chapter_name_length_lt_3_and_not_0(CHAPTER_NAME,CHAPTER_URL,CHAPTER_INFO):
    chapter_info = CHAPTER_INFO
    # if len(CHAPTER_NAME) != 0 and len(CHAPTER_NAME) < 3:
        # print "Hello1"
    try:
        try:
            CHAPTER_NAME = "%s-%s" % (int(CHAPTER_NAME[0]), int(CHAPTER_NAME[1]))
        except:
            CHAPTER_NAME = "%s-%s" % (int(CHAPTER_NAME[0]), CHAPTER_NAME[1])
    except:
        try:
            CHAPTER_NAME = int(CHAPTER_NAME[0])
        except:
            CHAPTER_NAME = CHAPTER_NAME[0]
    chapter_info = "%s %s,%s" % (chapter_info, CHAPTER_NAME, CHAPTER_URL)
    #print CHAPTER_NAME
    return chapter_info

###Do not download : zip-rar file
def remove_useless_extension(CHAPTER_URL,useless_extension):
    if re.search('.zip|.rar|.bzip|.7z|.gzip', CHAPTER_URL):
        useless_extension = 1
    return useless_extension

def html_parser_raw_chapter(URL):
    HtmlContent = urllib2.urlopen(URL).read()
    soup = BeautifulSoup(HtmlContent)
    cooked_soup = soup.findAll('div', attrs={'class': 'content'})
    ChapterNameRaw = ""
    bonus_info = []
    for div in cooked_soup:
            CHAPTERS = div.findAll('a')
            for a in CHAPTERS:
                ChapterNameRaw+=a.string + "\n"
    return ChapterNameRaw

def html_parser_hamtr_chapter(URL,FilePath):
    HtmlContent = urllib2.urlopen(URL).read()
    soup = BeautifulSoup(HtmlContent)
    cooked_soup = soup.findAll('div', attrs={'class': 'content'})
    chapter_info = ""
    bonus_info = []
    for div in cooked_soup:
            CHAPTERS = div.findAll('a')
            # p = re.compile('[0-9]+[^ \)\s:.\- ]?')
            p = re.compile(u'(([c,C]hap|[c,C]hapter|\w+)?[ ]+?[0-9]+[^ \)\s:.\- ]?|[0-9]+[^ \)\s:.\- ]?)', re.UNICODE)
            # p = re.compile('(chap?[ ]+?[0-9]+[^ \)\s:.\- ]?|chapter?[ ]+?[0-9]+[^ \)\s:.\- ]?)|[0-9]+[^ \)\s:.\- ]?')
            for a in CHAPTERS:
                CHAPTER_URL="http://hamtruyen.com" + a['href']
                useless_extension = 0
                useless_extension = remove_useless_extension(CHAPTER_URL,useless_extension)

                if useless_extension == 1:
                    pass
                else:
                    # CHAPTER_NAME = p.findall(a.contents[0])
                    try:
                        CHAPTER_NAME = p.findall(a.contents[0].decode('utf-8'))
                    except:
                        CHAPTER_NAME = p.findall(a.contents[0])

                    check = 0

                    check = detect_abnomal_chapter_name(CHAPTER_NAME, check)

                    if check != 1:
                        bonus_info.append(CHAPTER_URL)
                    else:
                        CHAPTER_NAME = check_unicode_chapter_name(CHAPTER_NAME)
                        try:
                            if len(CHAPTER_NAME) >= 3:
                                chapter_info = chapter_name_length_gt_3(CHAPTER_NAME,CHAPTER_URL,chapter_info)
                            elif len(CHAPTER_NAME) != 0 and len(CHAPTER_NAME) < 3:
                                chapter_info = chapter_name_length_lt_3_and_not_0(CHAPTER_NAME,CHAPTER_URL,chapter_info)
                            else:
                                bonus_info.append(CHAPTER_URL)
                        except:
                            bonus_info.append(CHAPTER_URL)
    ###Process special chapter (Just character - not digital in CHAPTER_NAME)
    for i in range(len(bonus_info)):
        CHAPTER_NAME = "Bonus-%s" % (len(bonus_info) - i)
        CHAPTER_URL = bonus_info[i]
        #chapter_info = "%s %s,%s" % (chapter_info, CHAPTER_NAME, CHAPTER_URL)
        chapter_info = "%s,%s %s" % (CHAPTER_NAME, CHAPTER_URL, chapter_info)

    chapter_info=re.sub(" ",r"\n",chapter_info)
    chapter_info=re.sub("(.*),",r"#\1#  ",chapter_info)
    chapter_info=chapter_info.partition("\n")[2]
    chapter_info+="\n"

    if Output_Type == "print" :  ### Choose output type
        print chapter_info
    else:
        append_to_file(FilePath,chapter_info)

    if Enale_Review == "True":
        ChapterNameRaw=html_parser_raw_chapter(URL)
        for i,x in zip(ChapterNameRaw.splitlines() ,chapter_info.splitlines()):
            print i + "\n" + x
            print "--------------------"


def html_parser_hamtr_page(URL,FilePath):
    HtmlContent = urllib2.urlopen(URL).read()
    soup = BeautifulSoup(HtmlContent)
    cooked_soup = soup.findAll('div', attrs={'class': 'content_chap'})
    PAGE_LINK = ""
    for div in cooked_soup:
        PAGES = div.findAll('img')
        for a in PAGES:
            #p = re.compile('http://\S+.[jpg,png]')
            #a = p.findall(str(a.extract()))
            # print a[0]
            #PAGE_LINK = "%s %s" % (PAGE_LINK, a[0])
            PAGE_LINK += "%s\n" %a["src"]
    #PAGE_LINK=re.sub(" ",r"\n",PAGE_LINK)
    #PAGE_LINK+="\n"
    PAGE_LINK=remove_advert_images(PAGE_LINK)

    if Output_Type == "print" :  ### Choose output type
        print PAGE_LINK
    else:
        append_to_file(FilePath,PAGE_LINK)

dict_job = {'ChapterList': html_parser_hamtr_chapter, 'PageList': html_parser_hamtr_page}
# $1 ==  ChapterList or PageList
# $2 ==  URL
# $3 ==  Path-To-Output-File
dict_job[argv[1]](argv[2],argv[3])
#print argv

#html_parser_hamtr_page('http://hamtruyen.com/doc-truyen/kingdom---vuong-gia-thien-ha(thanhtruyen-com)-chapter-319.html')
#html_parser_hamtr_chapter( 'http://hamtruyen.com/one-punch-man---phong-tom-1386.html')
