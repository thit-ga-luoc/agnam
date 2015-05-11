#!/usr/bin/python2.7
# -*- coding: utf-8 -*-
from sys import argv
import re
from urllib2 import urlopen
from BeautifulSoup import BeautifulSoup
from HTMLParser import HTMLParser

HtmlCodeParse = HTMLParser()  ## Convert HTML code to UTF-8
key_check = ['tập','chap','chương']
key_check_phan=['phần','phan','II']  #,'-2-'
key_check_advert=['www.picasa2html.com','quang+cao.jpg']
Duplicate_List={}
Output_Type = "Append"
# Replace ###Debug with "" to enable Debug/Review mode

def remove_advert_images(PageList):
    PageList_New=""
    for Page in PageList.splitlines():
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


def sort_order_by_numeric(x):
    r = re.compile('(\d+)')
    l = r.split(x)
    return [int(y) if y.isdigit() else y for y in l]

def append_to_file(FilePath, Content):
    file=open(FilePath,"w")
    file.write(Content)
    file.close()

def insert_duplicate_name_list(NAME):
    FLAG=0
    for K in Duplicate_List:
        if K == NAME :
           FLAG=1
           break
    if FLAG == 1:
        Duplicate_List[NAME] += 1
    else:
        Duplicate_List[NAME] = 2

def Chapter_Name_Parser(Chapter_URL,Prefix=""):
    CHAPTER_NAME=re.sub(".*-chuong-.*?([0-9].*)",r"\1",Chapter_URL,flags=re.IGNORECASE)  # get all character after "-chuong-"
    CHAPTER_NAME=re.sub("/$" ,"",CHAPTER_NAME,flags=re.IGNORECASE)  # Remove last "/"
    CHAPTER_NAME=re.sub(":|\+|-|_|\.|#","-",CHAPTER_NAME,flags=re.IGNORECASE)  # Convert all -+._#:  to -
    CHAPTER_NAME=re.sub("-$","",CHAPTER_NAME,flags=re.IGNORECASE)  # Remove last character if it is -
    CHAPTER_NAME=re.sub("^0+([1-9]+)",r"\1",CHAPTER_NAME,flags=re.IGNORECASE)   # Convert 001 to 1
    return "%s%s" %(Prefix,CHAPTER_NAME)

def Chapter_Bonus_Parser(ChapterBonus):
    Bonus_Parsed_List=""
    Bonus_Length=len(ChapterBonus)
    for Chapter in ChapterBonus:
        Bonus_Parsed_List+="#Bonus-%s#   http://blogtruyen.com%s\n" %(Bonus_Length,Chapter['href'])
        Bonus_Length -= 1
    return Bonus_Parsed_List

def html_parser_truyentranhtuan_story(URL,FilePath):
    HtmlContent = urlopen(URL).read()
    #HtmlContent = open('E://story//phan2',"r")
    #HtmlContent=HtmlContent.read()
    soup = BeautifulSoup(HtmlContent)
    cooked_soup = soup.findAll('div',attrs={'id':'manga-chapter'})
    ChapterList = ""
    ChapterBonus = []
    for div in cooked_soup:
        CHAPTERS = div.findAll('a')
        for a in CHAPTERS:
            Prefix=""
            CHAPTER_NAME=HtmlCodeParse.unescape(a.string)   ### Convert all html code to utf-8
            if "http://truyentranhtuan.com/" not in a['href']:  ## Only accept "href" that contain "http://truyentranhtuan.com/"
                continue

            elif re.findall("[0-9]+",a['href']) == []:   ## Chapter_Name contain no number will be placed on ChapterBonus
                ChapterBonus.append(a)
                continue

            for Key in key_check_phan:
                if re.findall(Key,str(a['href']),flags=re.IGNORECASE) != []:
                    Prefix="V2-" ### Will be extented to V2, V3, V4...

            if  Prefix=="V2-":  ### Please remove this condition to enable V2 check
                continue

            CHAPTER_NAME=Chapter_Name_Parser(a['href'],Prefix)   ### Parse Chapter_Name
            if CHAPTER_NAME == None :   ### If Chapter_Name is NULL =>  will be placed on  ChapterBonus
                ChapterBonus.append(a)
                continue
            else:
             ###Debug   print HtmlCodeParse.unescape(a.string)
                CHAPTER_URL=a['href']
                if "#%s#" %CHAPTER_NAME in ChapterList:  ### If Chapter_Name already existed on ChapterList => Will be placed on Duplicate_List
                    insert_duplicate_name_list(CHAPTER_NAME)
                ChapterList+="#%s#   %s\n" %(CHAPTER_NAME,CHAPTER_URL)
             ###Debug   print CHAPTER_NAME
             ###Debug   print "-----------"
