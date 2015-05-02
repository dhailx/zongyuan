//
//  LibraryListViewController.m
//  MyReader
//
//  Created by YDJ on 13-5-22.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import "LibraryListViewController.h"
#import "RootViewController.h"
#import "PublicClassHeader.h"
#import "SaffronClientSQLManager.h"
#import "JGBooksModel.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "RegexKitLite.h"
#import "BookSearchViewController.h"
#import "NetworkMonitor.h"
#import "AsyRequestServer.h"
#import "Reachability.h"
#import "BooksInfo.h"
#import "SBJson.h"
#import "MBProgressHUD.h"
#import "JGUtil.h"
#import "Decrypt.h"
#import "ImgViewController.h"
//每行书的个数

@interface LibraryListViewController ()<UITableViewDataSource,UITableViewDelegate,ReaderViewControllerDelegate,UISearchBarDelegate,UIPopoverControllerDelegate,BookSearchDelegate>
{
    NSMutableArray *catearr;
}
@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)NSMutableArray * searchArray;
@property (nonatomic,strong)UISearchBar * searchBar;
@property (nonatomic,strong)Books *myBooks;
@property (nonatomic,strong)Books *myBooksinfo;
@property (nonatomic,strong)BooksInfo * searchSelectBook;//搜索的时候选择的书
@property (nonatomic,strong)UIPopoverController *popover;
@property (nonatomic,strong) UIPopoverController *settingPop;
@property (nonatomic,assign)BOOL isMainView;

@property (nonatomic,strong)BooksInfo * lastReadBookInfo;//最后
@end

@implementation LibraryListViewController

@synthesize index;
@synthesize IPurl,landIP;
@synthesize CategoryID,CategoryID2,smallCategoryArr,categoryIDclass3,CategoryNameArr;
@synthesize MybookType,NavBg,NavList,name,UserLabel,progress,myBookBtn;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //CategoryArray=[NSMutableArray array];
        
        // Custom initialization
    }
    return self;
}


-(Books *)sortBooksInfo:(Books *)book
{//TODO:排序，按找每行的个数放到数组里面去,排序后cateBook.bookList里面不再直接存放booksInfo对象，而是存放数组，一个数组就是一个cell，数组中的元素就是booksInfo对象
    
    NSLog(@"---%@",book.categoryList);
    for (int i=0;i<[book.categoryList count];i++) {
        CategoryBook * cateBook = [book.categoryList objectAtIndex:i];
        NSMutableArray * result=[NSMutableArray arrayWithArray:cateBook.bookList];
        NSMutableArray * temp=[NSMutableArray array];
        NSMutableArray * sortList=[NSMutableArray array];
        int start=0;
        while (start!=[result count]) {
            
            BooksInfo * bookInfo=[result objectAtIndex:start];
            [temp addObject:bookInfo];
            start++;
            NSInteger knum=kNumBook;
            if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)     {
                knum=5;
            }
            if (start==[result count] || [temp count]==knum) {
                [sortList addObject:[NSMutableArray arrayWithArray:temp]];//存到数组里面，本数组最大个数不会超过kNumbook的值
                [temp removeAllObjects];
            }
        }
        //        NSLog(@"////////////////=============%@",sortList);
        
        [cateBook.bookList removeAllObjects];
        [cateBook.bookList addObjectsFromArray:sortList];
        [book.categoryList replaceObjectAtIndex:i withObject:cateBook];//替换刷新
    }
    //    NSLog(@"nfffffffff%@",book);
    return book;
}

-(void)backHome
{
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    RootViewController *root=[RootViewController alloc];
    [root.shuTabView reloadData];
}

-(void)settingBtn
{
    
    UINavigationController *nav=[[UINavigationController alloc] init];
    _settingPop=[[UIPopoverController alloc] initWithContentViewController:nav];
    _settingPop.popoverContentSize=CGSizeMake(220, 120);
    _settingPop.delegate=self;
    [_settingPop presentPopoverFromRect:setting.frame inView:setting.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    nav.navigationBarHidden=YES;
    
    UIView *view=[[UIView alloc] init];
    [view setFrame:_settingPop.contentViewController.view.frame];
    [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lasetSettingbg.png"]]];
    [view setBackgroundColor:[UIColor blackColor]];
    [_settingPop.contentViewController.view addSubview:view];
    
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
        
        [iptext setText:self.IPurl];
        
    }
    [iptext setPlaceholder:self.IPurl]; //显示水印内容
    NSLog(@"---%@",IPurl);
    [view addSubview:iptext];
    
    UIButton *uploadBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [uploadBtn setFrame:CGRectMake(69, 80, 76, 30)];
    //  [uploadBtn setTitle:@"同步" forState:UIControlStateNormal];
    [uploadBtn setBackgroundImage:[UIImage imageNamed:@"uploadBtn.png"] forState:UIControlStateNormal];
    [uploadBtn setBackgroundImage:[UIImage imageNamed:@"selectUploadBtn.png"] forState:UIControlStateHighlighted];
    [uploadBtn addTarget:self action:@selector(uploadBooks) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:uploadBtn];
}


- (void)showError:(NSString*)message
{
	UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:message
												  delegate:self
										 cancelButtonTitle:@"确定"
										 otherButtonTitles:nil];
	[alert show];
}

//TODO: --同步方法
-(void)uploadBooks
{
    NSLog(@"--iiiiipppppp-%@",iptext.text);
    if (![iptext.text isEqualToString:@""] &&iptext.text!=nil) {
        if ([[AsyRequestServer getInstance] testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
            isUpload=YES;
            MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
			mbp.labelText = @"同步中,请稍后...";
            [iptext resignFirstResponder];
            //      [self.view setUserInteractionEnabled:NO];
            [self.navigationController.view setUserInteractionEnabled:NO];
            [self popoverControllerDidDismissPopover:self.settingPop];
            [self AsihttpRequest:[NSString stringWithFormat:return_wordData_url,iptext.text]];
        }else
        {
            [self showError:@"请求失败，请检查网络链接"];
        }
    }else{
        
        [self showError:@"请输入IP地址"];
    }
    
}


-(NSMutableArray *)selectBookCategoryTab{
    NSString *seclectSql=[NSString stringWithFormat:Select_sql_BookCategoryName,[self.CategoryID intValue]];
	NSMutableArray *sqlArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:seclectSql];
    return sqlArr;
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
        
        userName=[[uuidArr objectAtIndex:0] objectForKey:@"UserID"];
        uuidstring=[[uuidArr objectAtIndex:0] objectForKey:@"UUID"];
        
        NSLog(@"-------userName------%@",userName);
        NSLog(@"-------userName------%@",uuidstring);
        
    }
    BooksInfo * bookinfo=[[BooksInfo alloc] init];
    bookinfo.urlStr=(NSMutableString *)urlstr;
    bookinfo.UUID=uuidstring;
    bookinfo.userName=userName;
    asyrequest=[AsyRequestServer getInstance];
    asyrequest.requestType=0;
    [asyrequest requestFormDataWithNewObject:bookinfo fromeDelegate:self];
    
    //***************************************************************************//
    
}

