//
//  AsyRequestServer.m
//  MyReader
//
//  Created by baby on 13-6-7.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import "AsyRequestServer.h"
#import "PublicClassHeader.h"
#import "NetworkMonitor.h"
#import "Reachability.h"
#import "SBJson.h"
#import "SaffronClientSQLManager.h"
#import "MBProgressHUD.h"

@interface  AsyRequestServer ()
//-(void)requestFinished:(ASIFormDataRequest *)request;
//-(void)requestFailed:(ASIFormDataRequest *)request;
-(void)requestDownloadFinished:(ASIHTTPRequest *)request;
-(void)requestDownloadFailed:(ASIHTTPRequest *)request;
@end

@implementation AsyRequestServer
@synthesize requestType;
@synthesize requestff,logType;
@synthesize tokenStr;
@synthesize downLoadAll;
static AsyRequestServer *asy =nil;

+(AsyRequestServer*) getInstance
{
    @synchronized(self)
    {
        if(asy == nil)
        {
            asy = [[self alloc] init];
        }
        
        return asy;
    }
}

-(id)init
{
	self=[super init];
	if (self)
	{
		queue=[[ASINetworkQueue alloc] init];
        //	[queue reset];
		//	[queue setMaxConcurrentOperationCount:4];//最大并发数量
		[queue setShowAccurateProgress:YES];
		[queue setShouldCancelAllRequestsOnFailure:NO];
        [queue go];
	}
	return self;
}
#pragma -提交数据
-(void)requestFormDataWithNewObject:(BooksInfo *)object fromeDelegate:(UIViewController *)delegate
{
    
    if (object.urlStr) //看是否有url
	{
        NSLog(@"-------url:%@",object.urlStr);
		ASIFormDataRequest * request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:object.urlStr]];
		request.delegate=delegate;
		[request setDidFailSelector:@selector(requestFailed:)];//失败的代理方法
		[request setDidFinishSelector:@selector(requestFinished:)];//成功的代理方法
        if ([requestff isEqualToString:@"GET"]) {
            //requestff 判断请求的方式
            [request setRequestMethod:[NSString stringWithFormat:@"%@",self.requestff]];
        }
        else{
            
            if ([self.logType isEqualToString:@"login"]) {
                [request setRequestMethod:@"POST"];
                [request setPostValue:object.userName forKey:@"username"];
                
            }else{
                [request setRequestMethod:@"POST"];
                [request setPostValue:object.userName forKey:@"userId"];
                
            }
            [request setPostValue:object.UUID forKey:@"deviceid"];
            //[request setPostValue:@"ED7E578BE2F34AFCB20C7798D576E064" forKey:@"deviceid"];
        }
        
        if ([self.tokenStr isEqualToString:@"postToken"]) {
            [request setPostValue:object.postToken forKey:@"deviceToken"];
        }
        //  [request setPostValue:object.userName forKey:@"username"];
        if (object.password) {
            NSLog(@"object.userName%@,%@",object.userName,object.password);
            // [request setPostValue:object.userName forKey:@"username"];
            [request setPostValue:object.password forKey:@"password"];
        }
        [request setTimeOutSeconds:240.0f];  //设置请求超时时间；
        
        
        
        if (object.body) {
            [request setPostValue:object.body forKey:object.bodyKey];
        }
		[request setUserInfo:[NSDictionary dictionaryWithObject:object forKey:ASY_UpLoadRequestObjet_UseInfo]];  //设置详细信息
        if (requestType == 0) {
            // [queue addOperation:request];//加入队列，采用异步
            [request startAsynchronous];
        }else{
            
            [request startSynchronous]; //采用同步
        }
		
        
	}
}
-(void)requestFormDataWithNewObject:(BooksInfo *)object fromeDelegate:(UIViewController *)delegate UserName:(NSString*)userName BookId:(int)bookId
{
    
    if (object.urlStr) //看是否有url
	{
        NSLog(@"-------url:%@",object.urlStr);
		ASIFormDataRequest * request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:object.urlStr]];
		request.delegate=delegate;
		[request setDidFailSelector:@selector(requestFailed:)];//失败的代理方法
		[request setDidFinishSelector:@selector(requestFinished:)];//成功的代理方法
		if ([object.urlStr hasPrefix:@"https"])
		{
			[request setValidatesSecureCertificate:NO];
		}
        [request setRequestMethod:@"POST"];
        [request setTimeOutSeconds:240];  //设置请求超时时间；
        
        if (object.UUID) {
            // [request appendPostData:[object.UUID dataUsingEncoding:NSUTF8StringEncoding]];
            [request setPostValue:object.UUID forKey:@"deviceid"];
            [request setPostValue:object.userName forKey:@"userId"];
        }
        
        //  [request setPostValue:userName forKey:@"userId"];
        [request setPostValue:[NSNumber numberWithInt:bookId] forKey:@"bookId"];
        
        
        
		[request setUserInfo:[NSDictionary dictionaryWithObject:object forKey:ASY_UpLoadRequestObjet_UseInfo]];  //设置详细信息
        if (requestType == 0) {
            // [queue addOperation:request];//加入队列，采用异步
            [request startAsynchronous];
        }else{
            
            [request startSynchronous]; //采用同步
        }
		
        
	}
}


