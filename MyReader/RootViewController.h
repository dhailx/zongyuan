//
//  RootViewController.h
//  cellMaxMinDemo
//
//  Created by Sagar Kothari on 19/07/11.
//  Copyright 2011 SagarRKothari-iPhone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookSearchViewController.h"
#import "JGBooksModel.h"
#import "ReaderViewController.h"
@interface RootViewController :UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,BookSearchDelegate,UIPopoverControllerDelegate,BookSearchDelegate,ReaderViewControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIPopoverControllerDelegate> {
	
    
    UITableView * shuTabView;
    BOOL first;
     UISearchBar * serarchBar;
     UIButton *hmSettingBtn;
     UIButton *myBookBtn;
    UITextField *iptext;
    UIPopoverController *settingPop;

}
@property (nonatomic, retain) UITableView * shuTabView;
@property (nonatomic, retain) NSArray *arrayOriginal;
@property (nonatomic, retain) NSMutableArray *arForTable;
@property (nonatomic,retain) NSMutableArray *CategoryArray;
@property (nonatomic,retain) NSString *CategoryID2;
@property (nonatomic,retain) NSString *CategoryID;
@property(nonatomic,retain)NSMutableArray *categoryIDclass4;
@property (nonatomic,retain) NSString * ipUrl;
-(void)miniMizeThisRows:(NSArray*)ar;

@property (nonatomic,strong) UIView *NavBg;
@property (nonatomic,strong) UILabel *NavList;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,strong) UILabel *UserLabel;

@property (nonatomic,strong)NSString *IPstr;

@property (nonatomic,strong)UIImageView *huiImage;


@end


