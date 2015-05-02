//
//  PublicClassHeader.h
//  MyReader
//
//  Created by baby on 13-7-1.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JGUtil.h"
//********* "AsyRequestServer.h"********//
#define ASY_RequestObjet_UseInfo  @"Asy-Request-Object" //userInfo信息
#define ASY_UpLoadRequestObjet_UseInfo @"Asy-UpLoadRequest-object"
#define ASY_RequestFinishObsever_Info @"Asy-finished-pro"
#define ASY_RequestFailedObsever_Info @"Asy-failed-pro"

//*********  "AppDelegate.h"********//
#define  Select_IP_UserInfo @"http://%@:8001/ValidateUserInfo.ashx"
#define  Insert_sql_UserInfo @"insert into 'UserInfo'(UserID,UUID,Success)values('%@','%@','%@')"
#define Select_sql_UserInfoUUID @"select * from 'UserInfo'"
#define Select_SuccessSql_UserInfoUUID @"select * from 'UserInfo' where Success = 'YES'"


//********* "LeftViewController.h"********//
#define Select_sql_BookCategoryName @"select * from 'BookCategory' where ParentCategoryId=%d"
//#define CategoryString_IP_Url @"http://%@/GetCategoryInfo.ashx"


//********* "CoverFlowViewController.h"********//
#define CategoryString_IP_Url @"http://%@:8001/GetCategoryInfo.ashx"
#define Insert_sql_BookCategory @"insert into 'BookCategory'(CategoryID,CategoryName,ParentCategoryId) values('%@','%@','%@')"
#define Select_sql_BookCategory @"select * from 'BookCategory'"
#define Select_sql_BookCategoryName @"select * from 'BookCategory' where ParentCategoryId=%d"
#define Select_sql_BookCategoryNameSecond @"select * from 'BookCategory' where CategoryID=%d"
#define Select_sql_BookCategoryId @"select * from 'BookCategory' where CategoryID=%d or ParentCategoryId=%d"

//********* "LibraryListViewController.h"********//
#define kNumBook 4
#define String_IP_Url @"http://%@:8001/UpdateBook.ashx"
#define Select_sql_BookInfo @"select * from 'BookInfo' where UpLoad = 'NO'"
#define Select_sql_AllBookId @"select * from 'BookInfo' where BookKey = 'NO'"
#define Select_sql_UserInfo @"select * from 'UserInfo'"
#define Select_sql_BookName @"select * from 'BookInfo' where BookID = %d"
#define BookInfo_Bookurl @"http://192.168.1.242/GetBookInfo.ashx"
//#define Delete_sql_Book  @"update 'BookInfo' set 'UpLoad' = 'YES' where BookID = %d"
#define Delete_sql_Book  @"delete from 'BookInfo' where BookID = %d"
#define Uplod_sql_BookNo  @"update 'BookInfo' set 'BookKey' = 'NO' where BookKey = 'YES'"
#define Uplod_sql_Book  @"update 'BookInfo' set 'UpLoad' = 'NO' where BookID = %d"
#define isDownload_sql_Book @"update 'BookInfo' set 'BookKey' = 'YES' where BookID = %d"
#define chanceDownload_sql_book @"update 'BookInfo' set 'BookKey' = 'NO' where BookID = %d"
#define Insert_sql_BookInfo @"insert into 'BookInfo'(bookID,bookName,page,CategoryID,Path,BookKey,UpLoad,BookMark,BookNote,BookCover) values(%d,'%@',%d,%d,'%@','NO','NO','NO','NO','NO')"
#define select_sql_indexBookInfo @"select * from 'BookInfo' where CategoryID=%d and UpLoad = 'NO'"
#define select_sql_allBookInfo @"select * from 'BookInfo' where UpLoad = 'NO'"
#define DownLoad_bookUrl_Book @"http://192.168.1.242:8001/pdfpath/%@"
//#define DownLoad_bookUrl_Book @"http://172.22.160.203:8001/pdfpath/%@"

//#define Select_sql_BookCategoryName @"select CategoryID from 'BookCategory' where ParentCategoryId=%d"



/************************新后台接口******************/
/*********查询已收藏的book***********/
#define select_sql_CollectedBook @"select * from 'BookInfo' where BookCover='YES' and UpLoad = 'NO'"
/*********查询已标签的book***********/
#define select_sql_NotedBook @"select * from 'BookInfo' where BookMark='YES' and BookCover = 'NO'"
/*********查询已批注的book***********/
#define select_sql_MarkedBook @"select * from 'BookInfo' where BookNote='YES' and BookMark = 'NO' and BookCover = 'NO'"
/*********加入收藏的Book*************/
#define update_sql_BookCover @"update 'BookInfo' set 'BookCover' = 'YES' where BookID = %d"
/*********添加批注的Book*************/
#define update_sql_BookNote @"update 'BookInfo' set 'BookNote' = 'YES' where BookID = %d"
/*********添加标签的Book*************/
#define update_sql_BookMark @"update 'BookInfo' set 'BookMark' = 'YES' where BookID = %d"
/*********取消收藏的Book*************/
#define update_sql_canleBookCover @"update 'BookInfo' set 'BookCover' = 'NO' where BookID = %d"
/*********取消批注的Book*************/
#define update_sql_canleBookNote @"update 'BookInfo' set 'BookNote' = 'NO' where BookID = %d"
/*********取消标签的Book*************/
#define update_sql_canleBookMark @"update 'BookInfo' set 'BookMark' = 'NO' where BookID = %d"
/*****返回分类接口****/
#define  return_class_url @"http://%@:8080/zongyuan/archive/tech/category/?parent=0&userId=%@&deviceid=%@"
/*****返回文档接口****参数格式 userId=1&deviceid=dfsfsdfv*/
#define return_wordData_url @"http://%@:8080/zongyuan/archive/tech/records/list/"
/*****下载文档接口**** 参数格式 userId=admin&deviceid=adcsdcas*/
#define return_downBook_url @"http://%@:8080/zongyuan/upload/?bookId=%d&userId=%@&deviceid=%@"
/*****上传批注接口**** 参数格式 strRemarkString={"1":"1"}&userId=admin&deviceid=dfsfsdfv*/
#define upload_pizhu_url @"http://%@:8080/zongyuan/archive/tech/recordsDetail/"
/***********参数格式  bookId=913&userId=admin&deviceid=dfsfsdfv***************/
#define down_pizhu_url @"http://%@:8080/zongyuan/archive/tech/recordsDetail/list/"
/*********参数格式 username=admin&password=88888888&deviceid=adcsdcas************/
#define login_request_url @"http://%@:8080/zongyuan/login/client/"

/************是否可以批注****************************/
#define isPizhu_request_url @"http://%@:8080/zongyuan/archive/tech/recordsDetail/notation"

/***********上传token值****************/
#define postToken_request_url @"http://%@:8080/zongyuan/login/deviceToken"