-(NSString *)getIpUrl{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //creates paths so that you can pull the app's path from it
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"url1.plist"];
    NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:dataPath];
    NSString *urlStr=[NSString stringWithFormat:@"%@",[dTmp valueForKey:@"url1"]];
    return urlStr;
}
#pragma 下载方法
-(void)requestDownloadDataWithNewObject:(BooksInfo *)object delegate:(id)control
{
    
    NSString *selectUUIDSql1=[NSString stringWithFormat:Select_SuccessSql_UserInfoUUID];
    NSMutableArray *uuidarr1=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql1];
    if (uuidarr1.count<1) {
        [self showError:@"数据库出错"];
        return ;
    }
   // NSString *deviceid=@"ED7E578BE2F34AFCB20C7798D576E064";//
    NSString *deviceid=[[uuidarr1 objectAtIndex:0] objectForKey:@"UUID"];
    NSString *userId=[[uuidarr1 objectAtIndex:0] objectForKey:@"UserID"];
    
    //  NSLog(@"--------%@",object.urlStr);
    //  NSMutableString *path=(NSMutableString *)[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    //creates paths so that you can pull the app's path from it
    NSString *documentsDirectory = [path objectAtIndex:0];
    
    NSMutableString *savepath=(NSMutableString *)[documentsDirectory stringByAppendingPathComponent:@"DownLoad"];
    
    NSString *folderPath = [savepath stringByAppendingPathComponent:@"temp"];  //初始化临时文件路径
    NSFileManager *fileManager = [NSFileManager defaultManager];			//创建文件管理器
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
    if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //    BOOL fileExist = [fileManager fileExistsAtPath:object.groupPath];
    //    if (!fileExist) {//如果不存在说创建,因为下载时,不会自动创建文件夹
    //        [fileManager createDirectoryAtPath:object.groupPath withIntermediateDirectories:YES attributes:nil error:nil];
    //    }
    // NSString *urlStr=[object.urlStr stringByReplacingOccurrencesOfString:@":8001" withString:@""];
    NSString *urlStr=[NSString stringWithFormat:return_downBook_url,[self getIpUrl],object.bookID,userId,deviceid];
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    NSLog(@"====%@",urlStr);
    
    request.delegate=self;
    [request setDidFinishSelector:@selector(requestDownloadFinished:)];
    [request setDidFailSelector:@selector(requestDownloadFailed:)];
    [request setNumberOfTimesToRetryOnTimeout:2];				//设置请求超时时，设置重试的次数；
    [request setRequestMethod:@"GET"];
   
    NSString * savePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",object.bookName]];
    NSString * tempPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",object.bookName]];
    // NSLog(@"-=-=-=-=-=-=-lllll----%@\n%@",savePath,tempPath);
    //    object.savePath=[NSMutableString stringWithFormat:@"%@",savePath];
    //    object.tempPath=[NSMutableString stringWithFormat:@"%@",tempPath];
    //	NSLog(@"%@",object.savePath);
    [request setDownloadDestinationPath:savePath];
    [request setTemporaryFileDownloadPath:tempPath];
    [request setTimeOutSeconds:60];
    [request setAllowResumeForFileDownloads:YES];				//是否支持断点续传
    [request setShouldContinueWhenAppEntersBackground:YES];		//是否支持后台传输；
    [request setDownloadProgressDelegate:object.progressView];	//设置进度条代理
//    //[request setUploadProgressDelegate:object.progressView];
//    request.showAccurateProgress=YES;

