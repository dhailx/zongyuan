//
//  CoverFlowViewController.m
//  MyReader
//
//  Created by YDJ on 13-6-1.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import "CoverFlowViewController.h"
#import "PublicClassHeader.h"
#import "LibraryListViewController.h"
#import "SaffronClientSQLManager.h"
#import "RootViewController.h"
#import "BookSearchViewController.h"
#import "AsyRequestServer.h"
#import "MBProgressHUD.h"
#import "RegexKitLite.h"
#import "SBJson.h"
#import "BooksInfo.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "Decrypt.h"
#import "helpViewController.h"
#import "ImgViewController.h"
//@interface CoverFlowViewController ()<iCarouselDataSource, iCarouselDelegate>
//@property (retain, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;
//@property (nonatomic, retain) iCarousel *carousel;
//@property (nonatomic, retain)NSMutableArray * items;
//@end

@implementation CoverFlowViewController
@synthesize objectJson,IPstr;
@synthesize allDownloadBtn,myBookBtn,hmSettingBtn,NavBg,NavList,UserLabel,mbpload,nall,nFailed,nSucess,loadingAlertView,TipsLabel,LabelView,TipLabel,HelpBtn,MarkBtn;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *)selectBookCategory{
    
    NSString *selectSql=[NSString stringWithFormat:Select_sql_BookCategoryName,1];
	NSMutableArray *sqlArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];
    NSLog(@"----%@",sqlArr);
    return sqlArr;
}

- (void)showUploadMessage:(NSString*)message
{
	UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:message
												  delegate:self
                                         cancelButtonTitle:@"否"
                                         otherButtonTitles:@"是", nil];
	[alert show];
}

-(NSString *)saveUrlStr{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //creates paths so that you can pull the app's path from it
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"url1.plist"];
    NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:dataPath];
    NSString *urlStr=[NSString stringWithFormat:@"%@",[dTmp valueForKey:@"url1"]];
    NSLog(@"保存的url%@",urlStr);
    return urlStr;
}

