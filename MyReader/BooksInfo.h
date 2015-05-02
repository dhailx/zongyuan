//
//  BooksInfo.h
//  MyReader
//
//  Created by qintao on 13-5-17.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
@interface BooksInfo : NSObject
{
    NSString *classification; //分类
    NSString *bookName;
    NSString *author;
    NSString *publishDate; //出版日期
    NSString *standard;
    NSMutableArray *content;
    
    
}

//BookID BooKName  Author  PublishDate  page  Language BookProfile booksize PublishDate Weight Path BookCover CategoryID

@property (nonatomic, retain) NSString *userName;           //用户名
@property (nonatomic, retain) NSString *password;           //用户密码
@property (nonatomic, retain) NSString *UUID;
@property (nonatomic, retain) NSMutableString *body;
@property (nonatomic, retain) NSMutableDictionary *headerDictionary;
@property (nonatomic, retain) NSString *classification;

//@property (nonatomic, unsafe_unretained, readwrite) int bookCount;
@property (nonatomic) int bookID;                 //ID不能为空，且不能相同,必须给***
@property (nonatomic, retain) NSString *bookName;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *publishDate;
@property (nonatomic, retain) NSString *BookCover;
@property (nonatomic, retain) NSMutableString *bookUrl;
@property (nonatomic)  int page;
@property (nonatomic, unsafe_unretained) int CategoryID;
@property (nonatomic, retain) NSMutableArray *content;
@property (nonatomic, retain) NSString *deleteBookId;
@property (nonatomic, retain) NSString *NoEmpowerBook;
@property (nonatomic, copy) NSString * documentPath;
@property (nonatomic, retain) NSMutableString *urlStr;
@property (nonatomic,retain)NSMutableString * groupPath;                	//自定义文件夹的路径(下载数据)
@property (nonatomic,retain)NSMutableString * savePath;					//默认下载的路径(文件夹下具体的文件名)
@property (nonatomic,retain)NSMutableString * tempPath;					//下载的临时地址(文件夹下具体的文件名)
//@property (nonatomic,retain)UIProgressView  * progressView;//下载的进度条
@property (nonatomic,retain)MBProgressHUD  *progressView;
@property (nonatomic,retain)NSMutableString * bodyKey;
@property (nonatomic,retain)NSMutableDictionary *bodyDic;

@property (nonatomic,retain)NSString *bookKey;

@property (nonatomic,strong)NSString *postToken;

@property (nonatomic,strong)NSString *logType;

@property (nonatomic,strong)NSString *noDestroy; //作废字段

@property BOOL bLoad;
@property BOOL bCollect;
@property BOOL bMark;
@property BOOL bNote;
@property (nonatomic,strong)UIProgressView *pro;

@end
