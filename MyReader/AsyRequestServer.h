//
//  AsyRequestServer.h
//  MyReader
//
//  Created by baby on 13-6-7.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "ASIProgressDelegate.h"
#import "BooksInfo.h"
@class SBJsonParser;
@interface AsyRequestServer : NSObject
{
    
    ASINetworkQueue *queue;
}
@property (nonatomic) BOOL requestType;
@property (nonatomic,strong) NSString *requestff;
@property (nonatomic,strong) NSString *logType;
@property (nonatomic,strong) NSString *tokenStr;
@property (nonatomic,strong) NSString *downLoadAll;
+(AsyRequestServer*) getInstance;
-(void)requestFormDataWithNewObject:(BooksInfo *)object fromeDelegate:(UIViewController *)delegate;
-(void)requestDownloadDataWithNewObject:(BooksInfo *)object delegate:(id)control;
-(BOOL)testNetWorkConnectionWithUrlString:(NSString *)urlStr;
-(void)requestFormDataWithNewObject:(BooksInfo *)object fromeDelegate:(UIViewController *)delegate UserName:(NSString*)userName BookId:(int)bookId;

-(void)StopQueue;
-(void)showError:(NSString*)message;


-(void)SetProgress:(id)progress;
@end
