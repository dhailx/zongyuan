//
//  DBItem.h
//  MyReader
//
//  Created by YDJ on 13-6-1.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBItem : NSObject

@property (nonatomic,strong)FMDatabase * dataBase;

@property (nonatomic,retain)NSString * name;

+(DBItem *)getDBtem;
@end



/*
 
 
 
 //    bookinfo.urlStr=(NSMutableString *)@"http://192.168.1.242/GetCategoryInfo.ashx ";//@"http://192.168.1.242/UploadRemark.ashx";//@"http://192.168.1.242/GetBookInfo.ashx";//;//@"http://117.79.157.158:8080/SafetyService/Register/64013758/e10adc3949ba59abbe56e057f20f883e/e8a3211884a51d51e8fe1f40e023fcdd";//@"http://192.168.1.242/ValidateUserInfo.ashx";
 //    AsyRequest
 
 
 
 

 
 
 
 */
