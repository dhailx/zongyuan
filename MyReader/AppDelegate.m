//
//  AppDelegate.m
//  MyReader
//
//  Created by YDJ on 13-5-26.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import "AppDelegate.h"
#import "PublicClassHeader.h"
#import "LibraryListViewController.h"
#import "SaffronClientSQLManager.h"
#import "DBItem.h"
#import "CoverFlowViewController.h"
#import "RevealController.h"
#import "AsyRequestServer.h"
#import "BooksInfo.h"
#import "SBJson.h"
#import "MBProgressHUD.h"
#import "SBJson.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


-(NSString*)uuidString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString* uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    
    // transfer ownership of the string
    // to the autorelease pool
    
    // release the UUID
    CFRelease(uuid);
    
    return [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (void)showError:(NSString*)message
{
	UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:message
												  delegate:self
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil];
	[alert show];
}
-(void)initCoverView{
    
    CoverFlowViewController * coverFlow=[[CoverFlowViewController alloc] init];
    UINavigationController * navCover=[[UINavigationController alloc] initWithRootViewController:coverFlow];
   // [navCover.navigationBar setBackgroundImage:[UIImage imageNamed:@"navtitle.png"] forBarMetrics:UIBarMetricsDefault];
     if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)     {
        [navCover.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
    }else
        [navCover.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
    if (ipTF.text) {
        coverFlow.IPstr=ipTF.text;
    }
     self.window.rootViewController=navCover;

}

-(void)addHomeSubViews
{
    
    NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * documentDirectory=[paths objectAtIndex:0];
    NSString *localPath = [documentDirectory stringByAppendingPathComponent:@"url.plist"];
    NSDictionary *urlDataDic=[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"http://%@:8001/pdfpath/",ipTF.text] forKey:@"url"];
    NSString *localPath1 = [documentDirectory stringByAppendingPathComponent:@"url1.plist"];
    NSDictionary *urlDataDic1=[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",ipTF.text] forKey:@"url1"];
    [urlDataDic writeToFile:localPath atomically:YES];
    [urlDataDic1 writeToFile:localPath1 atomically:YES];
    {
    //    NSString *selectUUIDSql=[NSString stringWithFormat:Select_sql_UserInfoUUID];
     //   NSMutableArray *uuidarr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql];
      //  if ([uuidarr count]<1) {
      //     uuidstr=[self uuidString]; //创建唯一标示符；
            NSLog(@"====1111==%@,%@",uuidstr,userNameTF.text);
            NSString *insertSql=[NSString stringWithFormat:Insert_sql_UserInfo,userNameTF.text,uuidstr,@"YES"];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertSql];
    //    }
      
        [self initCoverView];

        NSLog(@"%@",[[NSBundle mainBundle] resourcePath]);
    }
}
-(void)requestFinished:(ASIFormDataRequest *)request
{
    
     NSLog(@"RequestFinist1----------:%d\n%@\n%@",[request responseStatusCode],[request error],[request responseString]);
    if ([postToken isEqualToString:@"post"]) {
        
        [self addHomeSubViews];
        [landingView removeFromSuperview];
        return ;
    }
    NSString *str=[[[request responseString] JSONValue]  objectForKey:@"status"];
    NSLog(@"----%@",str);
    if ([request responseStatusCode] ==200) {
        if ([str isEqualToString:@"success"]) {
            [self postTokenRequest];
            
            
        }else{
            [self juhuaStop];
            [self showError:@"用户名或密码错误"];
        }

    }
   }
-(void)requestFailed:(ASIFormDataRequest *)request
{
    [self juhuaStop];
     NSLog(@"RequestFailed2----------:%@\n%@\n\n\n\n%d\n",[request responseData],[request responseString],[request responseStatusCode]);
    
    [self showError:@"请求失败,请检查IP地址是否正确"];
    
}