//-(void)addBooksInfo:(NSString *)classId isend:(BOOL)end{
//    NSLog(@"--------classId---%@\n",classId);
//    if (end) {
//        NSLog(@"-----%d",catearr.count);
//        if (catearr.count) {
//            CategoryBook *books=[[CategoryBook alloc]init];
//            books.bookList=[NSMutableArray arrayWithArray:catearr];
//            // books.bookList=[cate copy];
//            [_myBooks.categoryList addObject:books];
//            [catearr removeAllObjects];
//            catearr=nil;
//            catearr=[NSMutableArray array];
//        }
//
//        return;
//    }
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    //creates paths so that you can pull the app's path from it
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//
//    // cate=[[CategoryBook alloc] init];
//    //    for (int j=0; j<[CategoryArray count]; j++) {
//    //        cate.cateName=[CategoryArray objectAtIndex:j];
//    //    }
//    //
//    int classstr  =[classId intValue];
//    NSString *selectBookSql=[NSString stringWithFormat:select_sql_indexBookInfo,classstr];
//    NSMutableArray *sqlArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql];
//    //   NSLog(@"--cccsssssccc---%d",classstr);
//    //  NSLog(@"----sqlarr--%@",sqlArr);
//    for (int i = 0; i<sqlArr.count; i++) {
//        BooksInfo * bkInfo=[[BooksInfo alloc] init];
//        bkInfo.bookName=[[sqlArr objectAtIndex:i] objectForKey:@"BooKName"];
//        bkInfo.documentPath=[NSString stringWithFormat:@"%@/%@.pdf",documentsDirectory,bkInfo.bookName];
//        //bkInfo.bookUrl =(NSMutableString *)[[sqlArr objectAtIndex:i] objectForKey:@"Path"];
//        bkInfo.bookID =[[[sqlArr objectAtIndex:i] objectForKey:@"BookID"] intValue];
//        NSString *urlstr=[NSString stringWithFormat:DownLoad_bookUrl_Book,[[sqlArr objectAtIndex:i] objectForKey:@"Path"]];
//        //       NSLog(@"lklklklklkklklkklkllkl--%@",urlstr);
//
//        NSString *url=[urlstr stringByReplacingOccurrencesOfString:@"$" withString:@"/"];
//        bkInfo.urlStr=(NSMutableString *)[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//        // NSLog(@"docfile=%@", bkInfo.documentPath);
//        [catearr addObject:bkInfo];
//    }
//
//    //   NSLog(@";;;;;%@\n%@",self.myBooks.categoryList,catearr);
//
//}
//-(void)selectallCategoryclass:(NSMutableArray *)CateIDarr{
//    NSMutableArray *pulicArr=[CateIDarr copy];
//    NSLog(@"1111111-------count-----%d",pulicArr.count);
//
//    for (int i = 0; i<[pulicArr count]; i++) {
//        self.CategoryID2=[pulicArr objectAtIndex:i];
//        NSLog(@"----%@",self.CategoryID2);
//        NSString *selectSql2=[NSString stringWithFormat:Select_sql_BookCategoryName,[self.CategoryID2 intValue]];
//     NSMutableArray * idArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql2]; //3级分类目录
//        NSLog(@"idarr---%@",idArr);
//
//        if (idArr.count<1) {
//            NSLog(@"       =========00000---%@",self.CategoryID2);
//            [self addBooksInfo:self.CategoryID2 isend:NO];
//
//        }
//
//        else{
//            for (int i = 0; i<[idArr count]; i++) {
//
//            NSString *idstr=[[idArr objectAtIndex:i] objectForKey:@"CategoryID"];
//            NSString *selectSql3=[NSString stringWithFormat:Select_sql_BookCategoryName,[idstr intValue]];
//            NSMutableArray * idArr2=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql3]; //4级分类目录
//            NSLog(@"       break======%@",idstr);
//            NSLog(@"idarr2---%@",idArr2);
//            if (idArr2.count<1) {
//                [self addBooksInfo:idstr isend:NO];
//                NSLog(@"444444");
//            }else{
//                for (int i = 0; i<[idArr2 count]; i++) {
//
//                NSString *idstr2=[[idArr2 objectAtIndex:i] objectForKey:@"CategoryID"];
//                NSString *selectSql4=[NSString stringWithFormat:Select_sql_BookCategoryName,[idstr2 intValue]];
//                NSMutableArray * idArr3=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql4]; //5级分类目录
//                    NSLog(@"       break======%@",idstr2);
//                NSLog(@"idarr3---%@",idArr3);
//
//                if (idArr3.count<1) {
//                    [self addBooksInfo:idstr2 isend:NO];
//                }else
//                {
//
//                }
//            }
//            }
//        }
//        }
//        [self addBooksInfo:@"end" isend:YES];
//    }
//
//
//}

/******/



//-(void)selecta:(NSMutableArray *)CateIDarr{
//
//    NSLog(@"写入plist文件路径----");
//    NSMutableArray *pulicArr=[CateIDarr copy];
//    NSLog(@"22222------count---%d",pulicArr.count);
//
//    NSMutableArray *allDataArr=[NSMutableArray array];
//
//    for (int i = 0; i<[pulicArr count]; i++) {
//
//        NSMutableArray *tempArr0=[NSMutableArray array];
//        NSMutableDictionary *tempDic0=[NSMutableDictionary dictionaryWithObjectsAndKeys:[CategoryArray objectAtIndex:i],@"name",@"0",@"number", nil];
//
//        self.CategoryID2=[pulicArr objectAtIndex:i];
//        NSLog(@"----%@",self.CategoryID2);
//        NSString *selectSql2=[NSString stringWithFormat:Select_sql_BookCategoryName,[self.CategoryID2 intValue]];
//        NSMutableArray * idArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql2]; //3级分类目录
//        NSLog(@"idarr---%@",idArr);
//
//        if (idArr.count<1) {
//
//
//        }
//
//        else{
//            for (int i = 0; i<[idArr count]; i++) {
//                NSLog(@"3333---count---%d",idArr.count);
//                NSMutableArray *tempArr1=[NSMutableArray array];
//                NSMutableDictionary *tempDic1=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"  %@",[[idArr objectAtIndex:i] objectForKey:@"CategoryName"]],@"name",@"1",@"number", nil];
//
//                [tempArr0 addObject:tempDic1];
//
//                NSString *idstr=[[idArr objectAtIndex:i] objectForKey:@"CategoryID"];
//                NSString *selectSql3=[NSString stringWithFormat:Select_sql_BookCategoryName,[idstr intValue]];
//                NSMutableArray * idArr2=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql3]; //4级分类目录
//                NSLog(@"       break======%@",idstr);
//                NSLog(@"idarr2-33333--%@",idArr2);
//                if (idArr2.count<1) {
//                    //[self addBooksInfo:idstr isend:NO];
//                    NSLog(@"444444");
//                }else{
//                    for (int i = 0; i<[idArr2 count]; i++) {
//
//               //         NSMutableArray *tempArr2=[NSMutableArray array];
//                        NSMutableDictionary *tempDic2=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"    %@",[[idArr2 objectAtIndex:i] objectForKey:@"CategoryName"]],@"name",@"2",@"number", nil];
//
//                        [tempArr1 addObject:tempDic2];
//
//                        NSString *idstr2=[[idArr2 objectAtIndex:i] objectForKey:@"CategoryID"];
//                        NSString *selectSql4=[NSString stringWithFormat:Select_sql_BookCategoryName,[idstr2 intValue]];
//                        NSMutableArray * idArr3=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql4]; //5级分类目录
//                        NSLog(@"       break======%@",idstr2);
//                        NSLog(@"idarr3---%@",idArr3);
//
//                        if (idArr3.count<1) {
//                        }else
//                        {
//
//                        }
//                    }
//                }if (tempArr1.count>0) {
//                    [tempDic1 setObject:tempArr1 forKey:@"Objects"];
//                    tempArr1=nil;
//                }
//
//            }
//            if (tempArr0.count>0) {
//                [tempDic0 setObject:tempArr0 forKey:@"Objects"];
//                tempArr0=nil;
//
//            }
//                    }
//        //[self addBooksInfo:@"end" isend:YES];
//        if (tempDic0.count>0) {
//            [allDataArr addObject:tempDic0];
//            tempDic0=nil;
//        }
//
//    }
//
//NSDictionary *allDataDic=[NSDictionary dictionaryWithObject:allDataArr forKey:@"Objects"];
//
//NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//NSString * documentDirectory=[paths objectAtIndex:0];
//NSString *localPath = [documentDirectory stringByAppendingPathComponent:@"dataPlist.plist"];
//[allDataDic writeToFile:localPath atomically:YES];
//
//NSLog(@"写入plist文件路径-----%@",localPath);
//}



