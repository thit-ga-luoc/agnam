#!/usr/bin/python2.7
# -*- coding: utf-8 -*-
from sys import argv
import re
from urllib2 import urlopen
from BeautifulSoup import BeautifulSoup
from HTMLParser import HTMLParser

HtmlCodeParse = HTMLParser()  ## Convert HTML code to UTF-8
key_check = ['tập','chap','chương']
key_check_phan=['phần','phan',' II ']
Duplicate_List={}
Output_Type = "Append"

# Replace ###Debug with "" to enable Debug/Review mode

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

def Chapter_Name_Parser(CHAPTER_NAME,Prefix=""):
    for Key in key_check:
        if re.findall(Key,str(CHAPTER_NAME.encode("utf-8")),flags=re.IGNORECASE) != []:
            #return str(re.sub(".*%s.*?([0-9]+.*?)[\s]?.*" %Key,r"\1",CHAPTER_NAME,flags=re.IGNORECASE))
            CHAPTER_NAME=re.sub(".*%s.*?([0-9]+)" %Key,r"\1",CHAPTER_NAME,flags=re.IGNORECASE)  # get all character after "key_check"
            CHAPTER_NAME=re.sub(" .*" ,"",CHAPTER_NAME,flags=re.IGNORECASE)  # Remove all character after first space " "
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

def html_parser_blogtruyen_story(URL,FilePath):
    HtmlContent = urlopen(URL).read()
    soup = BeautifulSoup(HtmlContent)
    cooked_soup = soup.findAll('div',attrs={'id':'list-chapters'})
    ChapterList = ""
    ChapterBonus = []
    for div in cooked_soup:
        CHAPTERS = div.findAll('a')
        for a in CHAPTERS:
            Prefix=""
            CHAPTER_NAME=HtmlCodeParse.unescape(a.string)   ### Convert all html code to utf-8
            if "/truyen/" not in a['href']:  ## Only accept "href" that contain "/truyen/"
                continue

            elif re.findall("[0-9]+",CHAPTER_NAME) == []:   ## Chapter_Name contain no number will be placed on ChapterBonus
                ChapterBonus.append(a)
                continue

            #CHAPTER_NAME=HtmlCodeParse.unescape(a.string)   ### Move to line 59
            for Key in key_check_phan:
                if re.findall(Key,str(CHAPTER_NAME.encode("utf-8")),flags=re.IGNORECASE) != []:
                    Prefix="V2-" ### Will be extented to V2, V3, V4...

            if  Prefix=="V2-":  ### Please remove this condition to enable V2 check
                continue

            CHAPTER_NAME=Chapter_Name_Parser(CHAPTER_NAME,Prefix)   ### Parse Chapter_Name
            if CHAPTER_NAME == None :   ### If Chapter_Name is NULL =>  will be placed on  ChapterBonus
                ChapterBonus.append(a)
                continue
            else:
             ###Debug   print HtmlCodeParse.unescape(a.string)
                CHAPTER_URL="http://blogtruyen.com" + a['href']
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

def html_parser_blogtruyen_chapter(URL,FilePath):
    HtmlContent = urlopen(URL).read()
    HtmlFeeder = BeautifulSoup(HtmlContent)
    HtmlParsed = HtmlFeeder.findAll('article',attrs={'id':'content'})
    PageList=""
    for div in HtmlParsed:
        PAGES=div.findAll('img')
        for a in PAGES:
            if "googleusercontent.com/gadgets/proxy?container" in a['src']:  ## In case of site using Proxy
                a['src']=re.sub(".*url=(https?://.*)",r"\1",a['src'])
            a['src']=re.sub(" ","%20",a['src'])
            PageList+=a['src'] + "\n"

    if Output_Type == "print" :  ### Choose output type
        print PageList
    else:
        append_to_file(FilePath,PageList)

dict_job = {'ChapterList': html_parser_blogtruyen_story, 'PageList': html_parser_blogtruyen_chapter}
# $1 ==  ChapterList or PageList
# $2 ==  URL
# $3 ==  Path-To-Output-File
dict_job[argv[1]](argv[2],argv[3])
#print argv

#URL="http://blogtruyen.com/truyen/bleach"
#Chap_URL="http://blogtruyen.com/truyen/historys-strongest-disciple-kenichi/chapter-527-buoc-di-dau-tien-cua-nhom-vu-trang"
##html_parser_blogtruyen_story(URL,FilePath="Story.txt")
#html_parser_blogtruyen_chapter(Chap_URL,FilePath="Chapter")