-(void)doDownloadBooks{
    
    //self.navigationController.navigationBar.userInteractionEnabled = NO;
    
    AsyRequestServer *asyRequest=[AsyRequestServer getInstance];
    if ([asyRequest testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
        asyRequest.downLoadAll=@"isAll";
        //  MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // mbp.labelText = @"加载数据中,请稍后...";
        NSString *selectSql=[NSString stringWithFormat:Select_sql_AllBookId];
        NSMutableArray *sqlArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];
        NSLog(@"%lu",(unsigned long)sqlArr.count);
        if (sqlArr.count==0) {
            [asyRequest showError:@"所有书籍都已下载！"];
        }else
        {
//            UIView *viewc=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, (self.view.frame.size.height-100)/2, self.view.frame.size.width/2, 60)];
//            [viewc setBackgroundColor:[UIColor blackColor]];
//            CALayer *l = [viewc layer];   //获取ImageView的层
//            [l setMasksToBounds:YES];
//            [l setCornerRadius:6.0];
//            UIProgressView *pro=[[UIProgressView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/12, 27, self.view.frame.size.width/3, 10)];
//           
//            [pro setProgressViewStyle:UIProgressViewStyleDefault];
//            pro.transform = CGAffineTransformMakeScale(1.0f,5.0f);
//            [viewc addSubview:pro];
//            [self.view addSubview:viewc];
//            [asyRequest SetProgress:pro];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SuccessProgressView) name:ASY_RequestFinishObsever_Info object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FailedProgressView) name:ASY_RequestFailedObsever_Info object:nil];
            nall=sqlArr.count;
            nSucess=0;
            nFailed=0;
      //     mbpload = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
      //      mbpload.labelText =[NSString stringWithFormat:@"共下载数据%d本，已下载0本，成功0本，失败0本",sqlArr.count] ;
            
            
            
            
            NSString *strtip=[NSString stringWithFormat:@"共下载数据%d本，已下载0本，成功0本，失败0本",sqlArr.count];
            
          //  loadingAlertView = [[UIAlertView alloc]
//                                             initWithTitle:nil message:strtip
//                                             delegate:nil cancelButtonTitle:nil
//                                             otherButtonTitles: nil];
           
           
            //[loadingAlertView addSubview:progressInd];
          //  [loadingAlertView show];
            
            UIButton *cancelbtn=[[UIButton alloc]initWithFrame:CGRectMake(110, 60, 80, 30)];
            [cancelbtn setTitle:@"取消" forState:UIControlStateNormal];
            [cancelbtn setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
            [cancelbtn setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
            [cancelbtn addTarget:self action:@selector(CancelProgressView:) forControlEvents:UIControlEventTouchUpInside];
            
            
            loadingAlertView=[[UIView alloc]initWithFrame:self.view.frame];
            loadingAlertView.backgroundColor=[UIColor blackColor];
            loadingAlertView.alpha=0.5;
            
            LabelView=[[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-300)/2, (self.view.frame.size.height)/2, 300, 90)];
            LabelView.backgroundColor=[UIColor whiteColor];
            LabelView.alpha=0.8;
            
            LabelView.layer.masksToBounds = YES;
            
            LabelView.layer.cornerRadius = 8.0;
            
            //view.layer.borderWidth = 1;
            
           // view.layer.borderColor = [[UIColor whiteColor] CGColor];
            
            TipsLabel =[[UILabel alloc]initWithFrame:CGRectMake(50, 0, 200, 60)];
            TipsLabel.textColor=[UIColor blackColor];
            TipsLabel.alpha=0.9;
            TipsLabel.backgroundColor=[UIColor clearColor];
            TipsLabel.textAlignment=NSTextAlignmentCenter;
            TipsLabel.numberOfLines=0;
            
            TipsLabel.font=[UIFont systemFontOfSize:15];
            
            TipsLabel.backgroundColor=[UIColor clearColor];
            TipsLabel.text=strtip;
            
            [LabelView addSubview:cancelbtn];
             CGRect frame = CGRectMake((self.view.frame.size.width-300)/2, (self.view.frame.size.height-200)/2, 300, 100);
             UIActivityIndicatorView* progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
            [progressInd startAnimating];
            progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [LabelView addSubview: TipsLabel];
            [loadingAlertView addSubview:progressInd];
            //[loadingAlertView addSubview:view];
            [self.view addSubview:loadingAlertView];
            [self.view addSubview:LabelView];
            for (int i=0; i<sqlArr.count; i++) {
            BooksInfo * bookinfo=[[BooksInfo alloc] init];
            bookinfo.bookID=[[[sqlArr objectAtIndex:i] objectForKey:@"BookID"] intValue];
            bookinfo.bookName=[[sqlArr objectAtIndex:i] objectForKey:@"BooKName"];
                

             [asyRequest requestDownloadDataWithNewObject:bookinfo delegate:self];
            }
            
        }
                
    }else{
        [asyRequest showError:@"请检查网络链接"];
    }
    
}

-(void)CancelProgressView:(UIButton *)button
{
     AsyRequestServer *asyRequest=[AsyRequestServer getInstance];
    [asyRequest StopQueue];
    [LabelView removeFromSuperview];
    [loadingAlertView removeFromSuperview];

}
-(void)SuccessProgressView
{
    nSucess++;
     TipsLabel.text =[NSString stringWithFormat:@"共下载数据%d本，已下载%d本，成功%d本，失败%d本",nall,nSucess+nFailed,nSucess,nFailed] ;
    
    if (nall==(nSucess+nFailed)) {
        [LabelView removeFromSuperview];
        [loadingAlertView removeFromSuperview];
    }
    
}
-(void)FailedProgressView
{
    nFailed++;
      TipsLabel.text =[NSString stringWithFormat:@"共下载数据%d本，已下载%d本，成功%d本，失败%d本",nall,nSucess+nFailed,nSucess,nFailed] ;
    if (nall==(nSucess+nFailed)) {
        [LabelView removeFromSuperview];
        [loadingAlertView removeFromSuperview];
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==200) {
        if (buttonIndex == 1)
        {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
        }
        return;
    }
    
    if (alertView.tag==120) {
        if (buttonIndex==1) {
            [self doDownloadBooks];
        }
        return ;
    }
    switch (buttonIndex) {
        case 0:
            NSLog(@"取消了就行了");
            [self popoverControllerDidDismissPopover:settingPop];
            break;
        case 1:
        {
            self.navigationController.navigationBar.userInteractionEnabled = NO;
            //            MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //            mbp.labelText = @"同步数据，请稍后...";
            
            AsyRequestServer *asyRequest=[AsyRequestServer getInstance];
            if ([asyRequest testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
                MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                mbp.labelText = @"加载数据中,请稍后...";
                BooksInfo * bookinfo=[[BooksInfo alloc] init];
                if (![[self saveUrlStr]isEqualToString:@""]) {
                    bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:CategoryString_IP_Url,[self saveUrlStr]];
                    NSLog(@"--------ipStr----%@",IPstr);
                    //  asyRequest.requestType = 1;
                    [asyRequest requestFormDataWithNewObject:bookinfo fromeDelegate:(UIViewController *)self];
                    
                }
            }else{
                [asyRequest showError:@"请检查网络链接"];
            }
            
        }
            break;
        default:
            break;
    }
}

- (void)showError:(NSString*)message
{
	UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:message
												  delegate:self
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil];
	[alert show];
}
-(void)Resize
{
    UIInterfaceOrientation to=self.interfaceOrientation;
    if(to == UIDeviceOrientationLandscapeLeft || to == UIDeviceOrientationLandscapeRight)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
        [bgImageView setFrame:self.view.frame];
        [bgImageView setImage:[UIImage imageNamed:@"bg_h.png"]];
        
        //NavBg.frame=CGRectMake(0, 44, self.view.bounds.size.width, 50);
        
        
        [serarchBar setFrame:CGRectMake(400, 1, 250, 40)];
        [myBookBtn setFrame:CGRectMake(800-80, 7, 25, 25)];
        [allDownloadBtn setFrame:CGRectMake(850-47, 2, 30, 35)];
        [hmSettingBtn setFrame:CGRectMake(900, 7, 25, 25)];
        
        [biaozhunBtn setFrame:CGRectMake(130, 158-70-14, 380, 171)];
        
        //审查审批文件
        [scyjBtn setFrame:CGRectMake(400-21+140, 158-70-14, 380, 171)];
        [scBtn setFrame:CGRectMake(130, 350-80-24, 380, 171)];
        
        //重要规划报告
        [ghBtn setFrame:CGRectMake(400-21+140, 350-80-24, 382, 171)];
        
        //管理制度文件
        [gzBtn setFrame:CGRectMake(130, 551-93-34, 380, 171)];
        
        //常用数据资料
        [qkBtn setFrame:CGRectMake(400-21+140, 551-93-34, 382, 171)];
        
        //规划设计图件
        [ghtBtn setFrame:CGRectMake(130, 750-120-44, 382, 171)];
        
        [OaBtn setFrame:CGRectMake(400-21+140, 750-120-44, 382, 171)];
        
        [HelpBtn setFrame:CGRectMake(400-21+140+400, 750-100+44, 80, 40)];
        
    }else if (to==UIDeviceOrientationPortrait || to ==UIDeviceOrientationPortraitUpsideDown){
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
        [bgImageView setImage:[UIImage imageNamed:@"newbg.png"]];
        [serarchBar setFrame:CGRectMake(340, 1, 250, 40)];
        [allDownloadBtn setFrame:CGRectMake(650, 2, 30, 35)];
        [bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
        [myBookBtn setFrame:CGRectMake(600, 7, 25, 25)];
        [hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
        [biaozhunBtn setFrame:CGRectMake(4, 158, 380, 171)];
        [scyjBtn setFrame:CGRectMake(400-21, 158, 380, 171)];
        [scBtn setFrame:CGRectMake(4, 350, 380, 171)];
        [ghBtn setFrame:CGRectMake(400-21, 350, 382, 171)];
        [gzBtn setFrame:CGRectMake(4, 551, 380, 171)];
        [qkBtn setFrame:CGRectMake(400-21, 551, 382, 171)];
        [ghtBtn setFrame:CGRectMake(4, 750, 382, 171)];
        [OaBtn setFrame:CGRectMake(400-21, 750, 382, 171)];
        [HelpBtn setFrame:CGRectMake(630, 950, 80, 40)];
        //NavBg.frame=CGRectMake(0, 44, self.view.bounds.size.width, 50);
    }

}

-(void)addButton{

     NSLog(@"%f-----%f",self.view.bounds.size.height,self.view.bounds.origin.y);
    NSInteger yy=0;
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)     {
        yy=44;
    }
    NavBg=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    NavBg.backgroundColor=[UIColor clearColor];
    NavBg.alpha=0.7;
   // NavBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  //  NavList=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, (self.view.frame.size.width-190), 50)];
   // [NavList setTextColor:[UIColor whiteColor]];
   // [NavBg addSubview:NavList];
    [self.view addSubview:NavBg];
    NavBg.frame=CGRectMake(0, 44-yy, self.view.bounds.size.width, 50);
  //  UIFont *font = [UIFont boldSystemFontOfSize:28.0];
  //  NavList.font = font;
  //  NavList.adjustsFontSizeToFitWidth = YES;
  //  NavList.minimumFontSize = 8.0f;
   // NavList.text=@"首页 >";
    
     UIFont *font1 = [UIFont boldSystemFontOfSize:20.0];
    
//    CGRect frame1 = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
//    
//    TipLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 64-yy, frame1.size.width-100, 100)];
//    [TipLabel setTextColor:[UIColor whiteColor]];
//    [self.view addSubview:TipLabel];
//    TipLabel.adjustsFontSizeToFitWidth = YES;
//    TipLabel.numberOfLines=0;
//    TipLabel.minimumFontSize = 8.0f;
//    TipLabel.font=font1;
//    TipLabel.text=@"欢迎登录水利部水利水电规划设计总院知识信息支撑平台1.6版,平台目前收录技术标准、审查文件、工程设计报告、重要规划、水利法规、水利图书、水利期刊、规划图鉴3000余册，为保证信息的及时准确，相关内容将不断更新。敬请持续关注。";
    
    
    
    UserLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-150, 0, 150, 50)];
    [UserLabel setTextColor:[UIColor whiteColor]];
    [NavBg addSubview:UserLabel];
    UserLabel.adjustsFontSizeToFitWidth = YES;
    UserLabel.minimumFontSize = 8.0f;
   
    UserLabel.font = font1;
    NSString *selectSql=[NSString stringWithFormat:Select_sql_UserInfo];
	NSMutableArray *uuidArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];

    if (uuidArr.count>0) {
        UserLabel.text=[NSString stringWithFormat:@"用户：%@",[[uuidArr objectAtIndex:0] objectForKey:@"UserID"]];
    }

    UserLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    //相关技术标准
    biaozhunBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [biaozhunBtn setFrame:CGRectMake(4, 158-yy, 380, 171)];
    [biaozhunBtn addTarget:self action:@selector(openBookShelf:) forControlEvents:UIControlEventTouchUpInside];
    [biaozhunBtn setBackgroundImage:[UIImage imageNamed:@"js11.png"] forState:UIControlStateNormal];
    biaozhunBtn.tag=6;
    [self.view addSubview:biaozhunBtn];
    
    //审查审批文件
    scyjBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [scyjBtn setFrame:CGRectMake(400-21, 158-yy, 380, 171)];
    [scyjBtn addTarget:self action:@selector(openBookShelf:) forControlEvents:UIControlEventTouchUpInside];
    [scyjBtn setBackgroundImage:[UIImage imageNamed:@"scyj2.png"] forState:UIControlStateNormal];
    scyjBtn.tag=0;
    [self.view addSubview:scyjBtn];
    
    //工程设计报告
    scBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [scBtn setFrame:CGRectMake(4, 350-yy, 380, 171)];
    [scBtn addTarget:self action:@selector(openBookShelf:) forControlEvents:UIControlEventTouchUpInside];
    [scBtn setBackgroundImage:[UIImage imageNamed:@"sc3.png"] forState:UIControlStateNormal];
    scBtn.tag=1;
    [self.view addSubview:scBtn];
    
    //重要规划报告
    ghBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [ghBtn setFrame:CGRectMake(400-21, 350-yy, 382, 171)];
    [ghBtn addTarget:self action:@selector(openBookShelf:) forControlEvents:UIControlEventTouchUpInside];
    [ghBtn setBackgroundImage:[UIImage imageNamed:@"gh4.png"] forState:UIControlStateNormal];
    ghBtn.tag=2;
    [self.view addSubview:ghBtn];
    
    
    //管理制度文件
    gzBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [gzBtn setFrame:CGRectMake(4, 551-yy, 380, 171)];
    gzBtn.tag=3;
    [gzBtn addTarget:self action:@selector(openBookShelf:) forControlEvents:UIControlEventTouchUpInside];
    [gzBtn setBackgroundImage:[UIImage imageNamed:@"gz5.png"] forState:UIControlStateNormal];
    [self.view addSubview:gzBtn];
    
    //常用数据资料
    qkBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [qkBtn setFrame:CGRectMake(400-21, 551-yy, 382, 171)];
    [qkBtn addTarget:self action:@selector(openBookShelf:) forControlEvents:UIControlEventTouchUpInside];
    [qkBtn setBackgroundImage:[UIImage imageNamed:@"qk6.png"] forState:UIControlStateNormal];
    qkBtn.tag=4;
    [self.view addSubview:qkBtn];
  
    //规划设计图件
    ghtBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [ghtBtn setFrame:CGRectMake(4, 750-yy, 382, 171)];
    [ghtBtn addTarget:self action:@selector(openBookShelf:) forControlEvents:UIControlEventTouchUpInside];
    [ghtBtn setBackgroundImage:[UIImage imageNamed:@"gt.png"] forState:UIControlStateNormal];
    ghtBtn.tag=5;
    [self.view addSubview:ghtBtn];
    
    OaBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [OaBtn setFrame:CGRectMake(400-21, 750-yy, 382, 171)];
    [OaBtn addTarget:self action:@selector(openOa:) forControlEvents:UIControlEventTouchUpInside];
    [OaBtn setBackgroundImage:[UIImage imageNamed:@"oa.png"] forState:UIControlStateNormal];
    OaBtn.tag=6;
    [self.view addSubview:OaBtn];
    
}