- (void)viewWillAppear:(BOOL)animated
{
    //
    //    [self performSelectorInBackground:@selector(backGroundLoadView) withObject:nil];
    //    [self.tableView reloadData];
    //    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    CGRect frame = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.view.frame = frame;//重新定义frame
    
    UIInterfaceOrientation to=self.interfaceOrientation;
    if(to == UIDeviceOrientationLandscapeLeft || to == UIDeviceOrientationLandscapeRight)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
        //   [bgImageView setImage:[UIImage imageNamed:@"bg_h.png"]];
        
        //   [serarchBar setFrame:CGRectMake(400, 1, 250, 40)];
        
        [setting setFrame:CGRectMake(900, 7, 25, 25)];
        [myBookBtn setFrame:CGRectMake(900-80, 7, 25, 25)];
        [self reloadView];
        [self.tableView reloadData];
        NavBg.frame=CGRectMake(0, 0, frame.size.width, 50);
        self.tableView.frame=CGRectMake(10,50,frame.size.width-20, frame.size.height-56);
        self.searchBar.frame=CGRectMake(frame.size.width-550, 1, 250, 40);
    }else if ([UIApplication sharedApplication].statusBarOrientation==UIDeviceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation ==UIDeviceOrientationPortraitUpsideDown){
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
        //   [serarchBar setFrame:CGRectMake(340, 1, 250, 40)];
        
        [setting setFrame:CGRectMake(710, 7, 25, 25)];
        [self reloadView];
        [myBookBtn setFrame:CGRectMake(650, 7, 25, 25)];
        [self.tableView reloadData];
        NavBg.frame=CGRectMake(0, 0, frame.size.width, 50);
        self.tableView.frame=CGRectMake(10,50,frame.size.width-20, frame.size.height-56);
        self.searchBar.frame=CGRectMake(frame.size.width-418, 1, 250, 40);
    }

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.view.frame = frame;//重新定义frame
    NSInteger yy=0;
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)     {
        yy=44;
    }
    isOpen=YES;
    catearr=[[NSMutableArray alloc]initWithCapacity:0];//临时存储 二级类里的书
//    NSArray *bookinfoarr=[NSArray new];
//    bookinfoarr=[self selectBookInfo];
    NSLog(@"//////%d\n%@",index,IPurl);
    bookJsonArr=[NSMutableArray array];
    
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"newbg.png"]]];
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
    }else
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(10, 3, 40, 34)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"newback.png"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backHome) forControlEvents:UIControlEventTouchUpInside];
    
    _searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(frame.size.width-418, 1, 250, 40)];
    _searchBar.placeholder=@"输入书名";
    _searchBar.delegate=self;
   // _searchBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.navigationController.navigationBar addSubview:_searchBar];
    //    if ([[[UIDevice currentDevice] systemName] floatValue] <7.0) {
    //        UIView * bg_search=[_searchBar.subviews objectAtIndex:0];
    //        [bg_search removeFromSuperview];
    //    }
    
    setting=[UIButton buttonWithType:1];
    [setting setFrame:CGRectMake(frame.size.width-68, 4, 30, 30)];
    [setting setBackgroundImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:setting];
    [setting addTarget:self action:@selector(settingBtn) forControlEvents:UIControlEventTouchUpInside];

    /***********************此方法可作废，此功能已在coverFlow类里实现******/
    //    if (bookinfoarr.count<1) {
    //        MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //        mbp.labelText = @"加载数据中,请稍后...";
    //        // [self.view setUserInteractionEnabled:NO];
    //        [self.navigationController.view setUserInteractionEnabled:NO];
    //        [self AsihttpRequest:[NSString stringWithFormat:String_IP_Url,self.IPurl]];
    //    }
    /*********************************************************************/
    
    _myBooks=[[Books alloc] init];
    _myBooks.categoryList=[NSMutableArray array];
    
    _myBooksinfo=[[Books alloc] init];
    _myBooksinfo.categoryList=[NSMutableArray array];
    
    // self.myBooks.categoryList=CategoryArray;
    //[self reloadView];
    // [self performSelectorInBackground:@selector(backGroundLoadView) withObject:nil];
    
    
    NSLog(@"========;;;;;;%@",CategoryID);
    
    //TODO:这里用的tableView的风格是Grouped的，大小相对设置的大一些，使其看来下像plain风格
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(10,50,frame.size.width-20, frame.size.height-100+44) style:UITableViewStylePlain];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
   //    [self.tableView reloadData];
  //  [MBProgressHUD hideHUDForView:self.view  animated:YES];
    
    
    NavBg=[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
    NavBg.backgroundColor=[UIColor clearColor];
    NavBg.alpha=0.7;
     NavBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    NavList=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, (frame.size.width-200), 50)];
    [NavList setTextColor:[UIColor whiteColor]];
    [NavBg addSubview:NavList];
    [self.view addSubview:NavBg];
    UIFont *font = [UIFont boldSystemFontOfSize:28.0];
    NavList.font = font;
    NavList.adjustsFontSizeToFitWidth = YES;
    NavList.minimumFontSize = 8.0f;
    NavList.text=[NSString stringWithFormat:@"%@",name ];
    UserLabel=[[UILabel alloc]initWithFrame:CGRectMake(frame.size.width-150, 0, 150, 50)];
    [UserLabel setTextColor:[UIColor whiteColor]];
    [NavBg addSubview:UserLabel];
    UserLabel.adjustsFontSizeToFitWidth = YES;
    UserLabel.minimumFontSize = 8.0f;
    UIFont *font1 = [UIFont boldSystemFontOfSize:20.0];
    UserLabel.font = font1;
    NSString *selectSql=[NSString stringWithFormat:Select_sql_UserInfo];
	NSMutableArray *uuidArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];
    
    if (uuidArr.count>0) {
        UserLabel.text=[NSString stringWithFormat:@"用户：%@",[[uuidArr objectAtIndex:0] objectForKey:@"UserID"]];
    }
    UserLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    myBookBtn=[UIButton buttonWithType:1];
    [myBookBtn setFrame:CGRectMake(650, 7, 25, 25)];
    [myBookBtn setBackgroundImage:[UIImage imageNamed:@"bookButton.png"] forState:UIControlStateNormal];
    [myBookBtn addTarget:self action:@selector(myBookslef:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:myBookBtn];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeProgressView) name:ASY_RequestFinishObsever_Info object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DownFaild:) name:ASY_RequestFailedObsever_Info object:nil];
}

-(BOOL)isHaveThisItem:(BooksInfo *)binfo
{
    NSLog(@"////////////////=============444---%@",self.searchArray);
    for (BooksInfo * info in self.searchArray) {
        
        if ([info.bookName isEqual:binfo]) {
            return YES;
        }
    }
    return NO;
}

-(void)doActionSearchBooks:(NSString *)text
{
    
    [self.searchArray removeAllObjects];
    
    for (CategoryBook * cate in self.myBooks.categoryList) {
        for (NSArray * temp in cate.bookList) {
            for (BooksInfo * bInfo in temp) {
                NSString *searchString = bInfo.bookName;
                NSRange   matchedRange = NSMakeRange(NSNotFound, 0UL);
                matchedRange=[searchString rangeOfRegex:text inRange:NSMakeRange(0, searchString.length)];
                
                if (matchedRange.location!=NSNotFound && ![self isHaveThisItem:bInfo]) {
                    [self.searchArray addObject:bInfo];
                }
            }
            
        }
        
        
    }
    
    
    
}

