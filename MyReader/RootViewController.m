//
//  RootViewController.m
//  cellMaxMinDemo
//
//  Created by Sagar Kothari on 19/07/11.
//  Copyright 2011 SagarRKothari-iPhone. All rights reserved.
//

#import "RootViewController.h"
#import "SaffronClientSQLManager.h"
#import "PublicClassHeader.h"
#import "LibraryListViewController.h"
#import "MBProgressHUD.h"
#import "JGUtil.h"
#import "CoverFlowViewController.h"
@implementation RootViewController

@synthesize arrayOriginal;
@synthesize arForTable;
@synthesize categoryIDclass4;
@synthesize CategoryArray,CategoryID2,CategoryID,ipUrl,shuTabView,NavBg,NavList,name,UserLabel,huiImage;

-(void)selecta:(NSMutableArray *)CateIDarr{
    
    if (CateIDarr) {
        NSLog(@"写入plist文件路径----");
        NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString * documentDirectory=[paths objectAtIndex:0];
        NSString *localPath = [documentDirectory stringByAppendingPathComponent:@"dataPlist.plist"];
        
        //        BOOL have=   [[NSFileManager defaultManager] fileExistsAtPath:localPath];
        //        if (!have) {
        
        NSMutableArray *pulicArr=[CateIDarr copy];
        NSLog(@"22222------count---%lu",(unsigned long)pulicArr.count);
        
        NSMutableArray *allDataArr=[NSMutableArray array];
        
        for (int i = 0; i<[pulicArr count]; i++) {
            
            NSMutableArray *tempArr0=[NSMutableArray array];
            NSMutableDictionary *tempDic0=[NSMutableDictionary dictionaryWithObjectsAndKeys:[CategoryArray objectAtIndex:i],@"name",[pulicArr objectAtIndex:i],@"CategoryID",@"0",@"number",@" 	#84C1FF",@"textColor",@"covercell.png",@"cellImage",@"one.png",@"btnImage", nil];
            
            self.CategoryID2=[pulicArr objectAtIndex:i];
            NSLog(@"----%@",self.CategoryID2);
            NSLog(@"-------111---%@",self.CategoryID2);
            NSString *selectSql2=[NSString stringWithFormat:Select_sql_BookCategoryName,[self.CategoryID2 intValue]];
            NSMutableArray * idArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql2]; //3级分类目录
            NSLog(@"idarr---%@",idArr);
            
            if (idArr.count<1) {
                
                
            }
            
            else{
                for (int i = 0; i<[idArr count]; i++) {
                    NSLog(@"3333---count---%lu",(unsigned long)idArr.count);
                    NSMutableArray *tempArr1=[NSMutableArray array];
                    NSMutableDictionary *tempDic1=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"           %@",[[idArr objectAtIndex:i] objectForKey:@"CategoryName"]],@"name",[[idArr objectAtIndex:i] objectForKey:@"CategoryID"],@"CategoryID",@"1",@"number",@" 	#FFE66F",@"textColor",@"covercell1.png",@"cellImage",@"two.png",@"btnImage1", nil];
                    
                    [tempArr0 addObject:tempDic1];
                    
                    NSString *idstr=[[idArr objectAtIndex:i] objectForKey:@"CategoryID"];
                    NSString *selectSql3=[NSString stringWithFormat:Select_sql_BookCategoryName,[idstr intValue]];
                    NSMutableArray * idArr2=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql3]; //4级分类目录
                    NSLog(@"                 break======%@",idstr);
                    NSLog(@"idarr2-33333--%@",idArr2);
                    if (idArr2.count<1) {
                        //[self addBooksInfo:idstr isend:NO];
                        NSLog(@"444444");
                    }else{
                        for (int i = 0; i<[idArr2 count]; i++) {
                            
                            NSMutableArray *tempArr2=[NSMutableArray array];
                            NSMutableDictionary *tempDic2=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"                   %@",[[idArr2 objectAtIndex:i] objectForKey:@"CategoryName"]],@"name",[[idArr2 objectAtIndex:i] objectForKey:@"CategoryID"],@"CategoryID",@"2",@"number",@"#B7FF4A",@"textColor",@"covercell2.png",@"cellImage",@"three.png",@"btnImage2", nil];
                            
                            [tempArr1 addObject:tempDic2];
                            
                            NSString *idstr2=[[idArr2 objectAtIndex:i] objectForKey:@"CategoryID"];
                            NSString *selectSql4=[NSString stringWithFormat:Select_sql_BookCategoryName,[idstr2 intValue]];
                            NSMutableArray * idArr3=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql4]; //5级分类目录
                            NSLog(@"       break======%@",idstr2);
                            NSLog(@"idarr3---%@",idArr3);
                            
                            if (idArr3.count<1) {
                            }else
                            {
                                for (int i = 0; i<[idArr3 count]; i++) {
                                    
                                  //  NSMutableArray *tempArr3=[NSMutableArray array];
                                    NSMutableDictionary *tempDic3=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"                             %@",[[idArr3 objectAtIndex:i] objectForKey:@"CategoryName"]],@"name",[[idArr3 objectAtIndex:i] objectForKey:@"CategoryID"],@"CategoryID",@"2",@"number",@"#00FF00",@"textColor",@"covercell2.png",@"cellImage",@"three.png",@"btnImage3", nil];
                                    
                                    [tempArr2 addObject:tempDic3];
                                    
                                    NSString *idstr3=[[idArr3 objectAtIndex:i] objectForKey:@"CategoryID"];
                                    NSString *selectSql5=[NSString stringWithFormat:Select_sql_BookCategoryName,[idstr3 intValue]];
                                    NSMutableArray * idArr4=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql5];