-(NSMutableArray *)selectBookInfo{
    
    NSString *selectSql=[NSString stringWithFormat:Select_sql_BookInfo];
	NSMutableArray *sqlArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];
    NSLog(@"----%@",sqlArr);
    return sqlArr;
}

//TODO: --网络请求
-(void)AsihttpRequest:(NSString *)urlstr  {
    //***************************************************************************//
    
    NSString *selectSql=[NSString stringWithFormat:Select_sql_UserInfo];
	NSMutableArray *uuidArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];
    NSLog(@"--uuid arr--%lu\n%@",(unsigned long)uuidArr.count,uuidArr);
    NSString *uuidstring=nil;
    NSString *userName=nil;
    if (uuidArr.count>0) {
        
        uuidstring=[[uuidArr objectAtIndex:0] objectForKey:@"UUID"];
        userName=[[uuidArr objectAtIndex:0] objectForKey:@"UserID"];
        NSLog(@"-------userName------%@",userName);
    }
    BooksInfo * bookinfo=[[BooksInfo alloc] init];
    bookinfo.urlStr=(NSMutableString *)urlstr;
    bookinfo.UUID=uuidstring;
    bookinfo.userName=userName;
    //
    //    bookinfo.UUID=@"DFSFSFSDFSSDGDG";
    //    bookinfo.userName=@"admin";
    AsyRequestServer * asyrequest=[AsyRequestServer getInstance];
    asyrequest.requestType=0;
    asyrequest.requestff=@"POST";
    
    [asyrequest requestFormDataWithNewObject:bookinfo fromeDelegate:self];
    
    //***************************************************************************//
    
}
//-(void)viewWillAppear:(BOOL)animated{
//
//}
//-(void)viewDidAppear:(BOOL)animated{
//
//
//}
//- (void)viewWillDisappear:(BOOL)animated{
//
//}
//- (void)viewDidDisappear:(BOOL)animated{
//
//
//}
-(void)uploadBookList{
    NSLog(@"--iiiiipppppp-%@",iptext.text);
    if (![iptext.text isEqualToString:@""] &&iptext.text!=nil) {
        if ([[AsyRequestServer getInstance] testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
            Upload=YES;
            MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
			mbp.labelText = @"同步中,请稍后...";
            
            if (rootVC) {
                MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:rootVC.view animated:YES];
                mbp.labelText = @"同步中,请稍后...";
                
            }
            [iptext resignFirstResponder];
            //[self.view setUserInteractionEnabled:NO];
            [self.navigationController.view setUserInteractionEnabled:NO];
            [self popoverControllerDidDismissPopover:settingPop];
            [self AsihttpRequest:[NSString stringWithFormat:return_wordData_url,iptext.text]];
        }else
        {
            [self showError:@"请求失败，请检查网络链接"];
        }
    }else{
        
        [self showError:@"请输入IP地址"];
    }
    
}
//TODO: --同步方法
-(void)uploadBooks
{
    isFrist =@"NO";
    [self loadClass];
    
}
-(void)settingBtn
{
    
    UINavigationController *nav=[[UINavigationController alloc] init];
    settingPop=[[UIPopoverController alloc] initWithContentViewController:nav];
    settingPop.popoverContentSize=CGSizeMake(220, 120);
    settingPop.delegate=self;
    [settingPop presentPopoverFromRect:hmSettingBtn.frame inView:hmSettingBtn.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    nav.navigationBarHidden=YES;
    
    UIView *view=[[UIView alloc] init];
    [view setFrame:settingPop.contentViewController.view.frame];
    [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lasetSettingbg.png"]]];
    [view setBackgroundColor:[UIColor blackColor]];
    [settingPop.contentViewController.view addSubview:view];
    
    UIImageView *image=[[UIImageView alloc] initWithFrame:view.frame];
    //    [image setImage:[UIImage imageNamed:@"newsettingbg.png"]];
    [image setImage:[UIImage imageNamed:@"lasetSettingbg.png"]];
    
    [view addSubview:image];
    
    UILabel * setLab=[[UILabel alloc] initWithFrame:CGRectMake(40, 20, 120, 28)];
    [setLab setText:@"IP地址:"];
    [setLab setFont:[UIFont systemFontOfSize:17]];
    [setLab setBackgroundColor:[UIColor clearColor]];
    [setLab setTextColor:[JGUtil colorWithHexString:@"84C1FF"]];
    [view addSubview:setLab];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //creates paths so that you can pull the app's path from it
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"url1.plist"];
    NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:dataPath];
    NSString *urlStr=[NSString stringWithFormat:@"%@",[dTmp valueForKey:@"url1"]];
    NSLog(@"保存的url%@",urlStr);
    
    // [urlDataDic writeToFile:localPath atomically:YES];
    iptext=[[UITextField alloc] init];
    [iptext setFrame:CGRectMake(43, 47, 148, 20)];
    iptext.delegate=self;
    [iptext setBackgroundColor:[UIColor whiteColor]];
    iptext.clearButtonMode = UITextFieldViewModeAlways;
    if (urlStr) {
        [iptext setText:urlStr];
        
    }else{
        
        [iptext setText:self.IPstr];
        
    }
    [iptext setPlaceholder:self.IPstr]; //显示水印内容
    NSLog(@"---%@",IPstr);
    [view addSubview:iptext];
    
    UIButton *uploadBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [uploadBtn setFrame:CGRectMake(69, 80, 76, 30)];
    //  [uploadBtn setTitle:@"同步" forState:UIControlStateNormal];
    [uploadBtn setBackgroundImage:[UIImage imageNamed:@"uploadBtn.png"] forState:UIControlStateNormal];
    [uploadBtn setBackgroundImage:[UIImage imageNamed:@"selectUploadBtn.png"] forState:UIControlStateHighlighted];
    [uploadBtn addTarget:self action:@selector(uploadBooks) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:uploadBtn];
}