-(void)didSearchMethodWithSearch:(UISearchBar *)searchBar
{
    
    if (_searchArray==nil) {
        _searchArray=[[NSMutableArray alloc] init];
    }
    
    [self doActionSearchBooks:searchBar.text];
    
    if (self.popover==nil) {
        BookSearchViewController * bookSearch=[[BookSearchViewController alloc] init];
        bookSearch.delegate=self;
        bookSearch.dataArray=[NSMutableArray arrayWithArray:self.searchArray];
        UINavigationController * navController=[[UINavigationController alloc] initWithRootViewController:bookSearch];
        
        _popover=[[UIPopoverController alloc] initWithContentViewController:navController];
        _popover.popoverContentSize=CGSizeMake(480, 700);
        _popover.delegate=self;
        [_popover presentPopoverFromRect:searchBar.frame inView:searchBar.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        navController.navigationBarHidden=YES;
    }
    else{
        
        UINavigationController * nav=(UINavigationController *)[self.popover contentViewController];
        BookSearchViewController * bookSearch=(BookSearchViewController *)[nav topViewController];
        bookSearch.dataArray=[NSMutableArray arrayWithArray:self.searchArray];
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
    // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // [defaults setBool:swith.on forKey:@"swith"];
    return YES;
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.popover dismissPopoverAnimated:YES];
    [self.view endEditing:YES];
    self.searchBar.text=nil;
    self.popover = nil;
    [self.searchBar resignFirstResponder];
    [self.settingPop dismissPopoverAnimated:YES];
    
}

#pragma mark 搜索进入pdf阅读
-(void)didSelectBookInfo:(BooksInfo *)bookInfo withOther:(NSDictionary *)other
{
    NSString *fileTmp=[Decrypt dFlie:bookInfo.bookName];
    BOOL dectyotOk =[[NSFileManager defaultManager] fileExistsAtPath:fileTmp];
    
    BOOL have=   [[NSFileManager defaultManager] fileExistsAtPath:bookInfo.documentPath];
    [self.searchBar resignFirstResponder];
    if (have==YES) {
        self.searchSelectBook=bookInfo;
        [self.popover dismissPopoverAnimated:YES];
        [self.view endEditing:YES];
        self.searchBar.text=nil;
        self.popover = nil;
        [self.searchBar resignFirstResponder];
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
            
        }
        self.lastReadBookInfo=bookInfo;
        
        
        //继续上次阅读的地方加载
        // ReaderDocument *document = [ReaderDocument withDocumentFilePath:self.searchSelectBook.documentPath password:nil];
        
        
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
            //MBProgressHUD *mpb=[MBProgressHUD showHUDAddedTo:sender animated:YES];
          //  mpb.labelText=@"下载中";
            bookInfo.bLoad=YES;
            [self.tableView reloadData];

            [asydownload requestDownloadDataWithNewObject:bookInfo delegate:self];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeProgressView) name:ASY_RequestFinishObsever_Info object:nil];
            
        }else{
            
            [self showError:@"请检查网络链接"];
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    NSLog(@"%@",self.myBooks.categoryList);
    
    
    CategoryBook *cateBook;
    if (self.myBooks.categoryList.count<1) {
        return 0;
    }
    cateBook= [self.myBooks.categoryList objectAtIndex:section];
    if ([self.myBooks.categoryList count]<1 ) {
        //if (cateBook.bookList.count<1){
        return 0;
    }else
    {
        cateBook= [self.myBooks.categoryList objectAtIndex:section];
        return [cateBook.bookList count];
        NSLog(@"------oooo----%lu",(unsigned long)[cateBook.bookList count]);
        
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  return 150;
    return 260;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryBook *cateBook;
    if (self.myBooks.categoryList.count<1) {
        return nil;
    }
    cateBook=[self.myBooks.categoryList objectAtIndex:indexPath.section];
    
    NSLog(@"==cccccccccc==%@,\n%@",self.myBooks.categoryList,cateBook);
    
    //这个数组就是每行cell众书的个数
    NSArray * tempItems=[cateBook.bookList objectAtIndex:indexPath.row];
    NSLog(@"====%@,\n%@",cateBook.bookList,cateBook);
    static NSString * cellIndentifier=@"cellIndentifier";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        //        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        //        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768-36, 150)];
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        // UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768-36, 260)];
//        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 232, self.view.bounds.size.width, 50)];
//        UIImage *img=[UIImage imageNamed:@"lastcell.png"];
//        img=[img stretchableImageWithLeftCapWidth:100 topCapHeight:0];
//        imageView.image=img;//[UIImage imageNamed:@"lastcell.png"];
//        [cell.contentView addSubview:imageView];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    for(UIView *mylabelview in [cell.contentView subviews])
    {
        if ([mylabelview isKindOfClass:[UIImageView class]]) {
            [mylabelview removeFromSuperview];
        }
    }
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 232, self.view.frame.size.width, 50)];
    UIImage *img=[UIImage imageNamed:@"lastcell.png"];
    img=[img stretchableImageWithLeftCapWidth:100 topCapHeight:0];
    imageView.image=img;//[UIImage imageNamed:@"lastcell.png"];
    [cell.contentView addSubview:imageView];

    for (UIView *vs in cell.contentView.subviews) {
        if ([vs isKindOfClass:[UIButton class]]) {
            [vs removeFromSuperview];
        }
    }
    for (int i=0; i<[tempItems count]; i++) {
        
        BooksInfo * book=[tempItems objectAtIndex:i];
        UIButton * btn=[UIButton buttonWithType:1];
        // [btn setFrame:CGRectMake(i*100+20, 30, 85, 110)];
        [btn setFrame:CGRectMake(i*177+23, 30+12, 80*2, 110*2-20)];
        btn.userInfo_Ext=[NSDictionary dictionaryWithObjectsAndKeys:book,@"kBookInfo", nil];

        NSLog(@"有木有下载过这个文件——%@",book.documentPath);
        BOOL isNew =   [[NSFileManager defaultManager] fileExistsAtPath:book.documentPath];
        if (isNew) {
            [btn setBackgroundImage:[UIImage imageNamed:@"booknew.png"] forState:UIControlStateNormal];
            [btn setEnabled:YES];
            book.bLoad=NO;
        }else{
            
            [btn setBackgroundImage:[UIImage imageNamed:@"newBook1.png"] forState:UIControlStateNormal];
            
        }
        if (book.bLoad) {
//            UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(10, 80, 150, 30)];
//            bgView.backgroundColor=[UIColor blackColor];
//            bgView.alpha=0.7;
//            CALayer *l = [bgView layer];   //获取ImageView的层
//            [l setMasksToBounds:YES];
//            [l setCornerRadius:3.0];
//            [bgView addSubview:book.progressView];
           // [btn addSubview:book.progressView];
            MBProgressHUD *mpb=[MBProgressHUD showHUDAddedTo:btn animated:YES];
            mpb.labelText=@"下载中";
        }
            
        
        
        
        //      }
        
        // [btn setTitle:book.bookName forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didSelectBookInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [longPressGestureRecognizer setMinimumPressDuration:0.8f];
        [longPressGestureRecognizer setAllowableMovement:50.0];
        if ([self.MybookType isEqualToString:@"YES"]) {
            [longPressGestureRecognizer addTarget:self action:@selector(canlegestureRecognizerHandle:)];
            
        }else if ([self.MybookType isEqualToString:@"YES1"])
        {
             [longPressGestureRecognizer addTarget:self action:@selector(markgestureRecognizerHandle:)];
        }
        else{
            
            [longPressGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
        }
        if (isNew) {
            [btn addGestureRecognizer:longPressGestureRecognizer];
            
        }
        NSLog(@"--cacacaca--%@",book.bookName);
        NSLog(@"---url--%@",book.urlStr);
        NSArray * labarr=[book.bookName componentsSeparatedByString:@"【"];
        UILabel *nameLabel=[[UILabel alloc] init];
        [nameLabel setFrame:CGRectMake(15, 70, 135, 60)];
        [nameLabel setText:[[labarr objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setNumberOfLines:0];
        [nameLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:16]];
        [nameLabel setLineBreakMode:NSLineBreakByWordWrapping];
        NSLog(@"----bnbnbnnbnbnbnnbnnbnb---%@--",[[UIFont familyNames] objectAtIndex:i]);
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[JGUtil colorWithHexString:@"5d3a12"]];
        [btn addSubview:nameLabel];
        
        UILabel *nameLabel1=[[UILabel alloc] init];
        [nameLabel1 setFrame:CGRectMake(15, 140, 135, 60)];
        if (labarr.count >1) {
            [nameLabel1 setText:[[NSString stringWithFormat:@"【%@",[labarr objectAtIndex:1]] stringByReplacingOccurrencesOfString:@"$" withString:@"/"]];
            [nameLabel1 setTextAlignment:NSTextAlignmentCenter];
            [nameLabel1 setNumberOfLines:0];
            [nameLabel1 setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
            [nameLabel1 setLineBreakMode:NSLineBreakByWordWrapping];
            NSLog(@"----bnbnbnnbnbnbnnbnnbnb---%@--",[[UIFont familyNames] objectAtIndex:i]);
            [nameLabel1 setBackgroundColor:[UIColor clearColor]];
            [nameLabel1 setTextColor:[JGUtil colorWithHexString:@"5d3a12"]];
            [btn addSubview:nameLabel1];
        }
        
    }
    
    return cell;
}

-(void)canlegestureRecognizerHandle:(UILongPressGestureRecognizer*)sender{
 
    UIButton *btn=(UIButton*)sender.view;
    BooksInfo *book=(BooksInfo *)[btn.userInfo_Ext objectForKey:@"kBookInfo"];
  //  NSLog(@"[[[[[%d",  book.bookID);
    sbookId=book.bookID;
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"取消收藏");
        UIAlertView *alt=[[UIAlertView alloc] initWithTitle:@"收藏提示" message:@"将此书移出我的书架？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alt.tag=101;
        [alt show];
    }
    
}