//    request.downloadProgressDelegate=control;
    //[request setShowAccurateProgress:YES];						//高精度的进度追踪
    [request setUserInfo:[NSDictionary dictionaryWithObject:object forKey:ASY_RequestObjet_UseInfo]];  //设置详细信息
    
   // [request startAsynchronous];
    [queue addOperation:request];//请求添加到队列
   // queue.downloadProgressDelegate=object.progressView;
   // [queue setDownloadProgressDelegate:control];
    //queue.downloadProgressDelegate=control;
   // [queue setShowAccurateProgress:YES];
   // queue.showAccurateProgress=YES;
   
}

-(void)SetProgress:(id)progress
{
    [queue setDownloadProgressDelegate:progress];
    

}

//-(void)requestFinished:(ASIFormDataRequest *)request
//{
//     NSLog(@"RequestFinist1----------:%d\n%@",[request responseStatusCode],[request responseString]);
//
//     id jsonObjects = [[request responseString] JSONValue];
//    NSLog(@"----------sbjson--------:\n%@",jsonObjects);
//}
//-(void)requestFailed:(ASIFormDataRequest *)request
//{
//     NSLog(@"RequestFailed2----------:%@\n%@\n\n\n\n%d\n",[request responseData],[request responseString],[request responseStatusCode]);
//
//}
- (void) dimissAlert:(UIAlertView *)alert
{
    if(alert)
    {
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex]animated:YES];
        
    }
}
- (void)showError:(NSString*)message
{
	UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:message
												  delegate:self
										 cancelButtonTitle:nil
										 otherButtonTitles:nil];
	[alert show];
    [self performSelector:@selector(dimissAlert:) withObject:alert afterDelay:0.8];
    
}
-(void)requestDownloadFinished:(ASIHTTPRequest *)request
{
    NSLog(@"RequestFinist----------:%@/n%@",[request responseData],[request responseString]);
    NSLog(@"----下载成功-%d",[request responseStatusCode]);
    if ([request responseStatusCode]==200) {
        BooksInfo *bk=[request.userInfo objectForKey:ASY_RequestObjet_UseInfo];
        if ([self.downLoadAll isEqualToString:@"isAll"]) {
            if (queue.requestsCount==1) {
                [self showError:@"书籍全部下载完成！"];
                self.downLoadAll=@"noAll";
                
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ASY_RequestFinishObsever_Info object:self userInfo:nil];
            NSString *insertBookInfoSql=[NSString stringWithFormat:isDownload_sql_Book,bk.bookID];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertBookInfoSql];
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ASY_RequestFinishObsever_Info object:self userInfo:nil];
        [self showError:[NSString stringWithFormat:@"%@下载成功",bk.bookName]];
        NSString *insertBookInfoSql=[NSString stringWithFormat:isDownload_sql_Book,bk.bookID];
        [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertBookInfoSql];
        [bk.progressView removeFromSuperview];
        
    }else{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString * ePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //  NSString * doc=[ePath stringByAppendingPathComponent:@"fileTemp"];
        BooksInfo *bk=[request.userInfo objectForKey:ASY_RequestObjet_UseInfo];
        
        NSString * bookPath =[ePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",bk.bookName]];
        [fileManager removeItemAtPath:bookPath error:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:ASY_RequestFailedObsever_Info object:self userInfo:bk];
        [self showError:[NSString stringWithFormat:@"%@下载失败",bk.bookName]];
        
    }
}
-(void)requestDownloadFailed:(ASIHTTPRequest *)request
{
    //[self showError:@"下载失败"];
    BooksInfo *bk=[request.userInfo objectForKey:ASY_RequestObjet_UseInfo];
    NSLog(@"------failed:%@,\n%@\n%d",[request error],[request responseString],[request responseStatusCode]);
    [[NSNotificationCenter defaultCenter] postNotificationName:ASY_RequestFailedObsever_Info object:self userInfo:bk];

}

-(BOOL)testNetWorkConnectionWithUrlString:(NSString *)urlStr
{
    
    Reachability * r=[Reachability reachabilityWithHostName:urlStr];
    if ([r currentReachabilityStatus]==0)
    {
        NSLog(@"-----无网络连接");
        
        return NO;
    }
    else {
        NSLog(@"------有网络连接");
        return YES;
        
    }
}

-(void)StopQueue
{
    [queue cancelAllOperations];
}
@end
