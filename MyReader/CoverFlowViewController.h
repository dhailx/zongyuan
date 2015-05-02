//
//  CoverFlowViewController.h
//  MyReader
//
//  Created by YDJ on 13-6-1.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookSearchViewController.h"
#import "JGBooksModel.h"
#import "ReaderViewController.h"
#import "RootViewController.h"
#import "MBProgressHUD.h"
@interface CoverFlowViewController : UIViewController<UISearchBarDelegate,BookSearchDelegate,UIPopoverControllerDelegate,BookSearchDelegate,ReaderViewControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIPopoverControllerDelegate>
{
    
    UILabel *classLabel;
   id objectJson;
    NSString *classArrStr;
    UISearchBar * serarchBar;
    UIPopoverController * spopver;
    NSMutableArray *searchArray;
    Books *myBooks;
    BooksInfo * searchSelectBook;
    BOOL isBookInfo;
    UIButton *hmSettingBtn;
    
    UITextField *iptext;
    UIPopoverController *settingPop;
    BOOL Upload;
    NSString *isFrist;
    RootViewController*rootVC;
    NSString *trackViewUrl;
    
    NSString *updateVS;
    NSString *version;
    
    UIImageView *bgImageView;
    
    UIButton *biaozhunBtn;
    UIButton *scyjBtn;
    UIButton *scBtn;
    UIButton *ghBtn;
    UIButton *gzBtn;
    UIButton *qkBtn;
    UIButton *ghtBtn;
    UIButton *OaBtn;
    
    UIButton *myBookBtn;
    UIButton *allDownloadBtn;
    UIButton *HelpBtn;
}

@property (nonatomic,strong) UIView *NavBg;
@property (nonatomic,strong) UILabel *NavList;
@property (nonatomic,strong) UILabel *UserLabel;
@property (nonatomic,strong) UILabel *TipLabel;

@property (nonatomic,strong)UIButton *myBookBtn;
@property (nonatomic,strong)UIButton *allDownloadBtn;
@property (nonatomic,strong)UIButton *HelpBtn;
@property (nonatomic,strong) UIButton *hmSettingBtn;
@property (nonatomic,strong)UIButton *MarkBtn;
@property (nonatomic,strong)NSMutableArray * objectJson;
@property (nonatomic,strong)NSString *IPstr;
-(NSMutableArray *)selectBookCategory;
//- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view;
//-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index;
//-(void)openBookShelf:(int)index;
-(void)didSelectBookInfo:(BooksInfo *)bookInfo withOther:(NSDictionary *)other;

@property (nonatomic,strong)UIView *loadingAlertView;
@property (nonatomic,strong)UILabel *TipsLabel;
@property (nonatomic,strong)UIView *LabelView;
@property (nonatomic,strong) MBProgressHUD *mbpload;
@property NSInteger nall;
@property NSInteger nSucess;
@property NSInteger nFailed;

@end