-(void)markgestureRecognizerHandle:(UILongPressGestureRecognizer*)sender{
    
    UIButton *btn=(UIButton*)sender.view;
    BooksInfo *book=(BooksInfo *)[btn.userInfo_Ext objectForKey:@"kBookInfo"];
    //  NSLog(@"[[[[[%d",  book.bookID);
    sbookId=book.bookID;
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"取消收藏");
        UIAlertView *alt=[[UIAlertView alloc] initWithTitle:@"收藏提示" message:@"将此书移出我的书架？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alt.tag=1001;
        [alt show];
    }
    
}


-(void)gestureRecognizerHandle:(UILongPressGestureRecognizer*)sender{
    
    UIButton *btn=(UIButton*)sender.view;
     BooksInfo *book=(BooksInfo *)[btn.userInfo_Ext objectForKey:@"kBookInfo"];
    // NSLog(@"[[[[[%d",  book.bookID);
    sbookId=book.bookID;
    bookName=book.bookName;
    if (sender.state == UIGestureRecognizerStateBegan) {
    
        NSLog(@"加入收藏");
        UIAlertView *alt=[[UIAlertView alloc] initWithTitle:@"收藏提示" message:@"将此书收藏到我的书架或者删除本地缓存！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"收藏", @"删除",nil];
        alt.tag=202;
        [alt show];
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==101) {
        if (buttonIndex ==1) {
            NSString *canleBookSql=[NSString stringWithFormat:update_sql_canleBookCover,sbookId];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:canleBookSql];
            [self reloadView];
            [self.tableView reloadData];
            return ;
        }
        
    }
    if (alertView.tag==1001) {
        if (buttonIndex ==1) {
            NSString *canleBookSql=[NSString stringWithFormat:update_sql_canleBookMark,sbookId];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:canleBookSql];
            [self reloadView];
            [self.tableView reloadData];
            return ;
        }
        
    }
    if (alertView.tag==202) {
        if (buttonIndex ==0) {
            NSLog(@"%@",alertView.title);
        }
        else if (buttonIndex==1) {
           NSLog(@"%@",alertView.title);
            NSString *keepBookSql=[NSString stringWithFormat:update_sql_BookCover,sbookId];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:keepBookSql];

        }else if(buttonIndex ==2){
            
            NSLog(@"%@",alertView.title);
            // 清除本地配置数据
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            
            NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/fileTemp/%@",bookName]];
            
            NSString *mapDecomentPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",bookName]];
            BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
            BOOL cRet = [fileMgr fileExistsAtPath:mapDecomentPath];
            if (bRet) {
                
                //
                NSError *err;
                
                [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
            }
            if (cRet) {
                 NSError *err;
                [fileMgr removeItemAtPath:mapDecomentPath error:&err];
                NSString *keepBookSql=[NSString stringWithFormat:chanceDownload_sql_book,sbookId];
                [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:keepBookSql];
            }
   

            [self.tableView reloadData];
        }
        return ;
    }
    if (alertView.tag ==303) {
        if (buttonIndex ==0) {
           // NSLog(@"---%d",self.navigationController.viewControllers.count);
            if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
            [self.navigationController dismissModalViewControllerAnimated:YES];
            }else{
                
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
    }
}
-(void)backGroundLoadView{
    
    [self reloadView];
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    
}
-(void)reloadView{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSArray *pathcache=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    //creates paths so that you can pull the app's path from it
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsCacheDirectory = [pathcache objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"url.plist"];
    NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:dataPath];
    NSString *urlStr=[NSString stringWithFormat:@"%@",[dTmp valueForKey:@"url"]];
    
    NSLog(@"---URlplist--%@,%@",urlStr,dTmp);
    
    {
        NSLog(@"没有2级分类");
        _myBooks=[[Books alloc] init];
        _myBooks.categoryList=[NSMutableArray array];
        CategoryBook * cate=[[CategoryBook alloc] init];
        cate.bookList=[NSMutableArray array];
        NSLog(@"-------222%@,%d",CategoryID,index);
   
        
        if ([self.MybookType isEqualToString:@"YES"]) {
            NSString *selectBookSql=[NSString stringWithFormat:select_sql_CollectedBook];
            NSMutableArray *sqlArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql];
//            NSString *selectBookSql1=[NSString stringWithFormat:select_sql_MarkedBook];
//            NSMutableArray *sqlArr1=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql1];
//            NSString *selectBookSql2=[NSString stringWithFormat:select_sql_NotedBook];
//            NSMutableArray *sqlArr2=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql2];
            NSLog(@"--cccsssccc---%@",sqlArr);
            if ((sqlArr.count)<1) {
                UIAlertView *alt=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"还未收藏书籍，可到书架中长按书籍选择添加收藏！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                alt.tag=303;
                [alt show];
                return ;
            }
            for (int i = 0; i<sqlArr.count; i++) {
                BooksInfo * bkInfo=[[BooksInfo alloc] init];
                bkInfo.progressView=[[MBProgressHUD alloc] initWithFrame:CGRectMake(12, 90, 140, 5)];
               // [bkInfo.progressView setProgressViewStyle:UIProgressViewStyleDefault];
               // bkInfo.progressView.transform = CGAffineTransformMakeScale(1.0f,5.0f);
                bkInfo.bLoad=NO;
                bkInfo.bCollect=YES;
               // CALayer *l = [bkInfo.progressView layer];   //获取ImageView的层
               // [l setMasksToBounds:YES];
               // [l setCornerRadius:3.0];
                
                bkInfo.bookName=[[sqlArr objectAtIndex:i] objectForKey:@"BooKName"];
                bkInfo.documentPath=[NSString stringWithFormat:@"%@/%@",documentsCacheDirectory,bkInfo.bookName];
                bkInfo.bookID =[[[sqlArr objectAtIndex:i] objectForKey:@"BookID"] intValue];
                NSString * url=[NSString stringWithFormat:@"%@%@",urlStr,[[sqlArr objectAtIndex:i] objectForKey:@"Path"]];
                NSLog(@"url========%@",url);
                // NSString *urlstr= [url stringByReplacingOccurrencesOfString:@"$" withString:@"/"];
                // NSLog(@"lklklklklkklklkklkllkl--%@",urlstr);
                bkInfo.urlStr=(NSMutableString *)[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"docfile=%@", bkInfo.documentPath);
                bkInfo.bookKey=[[sqlArr objectAtIndex:i] objectForKey:@"BookKey"];
                [cate.bookList addObject:bkInfo];
                docment=nil;
                docment=bkInfo.documentPath;
            }
//            for (int i = 0; i<sqlArr2.count; i++) {
//                BooksInfo * bkInfo=[[BooksInfo alloc] init];
//                bkInfo.progressView=[[MBProgressHUD alloc] initWithFrame:CGRectMake(12, 90, 140, 5)];
//                // [bkInfo.progressView setProgressViewStyle:UIProgressViewStyleDefault];
//                // bkInfo.progressView.transform = CGAffineTransformMakeScale(1.0f,5.0f);
//                bkInfo.bLoad=NO;
//                bkInfo.bNote=YES;
//                bkInfo.bCollect=NO;
//                bkInfo.bMark=NO;
//                // CALayer *l = [bkInfo.progressView layer];   //获取ImageView的层
//                // [l setMasksToBounds:YES];
//                // [l setCornerRadius:3.0];
//                
//                bkInfo.bookName=[[sqlArr2 objectAtIndex:i] objectForKey:@"BooKName"];
//                bkInfo.documentPath=[NSString stringWithFormat:@"%@/%@",documentsCacheDirectory,bkInfo.bookName];
//                bkInfo.bookID =[[[sqlArr2 objectAtIndex:i] objectForKey:@"BookID"] intValue];
//                NSString * url=[NSString stringWithFormat:@"%@%@",urlStr,[[sqlArr2 objectAtIndex:i] objectForKey:@"Path"]];
//                NSLog(@"url========%@",url);
//                // NSString *urlstr= [url stringByReplacingOccurrencesOfString:@"$" withString:@"/"];
//                // NSLog(@"lklklklklkklklkklkllkl--%@",urlstr);
//                bkInfo.urlStr=(NSMutableString *)[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                NSLog(@"docfile=%@", bkInfo.documentPath);
//                bkInfo.bookKey=[[sqlArr2 objectAtIndex:i] objectForKey:@"BookKey"];
//                [cate.bookList addObject:bkInfo];
//                docment=nil;
//                docment=bkInfo.documentPath;
//            }

           
        }else if([self.MybookType isEqualToString:@"YES1"]){
            NSString *selectBookSql1=[NSString stringWithFormat:select_sql_MarkedBook];
            NSMutableArray *sqlArr1=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql1];
            if ((sqlArr1.count)<1) {
                UIAlertView *alt=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"还未添加书签，可在阅读书籍时添加书签！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                alt.tag=303;
                [alt show];
                return ;
            }
            
            for (int i = 0; i<sqlArr1.count; i++) {
                BooksInfo * bkInfo=[[BooksInfo alloc] init];
                bkInfo.progressView=[[MBProgressHUD alloc] initWithFrame:CGRectMake(12, 90, 140, 5)];
                // [bkInfo.progressView setProgressViewStyle:UIProgressViewStyleDefault];
                // bkInfo.progressView.transform = CGAffineTransformMakeScale(1.0f,5.0f);
                bkInfo.bLoad=NO;
                bkInfo.bMark=YES;
                bkInfo.bNote=NO;
                bkInfo.bCollect=NO;
                
                
                // CALayer *l = [bkInfo.progressView layer];   //获取ImageView的层
                // [l setMasksToBounds:YES];
                // [l setCornerRadius:3.0];
                
                bkInfo.bookName=[[sqlArr1 objectAtIndex:i] objectForKey:@"BooKName"];
                bkInfo.documentPath=[NSString stringWithFormat:@"%@/%@",documentsCacheDirectory,bkInfo.bookName];
                bkInfo.bookID =[[[sqlArr1 objectAtIndex:i] objectForKey:@"BookID"] intValue];
                NSString * url=[NSString stringWithFormat:@"%@%@",urlStr,[[sqlArr1 objectAtIndex:i] objectForKey:@"Path"]];
                NSLog(@"url========%@",url);
                // NSString *urlstr= [url stringByReplacingOccurrencesOfString:@"$" withString:@"/"];
                // NSLog(@"lklklklklkklklkklkllkl--%@",urlstr);
                bkInfo.urlStr=(NSMutableString *)[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"docfile=%@", bkInfo.documentPath);
                bkInfo.bookKey=[[sqlArr1 objectAtIndex:i] objectForKey:@"BookKey"];
                [cate.bookList addObject:bkInfo];
                docment=nil;
                docment=bkInfo.documentPath;
            }


        }
        else{
            NSString *selectBookSql=[NSString stringWithFormat:select_sql_indexBookInfo,index];
            NSMutableArray *sqlArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql];
            NSLog(@"--cccsssccc---%@",sqlArr);
            for (int i = 0; i<sqlArr.count; i++) {
                BooksInfo * bkInfo=[[BooksInfo alloc] init];
                bkInfo.progressView=[[MBProgressHUD alloc] initWithFrame:CGRectMake(12, 90, 140, 5)];
                //[bkInfo.progressView setProgressViewStyle:UIProgressViewStyleDefault];
               // bkInfo.progressView.transform = CGAffineTransformMakeScale(1.0f,5.0f);
                bkInfo.bLoad=NO;

               // CALayer *l = [bkInfo.progressView layer];   //获取ImageView的层
               //            [l setMasksToBounds:YES];
                //            [l setCornerRadius:3.0];
                
                bkInfo.bookName=[[sqlArr objectAtIndex:i] objectForKey:@"BooKName"];
                bkInfo.documentPath=[NSString stringWithFormat:@"%@/%@",documentsCacheDirectory,bkInfo.bookName];
                bkInfo.bookID =[[[sqlArr objectAtIndex:i] objectForKey:@"BookID"] intValue];
                NSString * url=[NSString stringWithFormat:@"%@%@",urlStr,[[sqlArr objectAtIndex:i] objectForKey:@"Path"]];
                NSLog(@"url========%@",url);
                // NSString *urlstr= [url stringByReplacingOccurrencesOfString:@"$" withString:@"/"];
                // NSLog(@"lklklklklkklklkklkllkl--%@",urlstr);
                bkInfo.urlStr=(NSMutableString *)[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"docfile=%@", bkInfo.documentPath);
                bkInfo.bookKey=[[sqlArr objectAtIndex:i] objectForKey:@"BookKey"];
                [cate.bookList addObject:bkInfo];
                docment=nil;
                docment=bkInfo.documentPath;
                
            }
        }
        [_myBooks.categoryList addObject:cate];
        NSLog(@";;;;;%@\n%@",self.myBooks.categoryList,cate);
        
    }
    self.myBooks=[self sortBooksInfo:self.myBooks];
    
    //   [self.tableView reloadData];
}
-(void)removeProgressView
{
    
    [self.tableView reloadData];
    
}
-(void)DownFaild:(NSNotification*)notify
{
    BooksInfo * info=(BooksInfo *)notify.userInfo;

    NSString *str=[NSString stringWithFormat:@"%@下载失败",info.bookName];
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:str
												  delegate:self
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil];
	[alert show];
   
    CategoryBook *cateBook;
    if (self.myBooks.categoryList.count<1) {
        [self.tableView reloadData];
        return;
    }
    for (NSInteger i=0; i<self.myBooks.categoryList.count; i++) {
        cateBook=[self.myBooks.categoryList objectAtIndex:i];
        for (NSInteger n=0; n<cateBook.bookList.count; n++) {
             NSArray * tempItems=[cateBook.bookList objectAtIndex:n];
            for (int m=0; m<[tempItems count]; m++) {
                
                BooksInfo * book=[tempItems objectAtIndex:m];
                if (book.bookID==info.bookID) {
                    book.bLoad=NO;
                    [self.tableView reloadData];
                    return;
                }
                              
            }
        }
    }
    


}