//                                    if (idArr4.count<1) {
//                                        
//                                    }else {
//                                        
//                                        for (int i = 0; i<[idArr3 count]; i++) {
//                                            
//                                            NSMutableArray *tempArr4=[NSMutableArray array];
//                                            NSMutableDictionary *tempDic3=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"                                 %@",[[idArr3 objectAtIndex:i] objectForKey:@"CategoryName"]],@"name",[[idArr3 objectAtIndex:i] objectForKey:@"CategoryID"],@"CategoryID",@"2",@"number",@"#00FF7F",@"textColor",@"covercell2.png",@"cellImage",@"three.png",@"btnImage2", nil];
//                                            
//                                            [tempArr3 addObject:tempDic3];
//                                        }if (tempArr3.count>0) {
//                                            [tempDic3 setObject:tempArr3 forKey:@"Objects"];
//                                        }
//                                    }
                                }  if (tempArr2.count>0) {
                                    [tempDic2 setObject:tempArr2 forKey:@"Objects"];
                                    tempArr2=nil;
                                    
                                }
                            }
                        }
                    }if (tempArr1.count>0) {
                        [tempDic1 setObject:tempArr1 forKey:@"Objects"];
                        tempArr1=nil;
                    }
                }
                if (tempArr0.count>0) {
                    [tempDic0 setObject:tempArr0 forKey:@"Objects"];
                    tempArr0=nil;
                    
                }
            }
            //[self addBooksInfo:@"end" isend:YES];
            if (tempDic0.count>0) {
                [allDataArr addObject:tempDic0];
                tempDic0=nil;
            }
        }
        
        NSDictionary *allDataDic=[NSDictionary dictionaryWithObject:allDataArr forKey:@"Objects"];
        [allDataDic writeToFile:localPath atomically:YES];
        NSLog(@"[][][][][][][]%d", [allDataDic writeToFile:localPath atomically:YES]);
        
        NSLog(@"写入plist文件路径-----%@",localPath);
        
        //       }
        //        else{
        
        //            NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        //            NSString * documentDirectory=[paths objectAtIndex:0];
        //            NSString *dataPath = [documentDirectory stringByAppendingPathComponent:@"dataPlist.plist"];
        //	NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
        NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:localPath];
        self.arrayOriginal=[dTmp valueForKey:@"Objects"];
        [dTmp release];
        
        self.arForTable=[[[NSMutableArray alloc] init] autorelease];
        [self.arForTable addObjectsFromArray:self.arrayOriginal];
        //       }
        
    }
}

