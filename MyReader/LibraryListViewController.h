//
//  LibraryListViewController.h
//  MyReader
//
//  Created by YDJ on 13-5-22.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BooksInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "AsyRequestServer.h"
@interface LibraryListViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,ASIProgressDelegate>
{
    UIButton * setting;
  //  UISwitch *swith;
    UITextField * iptext;       //输入ip地址
    NSMutableArray *bookJsonArr; //请求返回的书的信息数组
    AsyRequestServer *asyrequest;
    NSString *docment;
    BOOL isUpload;
    BOOL isOpen;
    
    int sbookId;
    NSString *bookName;
    UIButton *myBookBtn;
}

@property (nonatomic,strong)UIButton *myBookBtn;


@property(nonatomic,strong)NSString * landIP;
@property(nonatomic,strong)NSString *IPurl;
@property(nonatomic,unsafe_unretained)int index;
//@property(nonatomic,strong)NSMutableArray  *CategoryArray;  //传入的二级分类数组 //作废
@property(nonatomic,strong)NSMutableArray *smallCategoryArr;//二级分类下分类数组
@property(nonatomic,strong)NSMutableArray  *CategoryListArr;
@property(nonatomic,strong)NSMutableArray *categoryIDclass3;
@property(nonatomic,strong)NSString *CategoryID;
@property(nonatomic,strong)NSString *CategoryID2;
@property(nonatomic,strong)NSMutableArray *CategoryNameArr;

@property(nonatomic,strong)NSString *MybookType;

@property(nonatomic,strong)UITableView *BookTabel;

@property (nonatomic,strong) UIView *NavBg;
@property (nonatomic,strong) UILabel *NavList;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,strong) UILabel *UserLabel;
@property (nonatomic,strong)UIProgressView *progress;


@end