//TODO:---阅读
-(void)didSelectBookInfo:(UIButton *)sender
{
    
    
    BooksInfo * book=[sender.userInfo_Ext objectForKey:@"kBookInfo"];
    NSLog(@"------%@,,,,,,,,,,,%d\n%@",book.documentPath,book.bookID,book.urlStr);
    NSLog(@"---%@",book.bookKey);
    
    /*
     
     NSFileManager *fileManager = [NSFileManager defaultManager];
     //在这里获取应用程序Documents文件夹里的文件及文件夹列表
     NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentDir = [documentPaths objectAtIndex:0];
     NSError *error = nil;
     NSArray *fileList = [[NSArray alloc] init];
     //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
     fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
     */
    //    NSString * ePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //
    //    NSString * doc=[ePath stringByAppendingPathComponent:@"fileTemp"];
    //    NSString * fileTmp=[doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",book.bookName]];
    NSString *fileTmp=[Decrypt dFlie:book.bookName];
  NSString *   exestr = [book.documentPath pathExtension];
    BOOL dectyotOk =[[NSFileManager defaultManager] fileExistsAtPath:fileTmp];
    BOOL have=   [[NSFileManager defaultManager] fileExistsAtPath:book.documentPath];
    ReaderDocument *document;
    if (have==YES) {
        NSLog(@"有这个文件");
        //  [sender setEnabled:YES];
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
            
            NSString *decryptBookPath = [Decrypt filePath:book.documentPath DecryptKey:nil fileName:book.bookName];//解密文件保存到新路径；//4f284b0e-054a-4041-9a27-f58d8c37baa3
            if ([exestr isEqualToString:@"jpg"] ||[exestr isEqualToString:@"png"]) {
                NSLog(@"图片");
                ImgViewController *imgVC=[[ImgViewController alloc] init];
                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:imgVC];
                imgVC.img=decryptBookPath;
                [self.navigationController presentViewController:nav animated:YES completion:nil];


                return;
            }else{
                
                document = [ReaderDocument withDocumentFilePath:decryptBookPath password:nil];
            }
        }
        self.lastReadBookInfo=book;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        //重头开始加载
        /*ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:book.documentPath password:nil];*/
        
        //继续上次阅读的地方加载
        
        
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            
            readerViewController.delegate = self;
            readerViewController.IPurlstr=self.IPurl;
            readerViewController.bookId=book.bookID;
            //[self.navigationController pushViewController:readerViewController animated:YES];
                        if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
                [self presentModalViewController:readerViewController animated:YES];
            }
            else{
                [self presentViewController:readerViewController animated:YES completion:^{
                    
                }];
            }
            if (book.bCollect==NO&&book.bMark==YES) {
                readerViewController.bShowMark=YES;
            }

            
        }
        if ([document.bookmarks count]>0) {
            NSString *keepBookSql=[NSString stringWithFormat:update_sql_BookMark,book.bookID];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:keepBookSql];
        }
        
    }else{
        
        NSLog(@"m没有有这个文件");
        AsyRequestServer *asylanding=[AsyRequestServer getInstance];
        if ([asylanding testNetWorkConnectionWithUrlString:@"www.baidu.com"]==YES) {
            [sender setEnabled:NO];
            
//            UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(10, 80, 150, 30)];
//            bgView.backgroundColor=[UIColor blackColor];
//            bgView.alpha=0.7;
//            CALayer *l = [bgView layer];   //获取ImageView的层
//            [l setMasksToBounds:YES];
//            [l setCornerRadius:3.0];
//            book.progressView.hidden=NO;
//            book.bLoad=YES;
//           // progress=[[UIProgressView alloc] initWithFrame:CGRectMake(5, 13, 140, 130)];
//            [bgView addSubview:book.progressView];
           // [progress setProgressViewStyle:UIProgressViewStyleDefault];
           // progress.transform = CGAffineTransformMakeScale(1.0f,3.0f);
           // book.progressView=progress;
              MBProgressHUD *mpb=[MBProgressHUD showHUDAddedTo:sender animated:YES];
              mpb.labelText=@"下载中";
            book.bLoad=YES;
            
            //[sender addSubview:book.progressView];
            
            //[sender setBackgroundImage:[UIImage imageNamed:@"downloadImg"] forState:UIControlStateNormal];
            AsyRequestServer *asydownload=[AsyRequestServer getInstance];
           // UIProgressView *pro=[[UIProgressView alloc]initWithFrame:CGRectMake(ScreenWidth/4, (ScreenHeight-60)/2, ScreenWidth/2, 600)];
            //UIProgressView *pro=[[UIProgressView alloc]initWithFrame:CGRectMake(12, 15, 50, 60)];
//            [self.view addSubview:pro];
//            pro.frame=CGRectMake(ScreenWidth/4, (ScreenHeight-60)/2, ScreenWidth/2, 600);
//            book.progressView=pro;
//            [book.progressView setProgressViewStyle:UIProgressViewStyleDefault];
//            pro.transform = CGAffineTransformMakeScale(1.0f,3.0f);
            [asydownload requestDownloadDataWithNewObject:book delegate:self];
            
         
            //    [self.tableView reloadData];
        }else{
            
            [self showError:@"请检查网络链接"];
            [self removeProgressView];
        }
        
    }
}