###Debug    for a in ChapterBonus:
###Debug        print a
    # Example of duplicate  http://blogtruyen.com/truyen/bleach
    if Duplicate_List != {}:  # Duplicate_list={'560': 2, '130': 2}
        for K in Duplicate_List:   # K is 560 and 130
            Temp_Var=re.findall("#%s#.*\n" %K,ChapterList)  # Temp is : [u'#560#   http://blogtruyen.com/truyen/bleach/chap-560\n', u'#560#   http://blogtruyen.com/truyen/bleach/chap-560-126193\n']
            for Chapter in Temp_Var:                        #           [u'#130#   http://blogtruyen.com/truyen/bleach/chap-130-extra\n', u'#130#   http://blogtruyen.com/truyen/bleach/chap-130-new-new-new\n']
                ChapterList=re.sub(Chapter,"#%s-%d#   %s" %(K,Duplicate_List[K],Chapter.split("   ")[1]),ChapterList)
                Duplicate_List[K]=Duplicate_List[K] - 1
    #Result :   #130-2#   http://blogtruyen.com/truyen/bleach/chap-130-extra
                #130-1#   http://blogtruyen.com/truyen/bleach/chap-130-new-new-new
                #560-2#   http://blogtruyen.com/truyen/bleach/chap-560
                #560-1#   http://blogtruyen.com/truyen/bleach/chap-560-126193

    ###### In the end of this function,there are 2 list = ChapterList + ChapterBonus
    Bonus_Parsed_List=Chapter_Bonus_Parser(ChapterBonus)
    #print(Bonus_Parsed_List)
    #print "-------------"
    #ChapterList+=Bonus_Parsed_List
    ChapterList=Bonus_Parsed_List + ChapterList

    if Output_Type == "print" :  ### Choose output type
        print(ChapterList)
    else:
        append_to_file(FilePath,ChapterList)

def sort_page_list(PageList):
    Sorted_PageList=""
    Temp_List=sorted(PageList.splitlines(),key=sort_order_by_numeric)
    for Page in Temp_List:
        Sorted_PageList+="%s\n" %Page
    return Sorted_PageList



def html_parser_truyentranhtuan_chapter(URL,FilePath):
    HtmlContent = urlopen(URL).read()
    #HtmlContent = open('E://story//URL-N',"r")
    #HtmlContent=HtmlContent.read()
    tttuan=re.findall("var slides_page_path.*",HtmlContent)  #tttuan
    # tttuan=re.sub(".*\[(.*)\].*",r"\1",tttuan[0])
    tttuan=re.findall("\[(.*)\]",tttuan[0])

    blogspot=re.findall("var slides_page_url_path.*",HtmlContent)  #blogspot
   # blogspot=re.sub(".*\[(.*)\].*",r"\1",blogspot[0])
    blogspot=re.findall("\[(.*)\]",blogspot[0])

    if "http" in tttuan[0]:
        if "http" in tttuan[0] and "http" in blogspot[0] :
            blogspot=re.sub("\""," ",blogspot[0])
            PageList=re.sub("\,","\n",blogspot)
            PageList+="\n"
        else:
            tttuan=re.sub("\""," ",tttuan[0])
            PageList=re.sub("\,","\n",tttuan)
            PageList=sort_page_list(PageList)
            PageList+="\n"
    elif "http" in blogspot[0]:
        blogspot=re.sub("\""," ",blogspot[0])
        PageList=re.sub("\,","\n",blogspot)
        PageList+="\n"
    else:
       PageList=""

    PageList=remove_advert_images(PageList)
    if Output_Type == "print" :  ### Choose output type
        print PageList
    else:
        append_to_file(FilePath,PageList)
dict_job = {'ChapterList': html_parser_truyentranhtuan_story, 'PageList': html_parser_truyentranhtuan_chapter}
# $1 ==  ChapterList or PageList
# $2 ==  URL
# $3 ==  Path-To-Output-File
dict_job[argv[1]](argv[2],argv[3])
#print argv

#Chap_URL="http://truyentranhtuan.com/one-piece-chuong-742"
#URL="http://truyentranhtuan.com/naruto"
#html_parser_truyentranhtuan_story(URL,FilePath="Story.txt")
#html_parser_truyentranhtuan_chapter(Chap_URL,FilePath="Chapter")