-(void)backAction{
    
    [self.navigationController popViewControllerAnimated:YES];
    SaffronClientSQLManager* man=[SaffronClientSQLManager getInstance];
    man.bAll=YES;
    man.strId=@"";
}
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    NSInteger yy=0;
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)     {
        yy=44;
    }
    CGRect frame = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.view.frame = frame;//重新定义frame

    
    first=YES;
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"newbg.png"]]];
    
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(5, 2, 40, 40)];
    [backBtn setImage:[UIImage imageNamed:@"newback.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * barBtn=[[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = barBtn;
    [barBtn release];
    
    
    
    
    huiImage=[[UIImageView alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        [huiImage setFrame:CGRectMake(52, 30+64-yy, frame.size.width-104, frame.size.height-118)];
    }else{
        
        [huiImage setFrame:CGRectMake(52, 30-yy, frame.size.width-104, frame.size.height-118)];
    }
    
     UIImage *img=[UIImage imageNamed:@"huibg.png"];
    img=[img stretchableImageWithLeftCapWidth:10 topCapHeight:10];

    NSLog(@"%f-----%f",huiImage.frame.size.width,huiImage.frame.size.height);
    
    UIGraphicsBeginImageContext(huiImage.frame.size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, huiImage.frame.size.width, huiImage.frame.size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    [huiImage setImage:scaledImage];
    
    
    [self.view addSubview:huiImage];
   // [huiImage release];
    
    
	
    self.shuTabView=[[UITableView alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        [self.shuTabView setFrame:CGRectMake(52+40, 35+30+64-yy, frame.size.width-184, frame.size.height-114)];
    }else{
        
        [self.shuTabView setFrame:CGRectMake(52+40, 35+20-yy, frame.size.width-184, frame.size.height-114)];
    }
    self.shuTabView.dataSource=self;
    self.shuTabView.delegate=self;
    [self.shuTabView setBackgroundColor:[UIColor clearColor]];
    [self.shuTabView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.shuTabView];
    //   [self selecta:self.categoryIDclass4];
    [self.shuTabView reloadData];
    
    
    NavBg=[[UIView alloc]initWithFrame:CGRectMake(0, 44-yy, frame.size.width, 50)];
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

    NavList.text=[NSString stringWithFormat:@"%@ >",name];
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
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
    [super viewWillAppear:animated];
    if (first==YES) {
        [self selecta:self.categoryIDclass4];
        [self.shuTabView reloadData];
        first=NO;
    }else
    {
        CGRect frame = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation ];
        self.view.frame = frame;//重新定义frame
        CoverFlowViewController *cov=[[CoverFlowViewController alloc] init];
        UIInterfaceOrientation to=self.interfaceOrientation;
        if(to == UIDeviceOrientationLandscapeLeft || to == UIDeviceOrientationLandscapeRight)
        {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
            //   [bgImageView setImage:[UIImage imageNamed:@"bg_h.png"]];
            
            //   [serarchBar setFrame:CGRectMake(400, 1, 250, 40)];
            [cov.myBookBtn setFrame:CGRectMake(800-80, 7, 25, 25)];
            [cov.allDownloadBtn setFrame:CGRectMake(850-47, 2, 30, 35)];
            [cov.hmSettingBtn setFrame:CGRectMake(900, 7, 25, 25)];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
                [self.shuTabView setFrame:CGRectMake(52+40, 35+30+64-44, frame.size.width-184, frame.size.height-114)];
            }else{
                
                [self.shuTabView setFrame:CGRectMake(52+40, 35+20, frame.size.width-184, frame.size.height-114)];
            }
            [self.shuTabView reloadData];
            NavBg.frame=CGRectMake(0, 0, frame.size.width, 50);
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
                [huiImage setFrame:CGRectMake(52, 30+64-44, frame.size.width-104, frame.size.height-118)];
            }else{
                
                [huiImage setFrame:CGRectMake(52, 30, frame.size.width-104, frame.size.height-118)];
            }
            
            UIImage *img=[UIImage imageNamed:@"huibg.png"];
            img=[img stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            
            NSLog(@"%f-----%f",huiImage.frame.size.width,huiImage.frame.size.height);
            
            UIGraphicsBeginImageContext(huiImage.frame.size);
            // 绘制改变大小的图片
            [img drawInRect:CGRectMake(0, 0, huiImage.frame.size.width, huiImage.frame.size.height)];
            // 从当前context中创建一个改变大小后的图片
            UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            // 使当前的context出堆栈
            UIGraphicsEndImageContext();
            
            [huiImage setImage:scaledImage];
            
        }else if ([UIApplication sharedApplication].statusBarOrientation ==UIDeviceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation  ==UIDeviceOrientationPortraitUpsideDown){
            
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
            //   [serarchBar setFrame:CGRectMake(340, 1, 250, 40)];
            [cov.allDownloadBtn setFrame:CGRectMake(650, 2, 30, 35)];
            // [bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [cov.hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
            [cov.myBookBtn setFrame:CGRectMake(600, 7, 25, 25)];
            [cov.hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
            
            NavBg.frame=CGRectMake(0, 44, frame.size.width, 50);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
                [self.shuTabView setFrame:CGRectMake(52+40, 35+30+64, frame.size.width-184, frame.size.height-114)];
            }else{
                
                [self.shuTabView setFrame:CGRectMake(52+40, 35+20, frame.size.width-184, frame.size.height-114)];
            }
            [self.shuTabView reloadData];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
                [huiImage setFrame:CGRectMake(52, 30+64, frame.size.width-104, frame.size.height-118)];
            }else{
                
                [huiImage setFrame:CGRectMake(52, 30, frame.size.width-104, frame.size.height-118)];
            }
            
            UIImage *img=[UIImage imageNamed:@"huibg.png"];
            img=[img stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            
            NSLog(@"%f-----%f",huiImage.frame.size.width,huiImage.frame.size.height);
            
            UIGraphicsBeginImageContext(huiImage.frame.size);
            // 绘制改变大小的图片
            [img drawInRect:CGRectMake(0, 0, huiImage.frame.size.width, huiImage.frame.size.height)];
            // 从当前context中创建一个改变大小后的图片
            UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            // 使当前的context出堆栈
            UIGraphicsEndImageContext();
            
            [huiImage setImage:scaledImage];
            
            
        }

    }
    
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  return 150;
    return 65;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //  NSLog(@"%d",[self.arForTable count]);
	return [self.arForTable count];
}


-(void)readBooks:(UIButton *)sender
{
    NSString *selectBookSql=[NSString stringWithFormat:select_sql_indexBookInfo,[[[self.arForTable objectAtIndex:sender.tag] valueForKey:@"CategoryID"] intValue]];
    NSMutableArray *sqlbookArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql];
    
    //if([d valueForKey:@"Objects"]) {
    //	NSArray *ar=[d valueForKey:@"Objects"];
    if (sqlbookArr.count>0) {

        NSMutableDictionary *sss=[sqlbookArr objectAtIndex:0];
        
        MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        mbp.labelText = @"加载数据中,请稍后...";
    
        NSLog(@"丶我进入%@",self.CategoryID);
        LibraryListViewController *libVC=[LibraryListViewController alloc];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:libVC];
    // long btnTag=(long)sender.tag;
        libVC.index =[[[self.arForTable objectAtIndex:sender.tag] valueForKey:@"CategoryID"] intValue];//(int) sender.tag;
        libVC.IPurl=self.ipUrl;
        libVC.CategoryID=self.CategoryID;
       // NSString *str=[[self.arForTable objectAtIndex:sender.tag]valueForKey:@"name"];
        
        NSString *strpath=[sss valueForKey:@"Path"];
        
        NSRange range = [strpath rangeOfString:name];
        int location = range.location;
        int leight = range.length;
        int loc=location+leight+1;
        
        NSRange range1 = [strpath rangeOfString:@"/newFileName"];
        int location1 = range1.location;
       // int leight1 = range1.length;
        
        NSString *str= [strpath substringWithRange:NSMakeRange(loc, location1-loc)];
        
        NSString *strUrl = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
        libVC.name=[NSString stringWithFormat:@"%@ > %@ >",name,strUrl];
        NSLog(@"%@",[self.arForTable objectAtIndex:sender.tag]);
    //[self.navigationController pushViewController:libVC animated:YES];
        [self presentViewController:nav animated:YES completion:nil];
        [MBProgressHUD hideHUDForView:self.view  animated:YES];
        [libVC release];
        [nav release];
    }
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	//cell.textLabel.text=[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"name"];
    [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
	[cell setIndentationLevel:[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue]];
    
    for(UIView *mylabelview in [cell.contentView subviews])
    {
        if ([mylabelview isKindOfClass:[UIImageView class]]) {
            [mylabelview removeFromSuperview];
        }
    }
    UIImageView *imageView=[[UIImageView alloc] init];
    UIImage *img=[UIImage imageNamed:[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"cellImage"]];
    img=[img stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    imageView.image=img;//[UIImage imageNamed:@"lastcell.png"];

    
    
    
   // UIImageView *cellImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"cellImage"]]];
    // CGFloat *floa=[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"textColor"];
    [imageView setFrame:CGRectMake(0, 0, shuTabView.frame.size.width, 53)];
    [cell.contentView addSubview:imageView];
    [imageView release];
    
    UIButton *oneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [oneBtn setFrame:CGRectMake(10, 10, 30, 30)];
    
    NSLog(@"aaaaaa---%@",[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"btnImage"]);
    [oneBtn setBackgroundImage:[UIImage imageNamed:[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"btnImage"]] forState:UIControlStateNormal];
    [cell.contentView addSubview:oneBtn];
    
    UIButton *twoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [twoBtn setFrame:CGRectMake(60, 10, 30, 30)];
    NSLog(@"aaaaaa1---%@",[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"btnImage1"]);

    [twoBtn setBackgroundImage:[UIImage imageNamed:[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"btnImage1"]] forState:UIControlStateNormal];
    [cell.contentView addSubview:twoBtn];
    
    UIButton *threeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [threeBtn setFrame:CGRectMake(110, 10, 30, 30)];
    NSLog(@"aaaaaa2---%@",[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"btnImage2"]);

    [threeBtn setBackgroundImage:[UIImage imageNamed:[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"btnImage2"]] forState:UIControlStateNormal];
    [cell.contentView addSubview:threeBtn];
    
    UIButton *fourBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [fourBtn setFrame:CGRectMake(150, 10, 30, 30)];
    NSLog(@"aaaaaa3---%@",[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"btnImage3"]);

    [fourBtn setBackgroundImage:[UIImage imageNamed:[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"btnImage3"]] forState:UIControlStateNormal];
    [cell.contentView addSubview:fourBtn];
    
    UILabel *cellLab=[[UILabel alloc] initWithFrame:CGRectMake(95, 8, 380, 42)];
    [cellLab setText:[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"name"]];
    [cellLab setFont:[UIFont fontWithName:@"AmericanTypewriter" size:19]];
    [cellLab setTextColor:[JGUtil colorWithHexString:[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"textColor"]]];
    [cellLab setBackgroundColor:[UIColor clearColor]];
    [cell.contentView addSubview:cellLab];
    [cellLab release];
    
    
    UIButton *openBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [openBtn setFrame:CGRectMake(shuTabView.frame.size.width-50, 5, 40, 40)];
    [openBtn setBackgroundImage:[UIImage imageNamed:@"look3.png"] forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(readBooks:) forControlEvents:UIControlEventTouchUpInside];
    openBtn.tag =indexPath.row;//[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"CategoryID"] intValue];
    NSLog(@"Btntag----%ld",(long)openBtn.tag);
    
    UIButton *openBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
    [openBtn1 setFrame:CGRectMake(shuTabView.frame.size.width-95, 5, 40, 40)];
    [openBtn1 setBackgroundImage:[UIImage imageNamed:@"mulu.png"] forState:UIControlStateNormal];
    [openBtn1 addTarget:self action:@selector(readBooks:) forControlEvents:UIControlEventTouchUpInside];
    openBtn1.tag =indexPath.row;//[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"CategoryID"] intValue];
    
    
    NSString *selectBookSql=[NSString stringWithFormat:select_sql_indexBookInfo,[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"CategoryID"] intValue]];
    NSMutableArray *sqlbookArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql];
    
    UILabel *numberLab=[[UILabel alloc] init];
    [numberLab setFrame:CGRectMake(shuTabView.frame.size.width-95, 5, 40, 40)];
    [numberLab setBackgroundColor:[UIColor clearColor]];
    [numberLab setTextColor:[UIColor yellowColor]];
  int a = (unsigned)[sqlbookArr count];
    if (a ==0) {
        [numberLab setText:[NSString stringWithFormat:@"%@",@""]];

    }else{
        [numberLab setText:[NSString stringWithFormat:@"%d",a]];
    }

    NSDictionary *d=[self.arForTable objectAtIndex:indexPath.row];
	//if([d valueForKey:@"Objects"]) {
	//	NSArray *ar=[d valueForKey:@"Objects"];
    if (sqlbookArr.count>0) {
        [openBtn setHidden:NO];
      //  openBtn.enabled=YES;
        
    }
    else{
        [openBtn setHidden:YES];
    //    openBtn.enabled=NO;

    }
    NSArray *ar=[d valueForKey:@"Objects"];
    if(ar.count>0){
        [openBtn1 setHidden:NO];
      //  [openBtn setHidden:NO];
      //  openBtn.enabled=NO;
    }else{
        [openBtn1 setHidden:YES];
    }
    [cell.contentView addSubview:openBtn];
    [cell.contentView addSubview:openBtn1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *d=[self.arForTable objectAtIndex:indexPath.row];
	if([d valueForKey:@"Objects"]) {
		NSArray *ar=[d valueForKey:@"Objects"];
		
		BOOL isAlreadyInserted=NO;
		
		for(NSDictionary *dInner in ar ){
			NSInteger index=[self.arForTable indexOfObjectIdenticalTo:dInner];
			isAlreadyInserted=(index>0 && index!=NSIntegerMax);
			if(isAlreadyInserted) break;
		}
		
		if(isAlreadyInserted) {
			[self miniMizeThisRows:ar];
		} else {
			NSUInteger count=indexPath.row+1;
			NSMutableArray *arCells=[NSMutableArray array];
			for(NSDictionary *dInner in ar ) {
				[arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
				[self.arForTable insertObject:dInner atIndex:count++];
			}
			[tableView insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationTop];
		}
	}else {
        NSString *selectBookSql=[NSString stringWithFormat:select_sql_indexBookInfo,[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"CategoryID"] intValue]];
        NSMutableArray *sqlbookArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectBookSql];
        
        //if([d valueForKey:@"Objects"]) {
        //	NSArray *ar=[d valueForKey:@"Objects"];
        if (sqlbookArr.count>0) {
            MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            mbp.labelText = @"加载数据中,请稍后...";
            
            NSLog(@"丶我进入%@",self.CategoryID);
            LibraryListViewController *libVC=[LibraryListViewController alloc];
            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:libVC];
            libVC.index =[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"CategoryID"] intValue];
            libVC.IPurl=self.ipUrl;
            NSString *str=[[self.arForTable objectAtIndex:indexPath.row]valueForKey:@"name"];
            NSString *strUrl = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            libVC.name=[NSString stringWithFormat:@"%@ > %@ >",name,strUrl];

            //[self.navigationController pushViewController:libVC animated:YES];
            [self presentViewController:nav animated:YES completion:nil];
            [MBProgressHUD hideHUDForView:self.view  animated:YES];
            [libVC release];
            [nav release];

        }

        //
        //        UIAlertView *alt=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"这个目录下没有子目录或书籍可阅!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        //        alt.tag=333;
        //        [alt show];
        
        
    }
}