-(void)juhuaStop{
    
 [MBProgressHUD hideHUDForView:self.window  animated:YES];
}
-(void)postTokenRequest{
    postToken=@"post";
    BooksInfo *bookinfo=[[BooksInfo alloc] init];
    bookinfo.userName=userNameTF.text;
    bookinfo.UUID=uuidstr;
    bookinfo.postToken=tokenString;
    bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:postToken_request_url,ipTF.text];
    NSLog(@"-----%@,%@",uuidstr,bookinfo.userName);
    AsyRequestServer *asylanding=[AsyRequestServer getInstance];
    asylanding.tokenStr=@"postToken";
//        MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
//        mbp.labelText = @"登陆中,请等待...";
        [asylanding requestFormDataWithNewObject:bookinfo fromeDelegate:(UIViewController *)self];
    
    
}
-(void)landing
{
    [userNameTF resignFirstResponder];

    if (![userNameTF.text isEqualToString:@""] && userNameTF.text!=nil &&![psdTF.text isEqualToString:@""]&& psdTF.text!=nil && ![ipTF.text isEqualToString:@""] && ipTF.text!=nil) {
        uuidstr=[self uuidString];
        BooksInfo *bookinfo=[[BooksInfo alloc] init];
        bookinfo.userName=userNameTF.text;
        bookinfo.password=psdTF.text;
        bookinfo.UUID=uuidstr;

       // bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:@"http://192.168.1.212:8080/zongyuan/login/client"];//http://192.168.1.242/ValidateUserInfo.ashx
        bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:login_request_url,ipTF.text];
        NSLog(@"-----%@,%@",uuidstr,bookinfo.urlStr);
        AsyRequestServer *asylanding=[AsyRequestServer getInstance];
        asylanding.logType=@"login";

        if ([asylanding testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
            MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
            mbp.labelText = @"登陆中,请等待...";
            [asylanding requestFormDataWithNewObject:bookinfo fromeDelegate:(UIViewController *)self];

        }else{

            [self showError:@"请检查网络链接"];
        }
    }else{
        [self showError:@"请输入用户名、密码、IP地址"];
    }
 

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
//[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
    UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    //判断程序是不是由推送服务完成的
    //看是否有push notification到达，并做相应处理，这个方法和local notification相同，但注意key要对应就行
    UILocalNotification * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        //弹出一个alertview,显示相应信息
        UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"receive remote notification!" message:@"hello" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [al show];
//        [al release];
    }
 //   [self updateItunesData];

        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
        [SaffronClientSQLManager getInstance];
    
  
    NSString *selectUUIDSql1=[NSString stringWithFormat:Select_SuccessSql_UserInfoUUID];
    NSMutableArray *uuidarr1=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql1];
    if (uuidarr1.count>0) {
        NSString *selectUUIDSql2=[NSString stringWithFormat:@"select * from 'BookInfo' where BookMark = 'NO' or BookNote = 'NO'"];
        NSMutableArray *uuidarr2=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql2];
        if (uuidarr2.count<=0) {
            NSString *selectUUIDSql3=[NSString stringWithFormat:@"alter table Bookinfo add BookMark BOOL"];
            
            [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql3];
            NSString *selectUUIDSql4=[NSString stringWithFormat:@"alter table Bookinfo add BookNote BOOL"];
            
            [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql4];
            [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:@"update 'BookInfo' set 'BookNote' = 'NO'"];
            [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:@"update 'BookInfo' set 'BookMark' = 'NO'"];
            [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:@"update 'BookInfo' set 'BookCover' = 'NO' where BookCover IS NULL"];
            
        }
        [self initCoverView];
    }else{
        NSString *selectUUIDSql3=[NSString stringWithFormat:@"alter table Bookinfo add BookMark BOOL"];
        
        [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql3];
        NSString *selectUUIDSql4=[NSString stringWithFormat:@"alter table Bookinfo add BookNote BOOL"];
        
        [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql4];

        [self showIntroWithCrossDissolve];
//        landingView=[[UIView alloc] initWithFrame:self.window.bounds];
//        [landingView  setBackgroundColor:[UIColor grayColor]];
//        [self.window addSubview:landingView];
//        
//        UIImageView *selfbgimageview=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landingbg.png"]];
//        [selfbgimageview setFrame:landingView.frame];
//        [landingView addSubview:selfbgimageview];
//        
//        UIImageView*logimage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landtitle.png"]];
//        [logimage setFrame:CGRectMake(160+40, 250, 320, 50)];
//        [selfbgimageview addSubview:logimage];
//        
//        UIImageView*landingxian=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landingxian.png"]];
//        [landingxian setFrame:CGRectMake(160+40, 310, 360, 2)];
//        [selfbgimageview addSubview:landingxian];
//        
//        UIImageView*userNameimage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userName.png"]];
//        [userNameimage setFrame:CGRectMake(180+40, 340, 320, 40)];
//        [landingView addSubview:userNameimage];
//        
//        UIImageView*pwdimage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password.png"]];
//        [pwdimage setFrame:CGRectMake(180+40, 397, 320, 40)];
//        [landingView addSubview:pwdimage];
//        
//        UIImageView*ipimage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ip.png"]];
//        [ipimage setFrame:CGRectMake(180+40, 454, 320, 40)];
//        [landingView addSubview:ipimage];
//        
//        UILabel *exlab=[[UILabel alloc] initWithFrame:CGRectMake(220, 495, 320, 30)];
//        [exlab setText:@"IP格式例如:192.168.1.1"];
//        [exlab setBackgroundColor:[UIColor clearColor]];
//        [selfbgimageview addSubview:exlab];
//        
//        UIButton *landingBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [landingBtn setFrame:CGRectMake(330, 540, 60, 40)];
//        [landingBtn setBackgroundImage:[UIImage imageNamed:@"landing"] forState:UIControlStateNormal];
//        [landingBtn setBackgroundImage:[UIImage imageNamed:@"selectlanding.png"] forState:UIControlStateHighlighted];
//        [landingBtn addTarget:self action:@selector(landing) forControlEvents:UIControlEventTouchUpInside];
//        [landingView addSubview:landingBtn];
//        
//        userNameTF=[[UITextField alloc] initWithFrame:CGRectMake(200+80, userNameimage.frame.origin.y+4, userNameimage.frame.size.width-55, 32)];
//        [userNameTF setBackgroundColor:[UIColor clearColor]];
//        [userNameTF setFont:[UIFont systemFontOfSize:20]];
//        userNameTF.clearButtonMode = UITextFieldViewModeAlways;
//        userNameTF.delegate=self;
//        [landingView addSubview:userNameTF];
//        [userNameTF bringSubviewToFront:landingView];
//        
//        
//        
//        psdTF=[[UITextField alloc] initWithFrame:CGRectMake(200+80, pwdimage.frame.origin.y+4, pwdimage.frame.size.width-55, 32)];
//        [psdTF setBackgroundColor:[UIColor clearColor]];
//        [psdTF setFont:[UIFont systemFontOfSize:20]];
//        psdTF.clearButtonMode = UITextFieldViewModeAlways;
//        [psdTF setSecureTextEntry:YES]; //设置密码为密文格式
//        psdTF.delegate=self;
//        [landingView addSubview:psdTF];
//        
//        ipTF=[[UITextField alloc] initWithFrame:CGRectMake(200+80, ipimage.frame.origin.y+4, ipimage.frame.size.width-55, 32)];
//        [ipTF setBackgroundColor:[UIColor clearColor]];
//        [ipTF setFont:[UIFont systemFontOfSize:20]];
//        ipTF.clearButtonMode = UITextFieldViewModeAlways;
//        ipTF.delegate=self;
//        ipTF.text=@"220.231.22.49";
//        [landingView addSubview:ipTF];

    }
  //  [self initCoverView];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
   // page1.title = @"Hello world";
    //page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    page1.bgImage = [UIImage imageNamed:@"2s"];
   // page1.titleImage = [UIImage imageNamed:@"original"];
    
    EAIntroPage *page2 = [EAIntroPage page];
   // page2.title = @"This is page 2";
   // page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
    page2.bgImage = [UIImage imageNamed:@"4s"];
   // page2.titleImage = [UIImage imageNamed:@"supportcat"];
    
    EAIntroPage *page3 = [EAIntroPage page];
   // page3.title = @"This is page 3";
   // page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
    page3.bgImage = [UIImage imageNamed:@"3s"];
   // page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
    
    EAIntroPage *page4 = [EAIntroPage page];
  
    page4.bgImage = [UIImage imageNamed:@"1s"];
    
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.window.bounds andPages:@[page1,page2,page3,page4]];
    
    [intro setDelegate:self];
    [intro showInView:self.window animateDuration:0.0];
}
- (void)introDidFinish {
    landingView=[[UIView alloc] initWithFrame:self.window.bounds];
    [landingView  setBackgroundColor:[UIColor grayColor]];
    [self.window addSubview:landingView];
    
    UIImageView *selfbgimageview=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landingbg.png"]];
    [selfbgimageview setFrame:landingView.frame];
    [landingView addSubview:selfbgimageview];
    
    UIImageView*logimage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landtitle.png"]];
    [logimage setFrame:CGRectMake(160+40, 250, 320, 50)];
    [selfbgimageview addSubview:logimage];
    
    UIImageView*landingxian=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landingxian.png"]];
    [landingxian setFrame:CGRectMake(160+40, 310, 360, 2)];
    [selfbgimageview addSubview:landingxian];
    
    UIImageView*userNameimage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userName.png"]];
    [userNameimage setFrame:CGRectMake(180+40, 340, 320, 40)];
    [landingView addSubview:userNameimage];
    
    UIImageView*pwdimage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password.png"]];
    [pwdimage setFrame:CGRectMake(180+40, 397, 320, 40)];
    [landingView addSubview:pwdimage];
    
    UIImageView*ipimage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ip.png"]];
    [ipimage setFrame:CGRectMake(180+40, 454, 320, 40)];
    [landingView addSubview:ipimage];
    
    UILabel *exlab=[[UILabel alloc] initWithFrame:CGRectMake(220, 495, 320, 30)];
    [exlab setText:@"IP格式例如:192.168.1.1"];
    [exlab setBackgroundColor:[UIColor clearColor]];
    [selfbgimageview addSubview:exlab];
    
    UIButton *landingBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [landingBtn setFrame:CGRectMake(330, 540, 60, 40)];
    [landingBtn setBackgroundImage:[UIImage imageNamed:@"landing"] forState:UIControlStateNormal];
    [landingBtn setBackgroundImage:[UIImage imageNamed:@"selectlanding.png"] forState:UIControlStateHighlighted];
    [landingBtn addTarget:self action:@selector(landing) forControlEvents:UIControlEventTouchUpInside];
    [landingView addSubview:landingBtn];
    
    userNameTF=[[UITextField alloc] initWithFrame:CGRectMake(200+80, userNameimage.frame.origin.y+4, userNameimage.frame.size.width-55, 32)];
    [userNameTF setBackgroundColor:[UIColor clearColor]];
    [userNameTF setFont:[UIFont systemFontOfSize:20]];
    userNameTF.clearButtonMode = UITextFieldViewModeAlways;
    userNameTF.delegate=self;
    [landingView addSubview:userNameTF];
    [userNameTF bringSubviewToFront:landingView];
    
    
    
    psdTF=[[UITextField alloc] initWithFrame:CGRectMake(200+80, pwdimage.frame.origin.y+4, pwdimage.frame.size.width-55, 32)];
    [psdTF setBackgroundColor:[UIColor clearColor]];
    [psdTF setFont:[UIFont systemFontOfSize:20]];
    psdTF.clearButtonMode = UITextFieldViewModeAlways;
    [psdTF setSecureTextEntry:YES]; //设置密码为密文格式
    psdTF.delegate=self;
    [landingView addSubview:psdTF];
    
    ipTF=[[UITextField alloc] initWithFrame:CGRectMake(200+80, ipimage.frame.origin.y+4, ipimage.frame.size.width-55, 32)];
    [ipTF setBackgroundColor:[UIColor clearColor]];
    [ipTF setFont:[UIFont systemFontOfSize:20]];
    ipTF.clearButtonMode = UITextFieldViewModeAlways;
    ipTF.delegate=self;
    ipTF.text=@"zsk.giwp.org.cn";
    [landingView addSubview:ipTF];
    
    
  //      CGRect frame1 = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    UIFont *font1 = [UIFont boldSystemFontOfSize:30.0];
        TipLabel=[[UILabel alloc]initWithFrame:CGRectMake(130, 640, 500, 100)];
        [TipLabel setTextColor:[UIColor whiteColor]];
        [landingView addSubview:TipLabel];
        TipLabel.adjustsFontSizeToFitWidth = YES;
        TipLabel.numberOfLines=0;
        TipLabel.minimumFontSize = 8.0f;
        TipLabel.font=font1;
        TipLabel.text=@"欢迎登录水利部水利水电规划设计总院知识信息支撑平台1.6版,平台目前收录技术标准、审查文件、工程设计报告、重要规划、水利法规、水利图书、水利期刊、规划图鉴3000余册，为保证信息的及时准确，相关内容将不断更新。敬请持续关注。";
    
    
    UIFont *font2 = [UIFont boldSystemFontOfSize:40.0];
    UILabel * TipLabel1=[[UILabel alloc]initWithFrame:CGRectMake(130, 740, 500, 100)];
    [TipLabel1 setTextColor:[UIColor whiteColor]];
    [landingView addSubview:TipLabel1];
    TipLabel1.adjustsFontSizeToFitWidth = YES;
    TipLabel1.numberOfLines=0;
    TipLabel1.minimumFontSize = 8.0f;
    TipLabel1.font=font2;
    TipLabel1.text=@"资料仅限内部使用";
    TipLabel1.textAlignment = UITextAlignmentCenter;
    
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
//    
    
   // [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    NSString *dPdf =[NSString stringWithFormat:@"%@/Library/Caches/fileTemp",NSHomeDirectory()];
    NSFileManager *fileManage=[NSFileManager defaultManager];
    [fileManage removeItemAtPath:dPdf error:nil];
    NSLog(@"///////////---%@----%d",dPdf,[fileManage removeItemAtPath:dPdf error:nil]);
    [self saveContext];
    NSLog(@"tuichu----");
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyReader" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MyReader.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo

{
    NSLog(@"\napns -> didReceiveRemoteNotification,Receive Data:\n%@", userInfo);
    //把icon上的标记数字设置为0,
    application.applicationIconBadgeNumber = 0;
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"推送通知"
                                                        message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil,nil];
//        alert.tag = alert_tag_push;f
        [alert show];
    }
}
//applicationdidRegisterForRemoteNotificationsWithDeviceToken
-(void )application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"deviceToken"];
    [userDefaults setObject:deviceToken forKey:@"deviceToken"];
    NSLog(@"My token is: %@", [userDefaults objectForKey:@"deviceToken"]);
    tokenString=[NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"deviceToken"]];

}
//- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults removeObjectForKey:@"deviceToken"];
//    [userDefaults setObject:deviceToken forKey:@"deviceToken"];
//    NSLog(@"My token is: %@", [userDefaults objectForKey:@"deviceToken"]);
//}
                                         
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"Failed to get token, error:%@", error_str);
}
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