-(void)downloadAllBooks:(UIButton *)sender{
    
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:@"下载全部书籍，可能需要较长时间，请保持网络连接良好，是否执行？"
												  delegate:self
                                         cancelButtonTitle:@"否"
                                         otherButtonTitles:@"是", nil];
    [alert setTag:120];
	[alert show];
}
-(void)myBookslef:(UIButton *)sender{
    
    //    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:@"该功能暂未开放，敬请期待！"
    //												  delegate:self
    //                                         cancelButtonTitle:@"确定"
    //                                         otherButtonTitles:nil, nil];
    //	[alert show];
    
    LibraryListViewController *libVC=[LibraryListViewController alloc];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:libVC];
    [self presentViewController:nav animated:YES completion:nil];
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    libVC.MybookType=@"YES";
    libVC.name=@" 收藏夹 >";
}
-(void)myBookMark:(UIButton *)sender{
    
    
    
    LibraryListViewController *libVC=[LibraryListViewController alloc];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:libVC];
    [self presentViewController:nav animated:YES completion:nil];
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    libVC.MybookType=@"YES1";
    libVC.name=@" 收藏夹 >";
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.edgesForExtendedLayout = UIRectEdgeTop;
    CGRect frame = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.view.frame = frame;//重新定义frame
    NSLog(@"%f-----%f",self.view.bounds.origin.x,self.view.bounds.origin.y);

    
    self.view.backgroundColor=[UIColor clearColor];
    bgImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newbg.png"]];
    [bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:bgImageView];

    allDownloadBtn=[UIButton buttonWithType:1];
    [allDownloadBtn setFrame:CGRectMake(650, 2, 30, 35)];
    [allDownloadBtn setBackgroundImage:[UIImage imageNamed:@"downAllBooks.png"] forState:UIControlStateNormal];
    [allDownloadBtn addTarget:self action:@selector(downloadAllBooks:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:allDownloadBtn];
    
   myBookBtn=[UIButton buttonWithType:1];
    [myBookBtn setFrame:CGRectMake(560, 7, 25, 25)];
    [myBookBtn setBackgroundImage:[UIImage imageNamed:@"bookButton.png"] forState:UIControlStateNormal];
    [myBookBtn addTarget:self action:@selector(myBookslef:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:myBookBtn];
    
    MarkBtn=[UIButton buttonWithType:1];
    [MarkBtn setFrame:CGRectMake(610, 7, 13, 25)];
    [MarkBtn setBackgroundImage:[UIImage imageNamed:@"ReaderMark.png"] forState:UIControlStateNormal];
    [MarkBtn addTarget:self action:@selector(myBookMark:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:MarkBtn];

    
    hmSettingBtn=[UIButton buttonWithType:1];
    [hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
    [hmSettingBtn setBackgroundImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:hmSettingBtn];
    [hmSettingBtn addTarget:self action:@selector(settingBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addButton];
    
    
    
    
    //判断是否为第一次进入，读取数据库为空的话进行网络请求，否则只读取本地数据库数据；
    if ([self selectBookCategory].count<1) {
        [self loadClass];
    }
    /***************************************/
    //   [self showUploadMessage:@"是否同步数据"];
    
    
    serarchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(300, 1, 250, 40)];
    serarchBar.placeholder=@"输入书名";
    serarchBar.delegate=self;
    [self.navigationController.navigationBar addSubview:serarchBar];
    
        HelpBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [HelpBtn setFrame:CGRectMake(630, 950, 80, 40)];
        [HelpBtn setBackgroundImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
        [HelpBtn addTarget:self action:@selector(helpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        HelpBtn.tag=100;
        [self.view addSubview:HelpBtn];
    
    
    //    if ([[[UIDevice currentDevice] systemName] floatValue] <7.0) {
    //           UIView * bg_search=[serarchBar.subviews objectAtIndex:0];
    //           [bg_search removeFromSuperview];
    //    }
    
    
    //    myBooks=[[Books alloc] init];
    //    myBooks.categoryList=[NSMutableArray array];
    


    
    [self reloadView];
    [self Resize];
    [self UpdateVersion];
}
-(void)Updateitunes
{
    AsyRequestServer *asyRequest=[AsyRequestServer getInstance];
    //if ([asyRequest testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
        [self updateItunesData];
        //  [self performSelector:@selector(updateItunesData) withObject:nil afterDelay:4];
   // }

}


-(void)UpdateVersion
{
    NSString *postURL = [NSString stringWithFormat:@"http://%@:8080/zongyuan/archive/appsetting/version/inner", @"zsk.giwp.org.cn"];
    __block ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:postURL]];
    
    
    
    
    
    
    [request setCompletionBlock :^{
        NSString *responseString = [request responseString ];
        NSLog ( @"%@" ,responseString);
        
        
        NSDictionary *dicExternal = [responseString JSONValue];
        
        
        if (dicExternal!=nil) {
            NSString *strVersion=[dicExternal objectForKey:@"version"];
            version= [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
            if (![strVersion isEqualToString:version]) {
                UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"检测更新版本:水规总院知识平台 %@",strVersion] message:@"" delegate:self cancelButtonTitle:@"稍后更新" otherButtonTitles: @"现在更新", nil];
                createUserResponseAlert.tag=200;
                [createUserResponseAlert show];
                
            }
        }
        request=nil;
        
    }];
    [request setFailedBlock :^{
        request=nil;
        [self showError:@"请求失败……"];
        
    }];
    [request startAsynchronous ];
    
}


-(void)helpButtonClicked:(UIButton *)sender{
    
    helpViewController *helpVC=[[helpViewController alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
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

-(void)loadClass{
    
    MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        mbp.labelText = @"数据同步中,请稍后...";
    AsyRequestServer *asyRequest=[AsyRequestServer getInstance];
    if ([asyRequest testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
        NSString *selectUUIDSql1=[NSString stringWithFormat:Select_SuccessSql_UserInfoUUID];
        NSMutableArray *uuidarr1=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectUUIDSql1];
        
        BooksInfo * bookinfo=[[BooksInfo alloc] init];
        
        //bookinfo.UUID=@"ED7E578BE2F34AFCB20C7798D576E064";
        
        bookinfo.UUID=[[uuidarr1 objectAtIndex:0] objectForKey:@"UUID"];
        bookinfo.userName=[[uuidarr1 objectAtIndex:0] objectForKey:@"UserID"];
        // bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:@"http://192.168.1.212:8080/zongyuan/archive/tech/category/?parent=0"];//@"http://192.168.1.242/GetCategoryInfo.ashx";
        if (IPstr) {
            bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:return_class_url,IPstr,bookinfo.userName,bookinfo.UUID];
            
        }else{
            if ([isFrist isEqualToString:@"NO"]) {
                bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:return_class_url,iptext.text,bookinfo.userName,bookinfo.UUID];
                //bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:return_class_url,iptext.text,bookinfo.userName,@"89CB20157D0C42208BFD1D5765E463D1"];
            }else{
                bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:return_class_url,[self getIpUrl],bookinfo.userName,bookinfo.UUID];
            }
            
            
        }
        
        NSLog(@"--------ipStr----%@",IPstr);
        asyRequest.requestff=@"GET";
        asyRequest.requestType = 0;
        asyRequest.tokenStr=@"";
        asyRequest.logType=@"ok";
        [asyRequest requestFormDataWithNewObject:bookinfo fromeDelegate:(UIViewController *)self];
        
    }else{
        [MBProgressHUD hideHUDForView:self.view  animated:YES];
        [asyRequest showError:@"请检查网络链接"];
    }
    
    
}
//TODO:请求代理方法
-(void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"RequestFinist1----------:%@\n%@\n",[request responseString],[[request responseString] JSONValue]);
    
    if ([updateVS isEqualToString:@"findVS"] &&request.tag==222) {
        NSString* jsonResponseString = [request responseString];
        NSDictionary *loginAuthenticationResponse = [jsonResponseString JSONValue];
        NSArray *configData = [loginAuthenticationResponse valueForKey:@"results"];
        
        NSString * tempVersion;
        NSString * trackName;
        NSString * releaseNotes;
        for (id config in configData)
        {
            tempVersion= [config valueForKey:@"version"];
            trackName = [config valueForKey:@"trackName"];
            releaseNotes =[config valueForKey:@"releaseNotes"];
            trackViewUrl = [config valueForKey:@"trackViewUrl"]
            ;
        }
        //Check your version with the version in app store
        if (![version isEqualToString:tempVersion]&&version<tempVersion)
        {
            UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"检测更新版本:%@ %@",trackName,tempVersion] message:releaseNotes delegate:self cancelButtonTitle:@"稍后更新" otherButtonTitles: @"现在更新", nil];
            createUserResponseAlert.tag=200;
            [createUserResponseAlert show];
            
        }
        NSLog(@"-=-=-=-=-=-nimabid   ");
        updateVS=@"nil";
        return;
    }
    objectJson = [[[request responseString] stringByReplacingOccurrencesOfString:@"	" withString:@""] JSONValue];
    
    if (Upload==YES) {
        [self.navigationController.view setUserInteractionEnabled:YES];
        NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString * documentDirectory=[paths objectAtIndex:0];
        NSString *localPath = [documentDirectory stringByAppendingPathComponent:@"url.plist"];
        NSDictionary *urlDataDic=[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"http://%@:8001/pdfpath/",iptext.text] forKey:@"url"];
        NSLog(@"-------%@",urlDataDic);
        [urlDataDic writeToFile:localPath atomically:YES];
        
        NSString *localPath1 = [documentDirectory stringByAppendingPathComponent:@"url1.plist"];
        NSDictionary *urlDataDic1=[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",iptext.text] forKey:@"url1"];
        [urlDataDic1 writeToFile:localPath1 atomically:YES];
        
        if ([[request responseString] isEqualToString:@"[]"] || [request responseString] == nil) {
            [self showError:@"无可更新内容"];
        }else{
            NSLog(@"%@",objectJson);
            [self didBookInfoFinish];
            [self reloadView];
            [self showError:@"同步完成"];
        }
        Upload=NO;
        [MBProgressHUD hideHUDForView:self.view  animated:YES];
        if (rootVC) {
            [MBProgressHUD hideHUDForView:rootVC.view animated:YES];
            
        }
        return;
    }
    if (isBookInfo ==YES) {
        //  objectJson = [[[request responseString] stringByReplacingOccurrencesOfString:@"~" withString:@"$"] JSONValue];
        [MBProgressHUD hideHUDForView:self.view  animated:YES];
        
        NSLog(@"---%@",objectJson);
        if ([[request responseString] isEqualToString:@"[]"]) {
            
            [self showError:@"没有可更新内容！"];
            
        }else{
            
            [self didBookInfoFinish];
            [self reloadView];
            [self showError:@"同步完成！"];
        }
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        isBookInfo =NO;
    }else{
        if (objectJson !=nil) {
            NSString *selectSql=[NSString stringWithFormat:@"%@",@"select * from 'BookCategory'"];
            NSMutableArray *listArr =[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];
            if (listArr.count>0) {
                NSString *deleteSql=[NSString stringWithFormat:@"%@",@"delete from 'BookCategory'"];
                [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:deleteSql];
            }
            
            NSArray *tmp = [NSArray array];
            NSArray *tmp2 = [NSArray array];
            NSArray *tmp3=[NSArray array];
            NSArray *tmp4=[NSArray array];
            NSArray *tmp5=[NSArray array];
            for (int i=0; i<[objectJson count]; i++) {
                NSString *categoryNameStr=[[objectJson objectAtIndex:i] objectForKey:@"categoryName"];
                NSString *categoryIdStr=[[[objectJson objectAtIndex:i] objectForKey:@"categoryId"] stringValue];
                NSString *parentCategoryIdStr=[[[objectJson objectAtIndex:i] objectForKey:@"parentCategoryId"] stringValue];
                
                NSString *insertCategorySql=[NSString stringWithFormat:Insert_sql_BookCategory,categoryIdStr,categoryNameStr,parentCategoryIdStr];
                [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertCategorySql];
                
                tmp=[[objectJson objectAtIndex:i] objectForKey:@"children"];
                for (int j = 0 ; j<tmp.count; j++) {
                    NSString *CategoryNameStr1=[[tmp objectAtIndex:j] objectForKey:@"categoryName"];
                    NSString *CategoryIdStr1=[[tmp objectAtIndex:j] objectForKey:@"categoryId"];
                    NSString *parentCategoryIdStr1=[[tmp objectAtIndex:j] objectForKey:@"parentCategoryId"];
                    
                    NSString *insertCategorySql2=[NSString stringWithFormat:Insert_sql_BookCategory,CategoryIdStr1,CategoryNameStr1,parentCategoryIdStr1];
                    [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertCategorySql2];
                    
                    tmp2=[[tmp objectAtIndex:j] objectForKey:@"children"];
                    NSLog(@"--tmp2%@",tmp2);
                    if (tmp2.count>0) {
                        for (int k =0; k<tmp2.count; k++) {
                            NSString *CategoryIdStr3=[[tmp2 objectAtIndex:k] objectForKey:@"categoryId"];
                            NSString *CategoryNameStr3=[[tmp2 objectAtIndex:k] objectForKey:@"categoryName"];
                            NSString *parentCategoryIdStr3=[[tmp2 objectAtIndex:k] objectForKey:@"parentCategoryId"];
                            
                            NSString *insertCategorySql3=[NSString stringWithFormat:Insert_sql_BookCategory,CategoryIdStr3,CategoryNameStr3,parentCategoryIdStr3];
                            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertCategorySql3];
                            
                            
                            tmp3 = [[tmp2 objectAtIndex:k] objectForKey:@"children"];
                            if (tmp3.count>0) {
                                for (int a = 0; a<tmp3.count; a++) {
                                    NSString *CategoryIdStr4=[[tmp3 objectAtIndex:a] objectForKey:@"categoryId"];
                                    NSString *CategoryNameStr4=[[tmp3 objectAtIndex:a] objectForKey:@"categoryName"];
                                    NSString *parentCategoryIdStr4=[[tmp3 objectAtIndex:a] objectForKey:@"parentCategoryId"];
                                    
                                    NSString *insertCategorySql4=[NSString stringWithFormat:Insert_sql_BookCategory,CategoryIdStr4,CategoryNameStr4,parentCategoryIdStr4];
                                    [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertCategorySql4];
                                    
                                    tmp4 = [[tmp3 objectAtIndex:a] objectForKey:@"children"];
                                    if (tmp4.count>0) {
                                        for (int b = 0; b<tmp4.count; b++) {
                                            NSString *CategoryIdStr5=[[tmp4 objectAtIndex:b] objectForKey:@"categoryId"];
                                            NSString *CategoryNameStr5=[[tmp4 objectAtIndex:b] objectForKey:@"categoryName"];
                                            NSString *parentCategoryIdStr5=[[tmp4 objectAtIndex:b] objectForKey:@"parentCategoryId"];
                                            
                                            NSString *insertCategorySql5=[NSString stringWithFormat:Insert_sql_BookCategory,CategoryIdStr5,CategoryNameStr5,parentCategoryIdStr5];
                                            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertCategorySql5];
                                            
                                            tmp5 = [[tmp4 objectAtIndex:b] objectForKey:@"children"];
                                            if (tmp5.count>0) {
                                                for (int c = 0; c<tmp5.count; c++) {
                                                    NSString *CategoryIdStr6=[[tmp5 objectAtIndex:c] objectForKey:@"categoryId"];
                                                    NSString *CategoryNameStr6=[[tmp5 objectAtIndex:c] objectForKey:@"categoryName"];
                                                    NSString *parentCategoryIdStr6=[[tmp5 objectAtIndex:c] objectForKey:@"parentCategoryId"];
                                                    
                                                    NSString *insertCategorySql6=[NSString stringWithFormat:Insert_sql_BookCategory,CategoryIdStr6,CategoryNameStr6,parentCategoryIdStr6];
                                                    [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertCategorySql6];
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            }
            if ([isFrist isEqualToString:@"NO"]) {
                [MBProgressHUD hideHUDForView:self.view  animated:YES];
                
                [self uploadBookList];
                return ;
            }
            isBookInfo = YES;
            MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            mbp.labelText = @"同步数据，请稍后...";
            
            [self AsihttpRequest:[NSString stringWithFormat:return_wordData_url,[self saveUrlStr]]];
            //  [self AsihttpRequest:@"http://localhost:8080/zongyuan/archive/tech/records/list"];
        }else{
            
            [self showError:@"更新分类失败!"];
        }
 
    }
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    
}

-(void)requestFailed:(ASIFormDataRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    [self showError:@"请求失败……"];
    NSLog(@"RequestFailed2----------:%@\n%@\n\n\n\n%@\n%@\n%d",[request responseData],[request responseString],[request error],[request requestHeaders],[request responseStatusCode]);
    
}

-(void)removeBook:(int)bookId{
    
    
    NSString *selectName=[NSString stringWithFormat:Select_sql_BookName,bookId];
    NSLog(@"%@,%@",[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectName],[[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectName] class]);
    NSArray *bookNamearr = [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectName];
    NSString *bookName;
    NSLog(@"=-=-%@",bookNamearr);
    for (int i=0; i<bookNamearr.count; i++) {
        bookName = [[bookNamearr objectAtIndex:i] objectForKey:@"BooKName"];
    }
    NSString *dPdf =[NSString stringWithFormat:@"%@/Library/Caches/fileTemp",NSHomeDirectory()];
    NSString *dPdf1 =[NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()];
NSFileManager *defaultManager;
    NSFileManager *defaultManager1;
    defaultManager = [NSFileManager defaultManager];
     defaultManager1 = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",dPdf,bookName] error:nil];
    [defaultManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",dPdf1,bookName] error:nil];
    
}
-(void)didBookInfoFinish
{
    
    NSMutableArray *arr=[NSMutableArray array];
    BooksInfo *bookInfo=[[BooksInfo alloc] init];
    NSLog(@"----bookJsonArrcount--%lu",(unsigned long)[objectJson count]);
    for (int i = 0;i<[objectJson count]; i++) {
        //  [arr addObject:[[bookJsonArr objectAtIndex:i] objectForKey:@"BooKName"]];
        bookInfo.bookID=[[[objectJson objectAtIndex:i] objectForKey:@"bookId"] intValue];
        //        bookInfo.bookName=[[[objectJson objectAtIndex:i] objectForKey:@"BooKName"] stringByReplacingOccurrencesOfString:@"$" withString:@"/"];
        bookInfo.bookName=[[objectJson objectAtIndex:i] objectForKey:@"bookName"];
        bookInfo.page=[[[objectJson objectAtIndex:i] objectForKey:@"page"] intValue];
        bookInfo.CategoryID=[[[objectJson objectAtIndex:i] objectForKey:@"categoryId"] intValue];
        //  bookInfo.deleteBookId=[[objectJson objectAtIndex:i] objectForKey:@"delBook"];
        bookInfo.NoEmpowerBook=[[objectJson objectAtIndex:i]objectForKey:@"noEmpowerBook"];
        bookInfo.bookUrl=(NSMutableString *)[[[objectJson objectAtIndex:i] objectForKey:@"bookUrl"] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        //     bookInfo.bookUrl=(NSMutableString *)[[objectJson objectAtIndex:i] objectForKey:@"bookurl"];
        //bookInfo.author =[[objectJson objectAtIndex:i] objectForKey:@"bookdetail"];
        bookInfo.bookKey = [[objectJson objectAtIndex:i] objectForKey:@"bookKey"];
        bookInfo.noDestroy = [[objectJson objectAtIndex:i] objectForKey:@"noDestroy"];
        
   
        NSLog(@"-----bbbbbbbbbbbb_--%@,\n%@",bookInfo.bookUrl,bookInfo.author);
        //以下为预留字段
        //bookInfo.BookCover=[[bookJsonArr objectAtIndex:i ] objectForKey:@"BookCover"];
        // bookInfo.author=[[bookJsonArr objectAtIndex:i ] objectForKey:@"Author"];
        //bookInfo.publishDate=[[bookJsonArr objectAtIndex:i ] objectForKey:@"PublishDate"];
        //bookInfo.Language=[[bookJsonArr objectAtIndex:i ] objectForKey:@"Language"];
        //bookInfo.BookProfile=[[bookJsonArr objectAtIndex:i ] objectForKey:@"BookProfile"];
        //bookInfo.bookID=[[bookJsonArr objectAtIndex:i ] objectForKey:@"booksize"];
        //bookInfo.Weight=[[bookJsonArr objectAtIndex:i ] objectForKey:@"Weight"];

        //        if (bookInfo.deleteBookId) {
        //            NSString *deleteBookSql=[NSString stringWithFormat:Delete_sql_Book,[bookInfo.deleteBookId intValue]];
        //            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:deleteBookSql];
        //        }
        //作废
        if (bookInfo.noDestroy) {
            [self removeBook:[bookInfo.noDestroy intValue]];
        }
        //获取数据，插入数据库
        if (bookInfo.deleteBookId) {
            //   [self removeBook:[bookInfo.deleteBookId intValue]];
            NSString *deleteBookSql=[NSString stringWithFormat:Delete_sql_Book,[bookInfo.deleteBookId intValue]];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:deleteBookSql];
        }
        NSLog(@"----caole---%@",bookInfo.NoEmpowerBook);
        if (bookInfo.NoEmpowerBook && [bookInfo.NoEmpowerBook intValue]!=0) {
            // [self removeBook:[bookInfo.NoEmpowerBook intValue]];
            
            NSString *deleteBookSql=[NSString stringWithFormat:Delete_sql_Book,[bookInfo.NoEmpowerBook intValue]];
            NSLog(@"----cale%@",deleteBookSql);
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:deleteBookSql];
            [self removeBook:[bookInfo.NoEmpowerBook intValue]];

        }
        if (bookInfo.bookID) {
            
            NSString *insertBookInfoSql=[NSString stringWithFormat:Insert_sql_BookInfo,bookInfo.bookID,bookInfo.bookName,bookInfo.page,bookInfo.CategoryID,bookInfo.bookUrl];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertBookInfoSql];
            NSLog(@"insertsql------%@",insertBookInfoSql);
            NSLog(@"insertsql------%@",insertBookInfoSql);
        }
        
        [arr addObject:bookInfo];
        
    }
    NSLog(@"===%@",arr);
    
}

-(void)MbprogressHUD
{
    MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mbp.labelText = @"加载数据中,请稍后...";
    
    
}

-(void)openOa:(UIButton *)sender
{
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"此功能暂未开放" message:nil
												  delegate:self
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil];
	[alert show];
}
-(void)openBookShelf:(UIButton *)sender
{
    [self performSelector:@selector(MbprogressHUD)];
     SaffronClientSQLManager* man=[SaffronClientSQLManager getInstance];
    rootVC=[[RootViewController alloc] init];
    rootVC.ipUrl=self.IPstr;
    //    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:rootVC];
    // [self.navigationController initWithRootViewController:rootVC];
    
 
    
    NSMutableArray *categoryListArr = [NSMutableArray array];
    NSMutableArray *categoryCategoryarr3=[NSMutableArray array];
    NSLog(@"-----nimade---%ld",(long)sender.tag);
    NSArray *categoryarr=[NSArray new];
    NSString *selectSql1=[NSString stringWithFormat:Select_sql_BookCategoryName,1];
	categoryarr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql1];
//    if (sender.tag>=categoryarr.count) {
//         [MBProgressHUD hideHUDForView:self.view  animated:YES];
//        return;
//    }
    NSArray *tmp = [NSArray array];
    if (categoryarr.count<1) {
        rootVC.CategoryID=[[objectJson objectAtIndex:sender.tag] objectForKey:@"CategoryID"];
        rootVC.name=[[objectJson objectAtIndex:sender.tag] objectForKey:@"CategoryName"];
        tmp =[[objectJson objectAtIndex:sender.tag] objectForKey:@"children"];
        
    }else{
        //rootVC.CategoryID=[[categoryarr objectAtIndex:0] objectForKey:@"CategoryID"];
        rootVC.CategoryID=[[categoryarr objectAtIndex:sender.tag] objectForKey:@"CategoryID"];
        rootVC.name=[[categoryarr objectAtIndex:sender.tag] objectForKey:@"CategoryName"];

        NSLog(@"=====%@",rootVC.CategoryID);
        NSString *selectSql2=[NSString stringWithFormat:Select_sql_BookCategoryName,[rootVC.CategoryID intValue]];
        tmp =[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql2]; //二级分类目录
        
        NSLog(@"=====%@",tmp);
        
    }
    
    if (tmp.count>0) {
        
        for (int i = 0; i<tmp.count; i++) {
            [categoryListArr addObject:[[tmp objectAtIndex:i] objectForKey:@"CategoryName"]];
            [categoryCategoryarr3 addObject:[[tmp objectAtIndex:i] objectForKey:@"CategoryID"]];
        }
        NSLog(@"----www%@",categoryListArr);
        NSLog(@"---------iooooooo%@",categoryCategoryarr3);
        rootVC.CategoryArray = categoryListArr;
        rootVC.categoryIDclass4 = categoryCategoryarr3;
    }
    //[self presentModalViewController:nav animated:YES];
    man.bAll=NO;
    man.strId=rootVC.CategoryID;
    [self.navigationController pushViewController:rootVC animated:YES];
     //[self presentViewController:nav animated:YES completion:nil];
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    
}


#pragma mark -
#pragma mark searchBar methods

-(BOOL)isHaveThisItem:(BooksInfo *)binfo
{
    for (BooksInfo * info in searchArray) {
        
        if ([info.bookName isEqual:binfo]) {
            return YES;
        }
    }
    return NO;
}


-(void)doActionSearchBooks:(NSString *)text
{
    [searchArray removeAllObjects];
    NSLog(@"%@---ssss---",myBooks.categoryList);
   SaffronClientSQLManager* man=[SaffronClientSQLManager getInstance];
    
    if (!man.bAll) {
        Books *Booksmy=[[Books alloc] init];
        Booksmy.categoryList=[NSMutableArray array];
        CategoryBook * cate=[[CategoryBook alloc] init];
        cate.bookList=[NSMutableArray array];
        
        NSMutableArray *idarr=[[NSMutableArray alloc]init];
        NSString *selectBookSqlid=[NSString stringWithFormat:Select_sql_BookCategoryNameSecond,[man.strId integerValue]];
        NSMutableArray *sqlArrid=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSqlid];
        for (NSInteger i=0; i<sqlArrid.count; i++) {
            
            NSString *sid=[[sqlArrid objectAtIndex:i] objectForKey:@"CategoryID"];
            [idarr addObject:sid];
            NSString *selectBookSqlid1=[NSString stringWithFormat:Select_sql_BookCategoryName,[sid integerValue]];
            NSMutableArray *sqlArrid1=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSqlid1];
            
            for (NSInteger n=0; n<sqlArrid1.count; n++) {
                NSString *sid1=[[sqlArrid1 objectAtIndex:n] objectForKey:@"CategoryID"];
                [idarr addObject:sid1];
                NSString *selectBookSqlid2=[NSString stringWithFormat:Select_sql_BookCategoryName,[sid1 integerValue]];
                NSMutableArray *sqlArrid2=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSqlid2];
                
                for (NSInteger m=0; m<sqlArrid2.count; m++) {
                    NSString *sid2=[[sqlArrid2 objectAtIndex:i] objectForKey:@"CategoryID"];
                    [idarr addObject:sid2];
                }
            }
            
        }
        NSMutableArray *sqlArr=[[NSMutableArray alloc]init];
        for (NSInteger ss=0; ss<idarr.count; ss++) {
            NSString *strrid=[idarr objectAtIndex:ss];
            NSString *selectBookSql=[NSString stringWithFormat:select_sql_indexBookInfo,[strrid integerValue]];
            NSMutableArray *sqlArr3=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql];
            for (NSInteger nn=0; nn<sqlArr3.count; nn++) {
                [sqlArr addObject:[sqlArr3 objectAtIndex:nn]];
            }
        }
        
        
        for (int aa = 0; aa<sqlArr.count; aa++) {
            BooksInfo * bkInfo=[[BooksInfo alloc] init];
            bkInfo.bookName=[[sqlArr objectAtIndex:aa] objectForKey:@"BooKName"];
       
            bkInfo.bookID =[[[sqlArr objectAtIndex:aa] objectForKey:@"BookID"] intValue];
                   bkInfo.bookKey=[[sqlArr objectAtIndex:aa] objectForKey:@"BookKey"];
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
            //creates paths so that you can pull the app's path from it
            NSString *documentsDirectory = [paths objectAtIndex:0];

             bkInfo.documentPath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,bkInfo.bookName];
            [cate.bookList addObject:bkInfo];
        }
         [Booksmy.categoryList addObject:cate];
        
        for (CategoryBook * cate in Booksmy.categoryList) {
            
            for (BooksInfo * bInfo in cate.bookList) {
                NSLog(@"%@",bInfo);
                NSString *searchString = bInfo.bookName;
                NSRange   matchedRange = NSMakeRange(NSNotFound, 0UL);
                matchedRange=[searchString rangeOfRegex:text inRange:NSMakeRange(0, searchString.length)];
                
                if (matchedRange.location!=NSNotFound && ![self isHaveThisItem:bInfo]) {
                    
                    [searchArray addObject:bInfo];
                }
            }
            
        }

    }else
    {
        
        for (CategoryBook * cate in myBooks.categoryList) {
        
              for (BooksInfo * bInfo in cate.bookList) {
                  NSLog(@"%@",bInfo);
                  NSString *searchString = bInfo.bookName;
                  NSRange   matchedRange = NSMakeRange(NSNotFound, 0UL);
                  matchedRange=[searchString rangeOfRegex:text inRange:NSMakeRange(0, searchString.length)];
            
                  if (matchedRange.location!=NSNotFound && ![self isHaveThisItem:bInfo]) {
               
                    [searchArray addObject:bInfo];
                }
              }
        }
    }
    
    

}