-(void)miniMizeThisRows:(NSArray*)ar{
	
	for(NSDictionary *dInner in ar ) {
		NSUInteger indexToRemove=[self.arForTable indexOfObjectIdenticalTo:dInner];
		NSArray *arInner=[dInner valueForKey:@"Objects"];
		if(arInner && [arInner count]>0){
			[self miniMizeThisRows:arInner];
		}
		
		if([self.arForTable indexOfObjectIdenticalTo:dInner]!=NSNotFound) {
			[self.arForTable removeObjectIdenticalTo:dInner];
			[shuTabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToRemove inSection:0]]withRowAnimation:UITableViewRowAnimationTop];
		}
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [super dealloc];
    // if (self.shuTabView) {
    //       self.shuTabView=nil;
    //       [self.shuTabView release];
    //   }
}



//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
//    
//}
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
    CoverFlowViewController *cov=[[CoverFlowViewController alloc] init];
    UIInterfaceOrientation to=self.interfaceOrientation;
    if(to == UIDeviceOrientationLandscapeLeft || to == UIDeviceOrientationLandscapeRight)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_h.png"] forBarMetrics:UIBarMetricsDefault];
     //   [bgImageView setImage:[UIImage imageNamed:@"bg_h.png"]];
        
     //   [serarchBar setFrame:CGRectMake(400, 1, 250, 40)];
        [cov.myBookBtn setFrame:CGRectMake(800-80, 7, 25, 25)];
        
        [cov.MarkBtn setFrame:CGRectMake(850-47, 7, 13, 25)];
        
        [cov.allDownloadBtn setFrame:CGRectMake(880, 2, 30, 35)];
        [cov.hmSettingBtn setFrame:CGRectMake(960, 7, 25, 25)];

 
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
            [self.shuTabView setFrame:CGRectMake(52+40, 35+30+64, frame.size.width-184, frame.size.height-114)];
        }else{
            
            [self.shuTabView setFrame:CGRectMake(52+40, 35+20, frame.size.width-184, frame.size.height-114)];
        }
        [self.shuTabView reloadData];
          NavBg.frame=CGRectMake(0, 44, frame.size.width, 50);
      
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
            [huiImage setFrame:CGRectMake(52, 30+64, frame.size.width-104, frame.size.height-118)];
        }else{
            
            [huiImage setFrame:CGRectMake(52, 30, frame.size.width-104, frame.size.height-118)];
        }
        
        UIImage *img=[UIImage imageNamed:@"huibg.png"];
        img=[img stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        
        NSLog(@"%f-----%f",huiImage.frame.size.width,huiImage.frame.size.height);
        
        UIGraphicsBeginImageContext(huiImage.frame.size);
        // 绘制改变大小的图片
        [img drawInRect:CGRectMake(0, 0, huiImage.frame.size.width, huiImage.frame.size.height)];
        // 从当前context中创建一个改变大小后的图片
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        
        [huiImage setImage:scaledImage];
        
    }else if (interfaceOrientation==UIDeviceOrientationPortrait || interfaceOrientation ==UIDeviceOrientationPortraitUpsideDown){
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shutitle.png"] forBarMetrics:UIBarMetricsDefault];
     //   [serarchBar setFrame:CGRectMake(340, 1, 250, 40)];
        [cov.allDownloadBtn setFrame:CGRectMake(655, 2, 30, 35)];
       // [bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [cov.hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
        [cov.myBookBtn setFrame:CGRectMake(560, 7, 25, 25)];
        [cov.hmSettingBtn setFrame:CGRectMake(710, 7, 25, 25)];
        [cov.MarkBtn setFrame:CGRectMake(615, 7, 13, 25)];

        NavBg.frame=CGRectMake(0, 44, frame.size.width, 50);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
            [self.shuTabView setFrame:CGRectMake(52+40, 35+30+64, frame.size.width-184, frame.size.height-114)];
        }else{
            
            [self.shuTabView setFrame:CGRectMake(52+40, 35+20, frame.size.width-184, frame.size.height-114)];
        }
        [self.shuTabView reloadData];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
            [huiImage setFrame:CGRectMake(52, 30+64, frame.size.width-104, frame.size.height-118)];
        }else{
            
            [huiImage setFrame:CGRectMake(52, 30, frame.size.width-104, frame.size.height-118)];
        }
        
        UIImage *img=[UIImage imageNamed:@"huibg.png"];
        img=[img stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        
        NSLog(@"%f-----%f",huiImage.frame.size.width,huiImage.frame.size.height);
        
        UIGraphicsBeginImageContext(huiImage.frame.size);
        // 绘制改变大小的图片
        [img drawInRect:CGRectMake(0, 0, huiImage.frame.size.width, huiImage.frame.size.height)];
        // 从当前context中创建一个改变大小后的图片
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        
        [huiImage setImage:scaledImage];
        
        
    }
}
//
@end