//-(void)setProgress:(float)newProgress
//{
//    [progress setProgress:newProgress];
//}

-(void)removeBook:(int)bookId{
    
    
    NSString *selectName=[NSString stringWithFormat:Select_sql_BookName,bookId];
    NSLog(@"%@,%@",[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectName],[[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectName] class]);
    NSArray *bookNamearr = [[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectName];
    NSString *bookName1=nil;
    for (int i=0; i<bookNamearr.count; i++) {
        bookName1 =[NSString stringWithFormat:@"%@",[[bookNamearr objectAtIndex:i] objectForKey:@"BooKName"]];
    }
    NSString *dPdf =[NSString stringWithFormat:@"%@/Library/Caches/fileTemp",NSHomeDirectory()];
    NSString *dPdf1 =[NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()];
    NSFileManager *defaultManager;
    NSFileManager *defaultManager1;
    defaultManager = [NSFileManager defaultManager];
    defaultManager1 = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",dPdf,bookName1] error:nil];
    [defaultManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",dPdf1,bookName1] error:nil];
    [self.tableView reloadData];
    
}
-(void)didFinish
{
    
    NSMutableArray *arr=[NSMutableArray array];
    BooksInfo *bookInfo=[[BooksInfo alloc] init];
    NSLog(@"----bookJsonArrcount--%lu",(unsigned long)[bookJsonArr count]);
    for (int i = 0;i<[bookJsonArr count]; i++) {
        
        //  [arr addObject:[[bookJsonArr objectAtIndex:i] objectForKey:@"BooKName"]];
        bookInfo.bookID=[[[bookJsonArr objectAtIndex:i] objectForKey:@"bookId"] intValue];
        bookInfo.bookName=[[bookJsonArr objectAtIndex:i] objectForKey:@"bookName"];
        bookInfo.page=[[[bookJsonArr objectAtIndex:i] objectForKey:@"page"] intValue];
        bookInfo.CategoryID=[[[bookJsonArr objectAtIndex:i] objectForKey:@"categoryId"] intValue];
        bookInfo.deleteBookId=[[bookJsonArr objectAtIndex:i] objectForKey:@"delBook"];
        bookInfo.NoEmpowerBook=[[bookJsonArr objectAtIndex:i]objectForKey:@"noEmpowerBook"];
        bookInfo.bookUrl=(NSMutableString *)[[[bookJsonArr objectAtIndex:i] objectForKey:@"bookUrl"] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        bookInfo.author =[[bookJsonArr objectAtIndex:i] objectForKey:@"bookdetail"];
        bookInfo.noDestroy = [[bookJsonArr objectAtIndex:i] objectForKey:@"noDestroy"];
        NSLog(@"-----bbbbbbbbbbbb_--%@,\n%@",bookInfo.bookUrl,bookInfo.author);
      //  bookInfo.bookKey=[[bookJsonArr objectAtIndex:i] objectForKey:@"bookKey"];
        //以下为预留字段
        //bookInfo.BookCover=[[bookJsonArr objectAtIndex:i ] objectForKey:@"BookCover"];
        // bookInfo.author=[[bookJsonArr objectAtIndex:i ] objectForKey:@"Author"];
        //bookInfo.publishDate=[[bookJsonArr objectAtIndex:i ] objectForKey:@"PublishDate"];
        //bookInfo.Language=[[bookJsonArr objectAtIndex:i ] objectForKey:@"Language"];
        //bookInfo.BookProfile=[[bookJsonArr objectAtIndex:i ] objectForKey:@"BookProfile"];
        //bookInfo.bookID=[[bookJsonArr objectAtIndex:i ] objectForKey:@"booksize"];
        //bookInfo.Weight=[[bookJsonArr objectAtIndex:i ] objectForKey:@"Weight"];
        
        if (bookInfo.noDestroy) {
            [self removeBook:[bookInfo.noDestroy intValue]];
        }
        if (bookInfo.deleteBookId) {
            NSString *deleteBookSql=[NSString stringWithFormat:Delete_sql_Book,[bookInfo.deleteBookId intValue]];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:deleteBookSql];
            [self removeBook:[bookInfo.deleteBookId intValue]];
            
        }
        if (bookInfo.NoEmpowerBook) {
            NSString *deleteBookSql=[NSString stringWithFormat:Delete_sql_Book,[bookInfo.NoEmpowerBook intValue]];
            NSLog(@"----cale%@",deleteBookSql);
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:deleteBookSql];
            [self removeBook:[bookInfo.NoEmpowerBook intValue]];

        }
        if (bookInfo.bookID) {
            NSString *insertBookInfoSql=[NSString stringWithFormat:Insert_sql_BookInfo,bookInfo.bookID,bookInfo.bookName,bookInfo.page,bookInfo.CategoryID,bookInfo.bookUrl];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:insertBookInfoSql];
            NSLog(@"insertsql------%@",insertBookInfoSql);
        }
        
        [arr addObject:bookInfo];
        
    }
    NSLog(@"===%@",arr);
    NSLog(@"dddd%@\n%lu",_myBooks.categoryList,(unsigned long)[_myBooks.categoryList count]);
    
    if (bookJsonArr.count>0) {
        [self reloadView];
    }
    
}
//TODO:--ASIFormDataRequest请求代理
-(void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"RequestFinist12222----------:%d\n%@",[request responseStatusCode],[request responseString]);
    
    bookJsonArr = [[request responseString] JSONValue];
    if ([request responseStatusCode] ==200) {
        if (isUpload==YES) {
            
            NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString * documentDirectory=[paths objectAtIndex:0];
            NSString *localPath = [documentDirectory stringByAppendingPathComponent:@"url.plist"];
            NSDictionary *urlDataDic=[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"http://%@:8001/pdfpath/",iptext.text] forKey:@"url"];
            NSLog(@"-------%@",urlDataDic);
            [urlDataDic writeToFile:localPath atomically:YES];
            
            NSString *localPath1 = [documentDirectory stringByAppendingPathComponent:@"url1.plist"];
            NSDictionary *urlDataDic1=[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",iptext.text] forKey:@"url1"];
            [urlDataDic1 writeToFile:localPath1 atomically:YES];
            
            NSLog(@"--同步返回数据---%@",[request responseString]);
            if ([[request responseString] isEqualToString:@"[]"] || [request responseString] == nil) {
                NSLog(@"没有同步数据");
                [self showError:@"无可更新内容"];
            }else{
                
                [self didFinish];
                [self showError:@"同步完成"];
            }
        }else{
            
            //   NSString *str= [[request responseString] stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br />"];
            //  NSLog(@" str   zhuanyi   ---%@",str);
            //   id jsonString=[[request responseString] JSONValue];
            //  NSLog(@"---json-type--%@",[jsonString class]);
            NSLog(@"nnnnnnnnnn%@",bookJsonArr);
            
            [self didFinish];
        }
    }else{
        
        [self showError:@"同步出错……"];
    }
    
    [self.navigationController.view setUserInteractionEnabled:YES];
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    // [self.tableView reloadData];
}
-(void)requestFailed:(ASIFormDataRequest *)request
{
    NSLog(@"RequestFailed2----------:\n%@\n\n\n\n%@\n%@\n%d",[request responseString],[request error],[request requestHeaders],[request responseStatusCode]);
    [MBProgressHUD hideHUDForView:self.view  animated:YES];
    
    if (isUpload==YES) {
        //     [self.view setUserInteractionEnabled:YES];
        [self.navigationController.view setUserInteractionEnabled:YES];
        [self showError:@"请求失败，请检查IP地址是否正确"];
        [self.tableView reloadData];
        
    }else{
        
        [self showError:@"获取数据失败"];
    }
}


- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    
    //[self.navigationController popViewControllerAnimated:YES];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}

-(void)dealloc
{
    // [asyrequest.request can]
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = [self frameForOrientation:interfaceOrientation];
    self.view.frame = frame;//重新定义frame
   
    UIInterfaceOrientation to=self.interfaceOrientation;
    if(to == UIDeviceOrientationLandscapeLeft || to == UIDeviceOrientationLandscapeRight)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
        //   [bgImageView setImage:[UIImage imageNamed:@"bg_h.png"]];
        
        //   [serarchBar setFrame:CGRectMake(400, 1, 250, 40)];
        
        [setting setFrame:CGRectMake(900, 7, 25, 25)];
       [myBookBtn setFrame:CGRectMake(900-80, 7, 25, 25)];
        [self reloadView];
        [self.tableView reloadData];
        NavBg.frame=CGRectMake(0, 44, frame.size.width, 50);
        self.tableView.frame=CGRectMake(10,50+44,frame.size.width-20, frame.size.height-100);
        self.searchBar.frame=CGRectMake(frame.size.width-550, 1, 250, 40);
    }else if (interfaceOrientation==UIDeviceOrientationPortrait || interfaceOrientation ==UIDeviceOrientationPortraitUpsideDown){
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
        //   [serarchBar setFrame:CGRectMake(340, 1, 250, 40)];
      [myBookBtn setFrame:CGRectMake(650, 7, 25, 25)];
        [setting setFrame:CGRectMake(710, 7, 25, 25)];
        [self reloadView];

        [self.tableView reloadData];
         NavBg.frame=CGRectMake(0, 44, frame.size.width, 50);
        self.tableView.frame=CGRectMake(10,50+44,frame.size.width-20, frame.size.height-100);
         self.searchBar.frame=CGRectMake(frame.size.width-418, 1, 250, 40);
    }
}
//


@end