-(void)didSearchMethodWithSearch:(UISearchBar *)searchBar
{
    
    if (searchArray==nil) {
        searchArray=[[NSMutableArray alloc] init];
    }
    
    [self doActionSearchBooks:searchBar.text];
    
    if (spopver==nil) {
        BookSearchViewController * bookSearch=[[BookSearchViewController alloc] init];
        bookSearch.delegate=self;
        bookSearch.dataArray=[NSMutableArray arrayWithArray:searchArray];
        UINavigationController * navController=[[UINavigationController alloc] initWithRootViewController:bookSearch];
        
        spopver=[[UIPopoverController alloc] initWithContentViewController:navController];
        spopver.popoverContentSize=CGSizeMake(480, 700);
        spopver.delegate=self;
        [spopver presentPopoverFromRect:searchBar.frame inView:searchBar.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        navController.navigationBarHidden=YES;
    }
    else{
        
        UINavigationController * nav=(UINavigationController *)[spopver contentViewController];
        BookSearchViewController * bookSearch=(BookSearchViewController *)[nav topViewController];
        bookSearch.dataArray=[NSMutableArray arrayWithArray:searchArray];
        [((UITableView *)bookSearch.view) reloadData];
        
    }
    
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    [self didSearchMethodWithSearch:searchBar];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [self didSearchMethodWithSearch:searchBar];
    
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    // NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    // [defaults setBool:swith.on forKey:@"swith"];
    return YES;
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [spopver dismissPopoverAnimated:YES];
    [self.view endEditing:YES];
    serarchBar.text=nil;
    spopver = nil;
    [serarchBar resignFirstResponder];
    [settingPop dismissPopoverAnimated:YES];
    
}

-(void)reloadView{
    
    
    NSString *selectBookSql=[NSString stringWithFormat:select_sql_allBookInfo];
    NSMutableArray *sqlArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql];
    NSLog(@"%@",sqlArr);
    if (sqlArr.count>0) {
        myBooks=[[Books alloc] init];
        myBooks.categoryList=[NSMutableArray array];
        //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
        //creates paths so that you can pull the app's path from it
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"url.plist"];
        //	NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
        NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:dataPath];
        NSString *urlStr=[NSString stringWithFormat:@"%@",[dTmp valueForKey:@"url"]];
        NSLog(@"--urlstr--%@",urlStr);
        
        {
            CategoryBook * cate=[[CategoryBook alloc] init];
            cate.bookList=[NSMutableArray array];
            //   NSLog(@"--cccsssccc---%d",[sqlArr count]);
            
            for (int i = 0; i<sqlArr.count; i++) {
                BooksInfo * bkInfo=[[BooksInfo alloc] init];
                bkInfo.bookName=[[[sqlArr objectAtIndex:i] objectForKey:@"BooKName"] stringByReplacingOccurrencesOfString:@"/" withString:@"$"];
                bkInfo.documentPath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,bkInfo.bookName];
                bkInfo.bookID =[[[sqlArr objectAtIndex:i] objectForKey:@"BookID"] intValue];
                NSString * url=[NSString stringWithFormat:@"%@%@",urlStr,[[sqlArr objectAtIndex:i] objectForKey:@"Path"]];
                //    NSLog(@"url========%@",url);
                NSString *urlstr= [url stringByReplacingOccurrencesOfString:@"~" withString:@"/"];
                //    NSLog(@"lklklklklkklklkklkllkl--%@",urlstr);
                bkInfo.urlStr=(NSMutableString *)[urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //    NSLog(@"docfile=%@", bkInfo.documentPath);
                bkInfo.bookKey =[[sqlArr objectAtIndex:i] objectForKey:@"BookKey"];
                [cate.bookList addObject:bkInfo];
            }
            [myBooks.categoryList addObject:cate];
            //  NSLog(@";;;;;%@\n%@",myBooks.categoryList,cate);
            
        }
        
    }
    
}

//#pragma mark 搜索进入pdf阅读
-(void)didSelectBookInfo:(BooksInfo *)bookInfo withOther:(NSDictionary *)other
{
    
    NSString *fileTmp=[Decrypt dFlie:bookInfo.bookName];
    BOOL dectyotOk =[[NSFileManager defaultManager] fileExistsAtPath:fileTmp];
    
    BOOL have=   [[NSFileManager defaultManager] fileExistsAtPath:bookInfo.documentPath];
    
    if (have==YES) {
        searchSelectBook=bookInfo;
        [spopver dismissPopoverAnimated:YES];
        [self.view endEditing:YES];
        serarchBar.text=nil;
        spopver = nil;
        [serarchBar resignFirstResponder];
        NSString *   exestr = [bookInfo.documentPath pathExtension];
        
        //TODO:==
        ReaderDocument *document;
        if (dectyotOk==YES) {
            
            if ([exestr isEqualToString:@"jpg"] ||[exestr isEqualToString:@"png"]) {
                ImgViewController *imgVC=[[ImgViewController alloc] init];
                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:imgVC];
                imgVC.img=fileTmp;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                
                NSLog(@"图片");
                return;
            }else{
                document = [ReaderDocument withDocumentFilePath:fileTmp password:nil];
                
            }
            
        }else{
            
            NSLog(@"---%@",bookInfo.bookKey);
            NSString *newPath = [Decrypt filePath:bookInfo.documentPath DecryptKey:nil fileName:bookInfo.bookName];
            if ([exestr isEqualToString:@"jpg"] ||[exestr isEqualToString:@"png"]) {
                ImgViewController *imgVC=[[ImgViewController alloc] init];
                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:imgVC];
                imgVC.img=newPath;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                
                NSLog(@"图片");
                return;
            }else{
                document = [ReaderDocument withDocumentFilePath:newPath password:nil];
                
            }
            
            //TODO:==
            
        }
        
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            
            readerViewController.delegate = self;
            
            // [self.navigationController pushViewController:readerViewController animated:YES];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
                [self presentModalViewController:readerViewController animated:YES];
            }
            else{
                
                [self presentViewController:readerViewController animated:YES completion:^{
                    
                }];
            }
        }
        
        
    }else{
        
        NSLog(@"去下载");
        NSLog(@"m没有有这个文件");
        AsyRequestServer *asylanding=[AsyRequestServer getInstance];
        if ([asylanding testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
            
            AsyRequestServer *asydownload=[AsyRequestServer getInstance];
//             UIProgressView *pro=[[UIProgressView alloc]initWithFrame:CGRectMake(ScreenWidth/4, (ScreenHeight-60)/2, ScreenWidth/2, 60)];
//            [self.view addSubview:pro];
//            bookInfo.progressView=pro;
            MBProgressHUD *mbp=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            mbp.labelText=@"下载文件,请稍后";
            [asydownload requestDownloadDataWithNewObject:bookInfo delegate:self];
            
            
           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeProgressView) name:ASY_RequestFinishObsever_Info object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeProgressView) name:ASY_RequestFailedObsever_Info object:nil];
        }else{
            
            [self showError:@"请检查网络链接"];

        }
    }
    
}
-(void)removeProgressView
{
    
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
}
- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    
    //[self.navigationController popViewControllerAnimated:YES];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)dealloc
//{
//
//    [self.navigationController.navigationBar removeGestureRecognizer:self.navigationBarPanGestureRecognizer];
//	 _navigationBarPanGestureRecognizer = nil;
//}


#pragma mark - 版本更新通知
-(void)updateItunesData{
    updateVS=@"findVS";
    version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSLog(@"version:%@",version);
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/lookup?id=797365633"];
    ASIFormDataRequest * versionRequest = [ASIFormDataRequest requestWithURL:url];
    versionRequest.tag=222;
    [versionRequest setRequestMethod:@"GET"];
    [versionRequest setDelegate:self];
    [versionRequest setTimeOutSeconds:150];
    [versionRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [versionRequest startAsynchronous];
    //Response string of our REST call
}
- (CGRect)frameForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect frame;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
    } else {
        frame = [UIScreen mainScreen].bounds;
    }
    return frame;
}

//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
////支持的方向
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = [self frameForOrientation:interfaceOrientation];
    self.view.frame = frame;//重新定义frame

    UIInterfaceOrientation to=self.interfaceOrientation;
    if(to == UIDeviceOrientationLandscapeLeft || to == UIDeviceOrientationLandscapeRight)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
        [bgImageView setFrame:frame];
        [bgImageView setImage:[UIImage imageNamed:@"bg_h.png"]];
        
         NavBg.frame=CGRectMake(0, 44, self.view.bounds.size.width, 50);
        
        
        [serarchBar setFrame:CGRectMake(400, 1, 250, 40)];
        [myBookBtn setFrame:CGRectMake(800-80, 7, 25, 25)];
        [MarkBtn setFrame:CGRectMake(850-47, 7, 13, 25)];
        
        [allDownloadBtn setFrame:CGRectMake(880, 2, 30, 35)];
        [hmSettingBtn setFrame:CGRectMake(960, 7, 25, 25)];
        
        [biaozhunBtn setFrame:CGRectMake(130, 158-70+30, 380, 171)];

        //审查审批文件
        [scyjBtn setFrame:CGRectMake(400-21+140, 158-70+30, 380, 171)];
        [scBtn setFrame:CGRectMake(130, 350-80+20, 380, 171)];
        
        //重要规划报告
        [ghBtn setFrame:CGRectMake(400-21+140, 350-80+20, 382, 171)];
        
        //管理制度文件
        [gzBtn setFrame:CGRectMake(130, 551-93+10, 380, 171)];
        
        //常用数据资料
        [qkBtn setFrame:CGRectMake(400-21+140, 551-93+10, 382, 171)];
        
        //规划设计图件
        [ghtBtn setFrame:CGRectMake(130, 750-120, 382, 171)];
        [OaBtn setFrame:CGRectMake(400-21+140, 750-120, 382, 171)];
        [HelpBtn setFrame:CGRectMake(400-21+140+400, 750-100+44, 80, 40)];

    }else if (interfaceOrientation==UIDeviceOrientationPortrait || interfaceOrientation ==UIDeviceOrientationPortraitUpsideDown){
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
        [bgImageView setImage:[UIImage imageNamed:@"newbg.png"]];
        [serarchBar setFrame:CGRectMake(300, 1, 250, 40)];
        [allDownloadBtn setFrame:CGRectMake(655, 2, 30, 35)];
        [bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
        [myBookBtn setFrame:CGRectMake(560, 7, 25, 25)];
        [hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
        [biaozhunBtn setFrame:CGRectMake(4, 158, 380, 171)];
        [scyjBtn setFrame:CGRectMake(400-21, 158, 380, 171)];
        [scBtn setFrame:CGRectMake(4, 350, 380, 171)];
        [ghBtn setFrame:CGRectMake(400-21, 350, 382, 171)];
        [gzBtn setFrame:CGRectMake(4, 551, 380, 171)];
        [qkBtn setFrame:CGRectMake(400-21, 551, 382, 171)];
        [ghtBtn setFrame:CGRectMake(4, 750, 382, 171)];
        [OaBtn setFrame:CGRectMake(400-21, 750, 382, 171)];
        NavBg.frame=CGRectMake(0, 44, self.view.bounds.size.width, 50);
        [HelpBtn setFrame:CGRectMake(630, 950, 80, 40)];
        [MarkBtn setFrame:CGRectMake(615, 7, 13, 25)];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
     CGRect frame = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.view.frame = frame;//重新定义frame
    
    UIInterfaceOrientation to=self.interfaceOrientation;
    if(to == UIDeviceOrientationLandscapeLeft || to == UIDeviceOrientationLandscapeRight)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
        [bgImageView setFrame:frame];
        [bgImageView setImage:[UIImage imageNamed:@"bg_h.png"]];
        
        NavBg.frame=CGRectMake(0, 0, self.view.bounds.size.width, 50);
        
        
        [serarchBar setFrame:CGRectMake(400, 1, 250, 40)];
        [myBookBtn setFrame:CGRectMake(800-80, 7, 25, 25)];
        [MarkBtn setFrame:CGRectMake(850-47, 7, 13, 25)];

        [allDownloadBtn setFrame:CGRectMake(880, 2, 30, 35)];
        [hmSettingBtn setFrame:CGRectMake(960, 7, 25, 25)];
        
        [biaozhunBtn setFrame:CGRectMake(130, 158-70-14, 380, 171)];
        
        //审查审批文件
        [scyjBtn setFrame:CGRectMake(400-21+140, 158-70-14, 380, 171)];
        [scBtn setFrame:CGRectMake(130, 350-80-24, 380, 171)];
        
        //重要规划报告
        [ghBtn setFrame:CGRectMake(400-21+140, 350-80-24, 382, 171)];
        
        //管理制度文件
        [gzBtn setFrame:CGRectMake(130, 551-93-34, 380, 171)];
        
        //常用数据资料
        [qkBtn setFrame:CGRectMake(400-21+140, 551-93-34, 382, 171)];
        
        //规划设计图件
        [ghtBtn setFrame:CGRectMake(130, 750-120-44, 382, 171)];
        [OaBtn setFrame:CGRectMake(400-21+140, 750-120-44, 382, 171)];
        [HelpBtn setFrame:CGRectMake(400-21+140+400, 750-100, 80, 40)];

        
    }else if ([UIApplication sharedApplication].statusBarOrientation==UIDeviceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation ==UIDeviceOrientationPortraitUpsideDown){
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
        [bgImageView setImage:[UIImage imageNamed:@"newbg.png"]];
        [serarchBar setFrame:CGRectMake(300, 1, 250, 40)];
        [allDownloadBtn setFrame:CGRectMake(655, 2, 30, 35)];
        [bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
        [myBookBtn setFrame:CGRectMake(560, 7, 25, 25)];
        [hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
        [biaozhunBtn setFrame:CGRectMake(4, 158, 380, 171)];
        [scyjBtn setFrame:CGRectMake(400-21, 158, 380, 171)];
        [scBtn setFrame:CGRectMake(4, 350, 380, 171)];
        [ghBtn setFrame:CGRectMake(400-21, 350, 382, 171)];
        [gzBtn setFrame:CGRectMake(4, 551, 380, 171)];
        [qkBtn setFrame:CGRectMake(400-21, 551, 382, 171)];
        [ghtBtn setFrame:CGRectMake(4, 750, 382, 171)];
        [OaBtn setFrame:CGRectMake(400-21, 750, 382, 171)];
        NavBg.frame=CGRectMake(0, 44, self.view.bounds.size.width, 50);
        [HelpBtn setFrame:CGRectMake(630, 950, 80, 40)];
        [MarkBtn setFrame:CGRectMake(615, 7, 13, 25)];
        
    }

}
-(void)viewDidAppear:(BOOL)animated
{
   
}
@end
