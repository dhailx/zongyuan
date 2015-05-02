//
//	ReaderViewController.m
//	Reader v2.6.0
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "BooksInfo.h"
#import "SBJson.h"
#import "AsyRequestServer.h"
#import <MessageUI/MessageUI.h>
#import "SaffronClientSQLManager.h"


#define degressToRadian(x) (M_PI * (x)/180.0)
@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,
ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate>
@end

@implementation ReaderViewController
{
    NSString *saveData;
    AsyRequestServer *asyrequest;
    AsyRequestServer *asyrequest2;
    
    UIPopoverController *popover;
    OutlineViewController *outline;
    
	ReaderDocument *document;
    UIView *notesBar;
    UIView *colorView;
    UIView *widthView;
	UIScrollView *theScrollView;
    BOOL isRed;
    BOOL isBlack;
    BOOL isBlue;
    BOOL isRemark;
	ReaderMainToolbar *mainToolbar;
    
	ReaderMainPagebar *mainPagebar;
    
	NSMutableDictionary *contentViews;
    
	UIPrintInteractionController *printInteraction;
    
	NSInteger currentPage;
    
	CGSize lastAppearSize;
    
	NSDate *lastHideTime;
    
	BOOL isVisible;
}

#pragma mark Constants
#define Select_sql_UserInfo @"select * from 'UserInfo'"

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark Properties

@synthesize delegate;
@synthesize bookId,IPurlstr,remarkArr,bShowMark;
#pragma mark Support methods

- (void)updateScrollViewContentSize
{
	NSInteger count = [document.pageCount integerValue];
    
	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit
    
	CGFloat contentHeight = theScrollView.bounds.size.height;
    
	CGFloat contentWidth = (theScrollView.bounds.size.width * count);
    
	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
	[self updateScrollViewContentSize]; // Update the content size
    
	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set
    
	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(id key, id object, BOOL *stop)
     {
         ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
         
     }
     ];
    
	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
    
	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];
    
	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
     ^(NSUInteger number, BOOL *stop)
     {
         NSNumber *key = [NSNumber numberWithInteger:number]; // # key
         
         ReaderContentView *contentView = [contentViews objectForKey:key];
         
         contentView.frame = viewRect; if (page == number) contentOffset = viewRect.origin;
         
         viewRect.origin.x += viewRect.size.width; // Next view frame position
     }
     ];
    
	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
    
}

- (void)updateToolbarBookmarkIcon
{
	NSInteger page = [document.pageNumber integerValue];
    
	BOOL bookmarked = [document.bookmarks containsIndex:page];
    
	[mainToolbar setBookmarkState:bookmarked]; // Update
}

- (void)showDocumentPage:(NSInteger)page
{
	if (page != currentPage) // Only if different
	{
		NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1;
        
		if ((page < minPage) || (page > maxPage)) return;
        
		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);
            
			if (minValue < minPage)
            {minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
                {minValue--; maxValue--;}
		}
        
		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];
        
		NSMutableDictionary *unusedViews = [contentViews mutableCopy];
        
		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
        viewRect.origin.y = 44;
        viewRect.size.height = theScrollView.bounds.size.height -90;
        
		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key
            
			ReaderContentView *contentView = [contentViews objectForKey:key];
            
			if (contentView == nil) // Create a brand new document content view
			{
				NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties
                
				contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];
                if (isRed) {
                    for (UIView *view in [theScrollView subviews] )
                    {
                        if ([view isKindOfClass:[ReaderContentView class]]) {
                            
                            
                            
                            [(ReaderContentView *)view redBrush];
                            
                            
                        }
                        
                    }
                    
                }
               else if (isBlack) {
                    for (UIView *view in [theScrollView subviews] )
                    {
                        if ([view isKindOfClass:[ReaderContentView class]]) {
                            
                            
                            
                            [(ReaderContentView *)view blackBrush];
                            
                            
                        }
                        
                    }
                    
                }
               else if (isBlue) {
                    for (UIView *view in [theScrollView subviews] )
                    {
                        if ([view isKindOfClass:[ReaderContentView class]]) {
                            
                            
                            
                            [(ReaderContentView *)view blueBrush];
                            
                            
                        }
                        
                    }
                    
               }
               else {
                   for (UIView *view in [theScrollView subviews] )
                   {
                       if ([view isKindOfClass:[ReaderContentView class]]) {
                           
                           
                           
                           [(ReaderContentView *)view blackBrush];
                           
                           
                       }
                       
                   }
                   
               }

                
				[theScrollView addSubview:contentView]; [contentViews setObject:contentView forKey:key];
                
				contentView.message = self; [newPageSet addIndex:number];
			}
			else // Reposition the existing content view
			{
				contentView.frame = viewRect; [contentView zoomReset];
                
				[unusedViews removeObjectForKey:key];
			}
            
			viewRect.origin.x += viewRect.size.width;
		}
        
		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
         ^(id key, id object, BOOL *stop)
         {
             [contentViews removeObjectForKey:key];
             
             ReaderContentView *contentView = object;
             
             [contentView removeFromSuperview];
         }
         ];
        
		unusedViews = nil; // Release unused views
        
		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);
        
		CGPoint contentOffset = CGPointZero;
        
		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;
        
		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
		}
        
		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}
        
		NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;
        
		if ([newPageSet containsIndex:page] == YES) // Preview visible page first
		{
			NSNumber *key = [NSNumber numberWithInteger:page]; // # key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			[targetView showPageThumb:fileURL page:page password:phrase guid:guid];
			[newPageSet removeIndex:page]; // Remove visible page from set
		}
        
		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
         ^(NSUInteger number, BOOL *stop)
         {
             NSNumber *key = [NSNumber numberWithInteger:number]; // # key
             
             ReaderContentView *targetView = [contentViews objectForKey:key];
             
             [targetView showPageThumb:fileURL page:number password:phrase guid:guid];
         }
         ];
        
		newPageSet = nil; // Release new page set
        
		[mainPagebar updatePagebar]; // Update the pagebar display
        
		[self updateToolbarBookmarkIcon]; // Update bookmark
        
		currentPage = page; // Track current page number
	}
    
    for (UIView *view in [theScrollView subviews] )
    {
        if ([view isKindOfClass:[ReaderContentView class]]) {
            
            [(ReaderContentView *)view cannotPainting];
            [(ReaderContentView *)view loadDrawDataBook:userName and:(int)bookId and:(int)currentPage];
            
            
        }
        
    }
    
}

- (void)showDocument:(id)object
{
	[self updateScrollViewContentSize]; // Set content size
    
	[self showDocumentPage:[document.pageNumber integerValue]];
    NSLog(@"%ld",(long)[document.pageNumber integerValue]);
	document.lastOpen = [NSDate date]; // Update last opened date
    
	isVisible = YES; // iOS present modal bodge
}



//TODO: --网络请求
-(void)AsihttpRequest:(NSString *)urlstr and:(NSString*)remark  {
    //***************************************************************************//
    BooksInfo * bookinfo=[[BooksInfo alloc] init];
    NSString *selectSql=[NSString stringWithFormat:Select_sql_UserInfo];
	NSMutableArray *uuidArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];
    NSLog(@"--uuid arr--%lu\n%@",(unsigned long)uuidArr.count,uuidArr);
    if (uuidArr.count>0) {
        
        bookinfo.UUID=[[uuidArr objectAtIndex:0] objectForKey:@"UUID"];
        bookinfo.userName=[[uuidArr objectAtIndex:0] objectForKey:@"UserID"];
        NSLog(@"-------userName------%@",userName);
    }

    bookinfo.urlStr=(NSMutableString *)urlstr;
    NSLog(@"%@",remark);
    if (!isRemark) {
        bookinfo.body=(NSMutableString *)[NSString stringWithFormat:@"{\"remark\":\"%@\",\"bookId\":\"%d\", \"bookPage\":\"%ld\",\"userId\":\"%@\"}",remark,self.bookId,(long)currentPage,userName];
        NSLog(@"%d",self.bookId);
        bookinfo.bodyKey=(NSMutableString *)@"strRemarkString";
        NSLog(@"%@",bookinfo.body);
        
        asyrequest=[AsyRequestServer getInstance];
        asyrequest.requestType=1;
        asyrequest.logType=@"sda";
        [asyrequest requestFormDataWithNewObject:bookinfo fromeDelegate:self];
    }else{
        
        
        asyrequest2=[AsyRequestServer getInstance];
        asyrequest2.requestType=1;
        asyrequest.logType=@"sda";
        [asyrequest2 requestFormDataWithNewObject:bookinfo fromeDelegate:self UserName:userName BookId:self.bookId];
        
    }
    
    //***************************************************************************//
    
}

-(void)requestFinished:(ASIFormDataRequest *)request
{

    if (!isRemark) {
        NSLog(@"%@",[request responseString]);
        if ([request responseStatusCode]==200 ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"操作成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"操作失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }else{
        NSLog(@"%@",[request responseString]);
        NSString *remarkstr = [request responseString];
        
        remarkArr = [remarkstr JSONValue];
        NSLog(@"%@",remarkArr);
    }
    
}
-(void)requestFailed:(ASIFormDataRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"操作失败，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}


#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
	id reader = nil; // ReaderViewController object
    
	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            
			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];
            
			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
            
			[object updateProperties]; document = object; // Retain the supplied ReaderDocument object for our use
            
			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
            
			reader = self; // Return an initialized ReaderViewController object
		}
	}
    
	return reader;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    isRed = NO;
    isBlack = NO;
    isBlue = NO;
    isRemark = NO;
    bShowMark=NO;
    NSString *selectSql=[NSString stringWithFormat:Select_sql_UserInfo];
	NSMutableArray *uuidArr=[[SaffronClientSQLManager getInstance] selectWithSqlSentenceN:selectSql];
    NSLog(@"--uuid arr--%lu\n%@",(unsigned long)uuidArr.count,uuidArr);
    NSString *uuidstring=nil;
    if (uuidArr.count>0) {
        
        uuidstring=[[uuidArr objectAtIndex:0] objectForKey:@"UUID"];
        userName=[[uuidArr objectAtIndex:0] objectForKey:@"UserID"];
        NSLog(@"-------userName------%@",userName);
    }
    
	assert(document != nil); // Must have a valid ReaderDocument
    
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
   //UIApplication* myDelegate =(UIApplication *)[[UIApplication sharedApplication] delegate];
	//CGRect viewRect = self.view.bounds; // View controller's view bounds
     CGRect viewRect = CGRectMake(0, 0, 768, 1024);
	theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All
    
	theScrollView.scrollsToTop = NO;
    theScrollView.scrollEnabled = YES;
	theScrollView.pagingEnabled = YES;
	theScrollView.delaysContentTouches = NO;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.userInteractionEnabled = YES;
	theScrollView.autoresizesSubviews = NO;
	theScrollView.delegate = self;
	[self.view addSubview:theScrollView];
    
    //    NSArray *colors = [NSArray arrayWithObjects:@"red",@"black" ,@"blue",nil];
    widthView =[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 180, 60)];
    for (int i =0; i<5; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(30*i+20, 15, 20, 30);
        button.tag = 3000+i;
        switch (i) {
            case 0:
                // button.backgroundColor = [UIColor redColor];
                //                [button setTintColor:[UIColor blueColor]];
                [button setTitle:@"10" forState:UIControlStateNormal];
                break;
            case 1:
                //button.backgroundColor = [UIColor blackColor];
                [button setTitle:@"15" forState:UIControlStateNormal];
                break;
            case 2:
                //button.backgroundColor = [UIColor blueColor];
                [button setTitle:@"20" forState:UIControlStateNormal];
                break;
            case 3:
                //button.backgroundColor = [UIColor blueColor];
                [button setTitle:@"25" forState:UIControlStateNormal];
                break;
            case 4:
                //button.backgroundColor = [UIColor blueColor];
                [button setTitle:@"30" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        [button addTarget:self action:@selector(widthSelect:) forControlEvents:UIControlEventTouchUpInside];
        [widthView addSubview:button];
    }
    
    colorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120, 60)];
    for (int i =0; i<3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30*i+20, 15, 20, 30);
        button.tag = 2000+i;
        switch (i) {
            case 0:
                button.backgroundColor = [UIColor redColor];
                break;
            case 1:
                button.backgroundColor = [UIColor blackColor];
                
                break;
            case 2:
                button.backgroundColor = [UIColor blueColor];
                
                break;
                
            default:
                break;
        }
        [button addTarget:self action:@selector(colorSelect:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:button];
    }
    
	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;
    notesBar = [[UIView alloc] initWithFrame:toolbarRect];
    notesBar.hidden = YES;
    notesBar.backgroundColor = [UIColor grayColor];//@"保存",@"颜色",@"粗细",@"清屏",@"撤销",@"取消",@"同步"
    NSArray *notes = [NSArray arrayWithObjects:@"颜色",@"粗细",@"清屏",@"撤销",@"保存",@"取消",@"下载",nil];
    CGRect buttonRect = notesBar.bounds;
    UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H"];
    UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N"];
    UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    for (int i = 0; i<7; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(i*80+60, buttonRect.origin.y+5, 50, buttonRect.size.height-10);
        [button setTitle:[notes objectAtIndex:i] forState:UIControlStateNormal];
        [button setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[button setBackgroundImage:buttonN forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(noteButton:) forControlEvents:UIControlEventTouchUpInside];
        [notesBar addSubview:button];
    }
    [self.view addSubview:notesBar];
    
    
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document]; // At top
    
	mainToolbar.delegate = self;
    
	[self.view addSubview:mainToolbar];
    
	CGRect pagebarRect = viewRect;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);
    
	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom
    
	mainPagebar.delegate = self;
    
	[self.view addSubview:mainPagebar];
    
	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
	[self.view addGestureRecognizer:singleTapOne];
    
	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
	[self.view addGestureRecognizer:doubleTapOne];
    
	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
	[self.view addGestureRecognizer:doubleTapTwo];
    
	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail
    
	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
    
    timer=[NSTimer scheduledTimerWithTimeInterval:6
                                           target:self
                                         selector:@selector(navBarTimer)
                                         userInfo:nil
                                          repeats:YES];
  /*
	UITapGestureRecognizer *singleTapThree = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarHidden:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapThree.numberOfTapsRequired = 1; singleTapThree.delegate = self;
	[self.view addGestureRecognizer:singleTapThree];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    [imgView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:imgView];
    UISwipeGestureRecognizer *swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    
    [imgView addGestureRecognizer:swipeGesture];
      */
  slider=[[UISlider alloc] initWithFrame:CGRectMake(600, 664, 227, 20)];
    	slider.minimumValue = 0;
 	slider.maximumValue = 1;
	slider.value = 0.5;
    CGAffineTransform rotation = CGAffineTransformMakeRotation(degressToRadian(90));
    slider.transform = rotation;
    [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];

}

-(void)updateValue:(id)sender{
    
    [[UIScreen mainScreen] setBrightness:slider.value];

}
-(void)handleSwipeGesture:(UIGestureRecognizer*)sender{
    
       //划动的方向
    
        UISwipeGestureRecognizerDirection direction=[(UISwipeGestureRecognizer*) sender direction];
    
       //判断是上下左右
    
       switch (direction) {
            
             case UISwipeGestureRecognizerDirectionUp:
            
                     NSLog(@"up");
            
                    break;
            
                 case UISwipeGestureRecognizerDirectionDown:
                   NSLog(@"down");
                 break;
           default:
               
              break;
       }
}
-(void)navBarHidden:(UITapGestureRecognizer *)tap{
    NSLog(@"nimabi");
//    [mainToolbar setHidden:NO];
//    [mainPagebar setHidden:NO];

}
-(void)navBarTimer{
    
//    [mainToolbar setHidden:YES];
//    [mainPagebar setHidden:YES];
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [theScrollView setBackgroundColor:[UIColor whiteColor]];
//    CGRect viewRect = CGRectMake(0, 0, 768, 1024);
//    theScrollView.frame=viewRect;
    slider.hidden=YES;

}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateScrollViewContentViews]; // Update content views
		}
        
		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [self showDocumentPage:[document.pageNumber integerValue]];
	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
	{
		[self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
	}
    if (bShowMark) {
        [self ShowMarkPage];
        bShowMark=NO;
    }
    
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	lastAppearSize = self.view.bounds.size; // Track view size
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
	[UIApplication sharedApplication].idleTimerDisabled = NO;
    
#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	mainToolbar = nil; mainPagebar = nil;
    
	theScrollView = nil; contentViews = nil; lastHideTime = nil;
    
	lastAppearSize = CGSizeZero; currentPage = 0;
    
	[super viewDidUnload];
}
//- (BOOL)prefersStatusBarHidden
//
//{
//
//    return YES;
//
//}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
    
	[self updateScrollViewContentViews]; // Update content views
    
	lastAppearSize = CGSizeZero; // Reset view size tracking
}

/*
 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
 {
 //if (isVisible == NO) return; // iOS present modal bodge
 
 //if (fromInterfaceOrientation == self.interfaceOrientation) return;
 }
 */

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	__block NSInteger page = 0;
    
	CGFloat contentOffsetX = scrollView.contentOffset.x;
    
	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(id key, id object, BOOL *stop)
     {
         ReaderContentView *contentView = object;
         
         if (contentView.frame.origin.x == contentOffsetX)
         {
             page = contentView.tag; *stop = YES;
         }
     }
     ];
    
	if (page != 0) [self showDocumentPage:page]; // Show the page
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //	[self showDocumentPage:theScrollView.tag]; // Show page
    //
    //	theScrollView.tag = 0; // Clear page number tag
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
        
		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;
            
			contentOffset.x -= theScrollView.bounds.size.width; // -= 1
            
			[theScrollView setContentOffset:contentOffset animated:YES];
            
			theScrollView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
        
		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;
            
			contentOffset.x += theScrollView.bounds.size.width; // += 1
            
			[theScrollView setContentOffset:contentOffset animated:YES];
            
			theScrollView.tag = (page + 1); // Increment page number
		}
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds
        
		CGPoint point = [recognizer locationInView:recognizer.view];
        
		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area
        
		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #
            
			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			id target = [targetView processSingleTap:recognizer]; // Target
            
			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object
                    
					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string
                        
						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [NSString stringWithFormat:@"http://%@", www];
                            
							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}
                    
					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
#ifdef DEBUG
                        NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
#endif
					}
				}
				else // Not a URL, so check for other possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger value = [target integerValue]; // Number
                        
						[self showDocumentPage:value]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
					if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
					{
						[mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
					}
				}
			}
            
			return;
		}
        
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}
        
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
        
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds
        
		CGPoint point = [recognizer locationInView:recognizer.view];
        
		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);
        
		if (CGRectContainsPoint(zoomArea, point)) // Double tap is in the zoom area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #
            
			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom ++
				{
					[targetView zoomIncrement]; break;
				}
                    
				case 2: // Two finger double tap: zoom --
				{
					[targetView zoomDecrement]; break;
				}
			}
            
			return;
		}
        
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}
        
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
        
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
        for (UIView *view in [theScrollView subviews] )
        {
            if ([view isKindOfClass:[ReaderContentView class]]) {
                if (view.tag == currentPage) {
                    NSLog(@"%ld",(long)view.tag);
                    //                        view.userInteractionEnabled = NO;
                    [(ReaderContentView *)view cannotPainting];
                    remarkStr = [(ReaderContentView *)view saveDrawDataBook:userName and:self.bookId and:(int)currentPage];
                    
                    //     //取上传所需参数
//                    NSString *remarkStr1;
//                    NSString *str = [NSString stringWithFormat:@"Documents/%@/%d/%d",userName,self.bookId,currentPage];
//                    NSString *path=[NSHomeDirectory() stringByAppendingPathComponent:str];
//                    NSLog(@"%@",path);
//                    NSString *dataNameStr = [NSString stringWithFormat:@"/data:%d",currentPage];
//                    NSString *infoNameStr = [NSString stringWithFormat:@"/info:%d",currentPage];
//                    NSFileManager *fileManager = [NSFileManager defaultManager];
//                    BOOL fileExists = [fileManager fileExistsAtPath:path];
//                    if (fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
//                        NSString *tmp1;
//                        NSString *tmp2;
//                        tmp1 = [NSString stringWithContentsOfFile:[path stringByAppendingString:dataNameStr] encoding:NSUTF8StringEncoding error:nil];
//                        tmp2 = [NSString stringWithContentsOfFile:[path stringByAppendingString:infoNameStr] encoding:NSUTF8StringEncoding error:nil];
//                        ////                            tmp1 = @"whats";
//                        ////                            tmp2 = @"wrong";
//                        remarkStr1 = [NSString stringWithFormat:@"%@$$%@",tmp1,tmp2];
//                        ////                            remarkStr=@"fsd";
//                        remarkStr1 = [remarkStr1 stringByReplacingOccurrencesOfString:@"<" withString:@"("];
//                        remarkStr1 = [remarkStr1 stringByReplacingOccurrencesOfString:@">" withString:@")"];
//                        remarkStr1 = [remarkStr1 stringByReplacingOccurrencesOfString:@"<" withString:@"("];
//                        remarkStr1 = [remarkStr1 stringByReplacingOccurrencesOfString:@":" withString:@"*"];
//                        remarkStr1 = [remarkStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"&"];
//                        remarkStr1 = [remarkStr1 stringByReplacingOccurrencesOfString:@"/" withString:@"^"];
//                        
//                    }

                    
                    
                }
                
                
            }
            
        }
    if (buttonIndex==0) {
        if (![self.IPurlstr isEqualToString:@""] && self.IPurlstr!=nil) {
          //  [self AsihttpRequest:[NSString stringWithFormat:@"http://%@:8001/UploadRemark.ashx",self.IPurlstr] and:remarkStr];
            [self AsihttpRequest:[NSString stringWithFormat:@"http://%@:8080/zongyuan/archive/tech/recordsDetail/",self.IPurlstr] and:remarkStr];
        }else{
            
            NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            //creates paths so that you can pull the app's path from it
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"url1.plist"];
            NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:dataPath];
            NSString *urlStr=[NSString stringWithFormat:@"%@",[dTmp valueForKey:@"url1"]];
            [self AsihttpRequest:[NSString stringWithFormat:@"http://%@:8080/zongyuan/archive/tech/recordsDetail/",urlStr] and:remarkStr];
        }
    }
}

-(void)showAlt{
    
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"消息提示" message:@"保存成功，是否上传到服务器？"
                                                  delegate:self
                                         cancelButtonTitle:@"是"
                                         otherButtonTitles:@"否",nil];
    [alert show];
}
- (void)noteButton:sender
{
    
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 0:
            [self popover:button];
            break;
        case 1:
            [self popover:button];
            break;
        case 2:
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    if (view.tag == currentPage) {
                        //                        view.userInteractionEnabled = YES;
                        [(ReaderContentView *)view canPainting];
                        [(ReaderContentView *)view clearBrush];
                        
                        
                    }
                }
                
            }
            
            break;
        case 3:
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    
                    if (view.tag == currentPage) {
                        //                        view.userInteractionEnabled = YES;
                        [(ReaderContentView *)view canPainting];
                        [(ReaderContentView *)view commandZ];
                        
                        
                    }
                    
                    
                }
                
            }
            
            break;
        case 4:
        {
            isRemark = NO;
            theScrollView.scrollEnabled = YES;
            
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    
                    if (view.tag == currentPage) {
                        //   view.userInteractionEnabled = NO;
                        [(ReaderContentView *)view setIsDisableZoom:NO];
                    }
                }
                
            }
            NSString *keepBookSql=[NSString stringWithFormat:update_sql_BookNote,bookId];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:keepBookSql];
            [self showAlt];
            notesBar.hidden = YES;
            mainToolbar.hidden = NO;

            break;
        }
        case 5:
            theScrollView.scrollEnabled = YES;
            
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    
                    if (view.tag == currentPage) {
                        //                        view.userInteractionEnabled = NO;
                        [(ReaderContentView *)view cannotPainting];
                         [(ReaderContentView *)view setIsDisableZoom:NO];
                    }
                }
                
            }
            notesBar.hidden = YES;
            mainToolbar.hidden = NO;
            
            break;
            
        case 6:
            
            theScrollView.scrollEnabled = YES;
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    if (view.tag == currentPage) {
                        //                        view.userInteractionEnabled = NO;
                        [(ReaderContentView *)view cannotPainting];
                        [(ReaderContentView *)view setIsDisableZoom:NO];

                        isRemark = YES;
                        if (![self.IPurlstr isEqualToString:@""] && self.IPurlstr!=nil) {
                            //[self AsihttpRequest:[NSString stringWithFormat:@"http://%@:8001/ReturnRemark.ashx",self.IPurlstr] and:nil];
                            [self AsihttpRequest:[NSString stringWithFormat:@"http://%@:8080/zongyuan/archive/tech/recordsDetail/list",self.IPurlstr] and:nil];
                        }else{
                            
                            NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                            //creates paths so that you can pull the app's path from it
                            NSString *documentsDirectory = [paths objectAtIndex:0];
                            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"url1.plist"];
                            NSDictionary *dTmp=[[NSDictionary alloc] initWithContentsOfFile:dataPath];
                            NSString *urlStr=[NSString stringWithFormat:@"%@",[dTmp valueForKey:@"url1"]];
                           // [self AsihttpRequest:[NSString stringWithFormat:@"http://%@:8001/ReturnRemark.ashx",urlStr] and:nil];
                              [self AsihttpRequest:[NSString stringWithFormat:@"http://%@:8080/zongyuan/archive/tech/recordsDetail/list",urlStr] and:nil];
                        }
                        if (remarkArr.count>0) {
                            for (int i = 0; i<remarkArr.count; i++) {
                                int bookid = [[[remarkArr objectAtIndex:i] objectForKey:@"bookId"] intValue];
                                int bookpage = [[[remarkArr objectAtIndex:i] objectForKey:@"bookPage"] intValue];
                                NSArray *datas = [[[remarkArr objectAtIndex:i] objectForKey:@"remark"]componentsSeparatedByString:@"$$"];//RemarkContent
                                NSArray *remarkData = [[datas objectAtIndex:0] componentsSeparatedByString:@"*"];
                                NSArray *remarkInfo = [[datas objectAtIndex:1] componentsSeparatedByString:@"*"];
                                NSLog(@"%@",remarkData);
                                NSLog(@"%@",remarkInfo);
                                
                                [(ReaderContentView *)view saveDrawDataBook:userName and:bookid and:bookpage and:remarkData and:remarkInfo];
                                [(ReaderContentView *)view loadDrawDataBook:userName and:self.bookId and:(int)currentPage];
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            notesBar.hidden = YES;
            mainToolbar.hidden = NO;
            
            break;
            
        default:
            
            break;
    }
}

#pragma mark ReaderContentViewDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar noteButton:(UIButton *)button
{
    //self.drawingView.userInteractionEnabled = YES;
    
    
    
	if (theScrollView.scrollEnabled) {
        theScrollView.scrollEnabled = NO;
      
        for (UIView *view in [theScrollView subviews] )
        {
            if ([view isKindOfClass:[ReaderContentView class]]) {
                //                view.userInteractionEnabled = YES;
                [(ReaderContentView *)view canPainting];
                [(ReaderContentView *)view DoImage];
                 [(ReaderContentView *)view zoomReset];
                /////在ReaderContentView中添加了一个属性isDisableZoom 这已经来禁用放到缩小，批注完成之后设置成NO就可以了
                [(ReaderContentView *)view setIsDisableZoom:YES];
                
                notesBar.hidden = NO;
                mainToolbar.hidden = YES;
                
                NSString *keepBookSql=[NSString stringWithFormat:update_sql_BookCover,bookId];
                [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:keepBookSql];
            }
            
        }
        
    }
    
    
    //self.drawingView.userInteractionEnabled = NO;
    
    
    //theScrollView.scrollEnabled = NO;
}


- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
    slider.hidden=NO;
	if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info
            
			CGPoint point = [touch locationInView:self.view]; // Touch location
            
			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);
            
			if (CGRectContainsPoint(areaRect, point) == false) return;
		}
        
		//[mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // Hide
        
		lastHideTime = [NSDate date];
	}
    
//    else {
//        
//        if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
//        {
//            if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
//            {
//                [mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
//            }
//        }
//        
//    }
}

#pragma mark ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option
    
	[document saveReaderDocument]; // Save any ReaderDocument object changes
    
	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];
    
	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache
    
	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss
    
	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
	}
	else // We have a "Delegate must respond to -dismissReaderViewController: error"
	{
		NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
	}
    
#endif // end of READER_STANDALONE Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss
    
	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];
    
	thumbsViewController.delegate = self; thumbsViewController.title = self.title;
    
	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
        [self presentModalViewController:thumbsViewController animated:YES];
    }
    else{
        [self presentViewController:thumbsViewController animated:YES completion:^{
            
        }];
    }
}
-(void)ShowMarkPage
{
    if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss
    
	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];
    
	thumbsViewController.delegate = self; thumbsViewController.title = self.title;
    
	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
        [self presentModalViewController:thumbsViewController animated:YES];
    }
    else{
        [self presentViewController:thumbsViewController animated:YES completion:^{
            
        }];
    }

    [thumbsViewController ShowBookMarkPage];
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
#if (READER_ENABLE_PRINT == TRUE) // Option
    
	Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");
    
	if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
	{
		NSURL *fileURL = document.fileURL; // Document file URL
        
		printInteraction = [printInteractionController sharedPrintController];
        
		if ([printInteractionController canPrintURL:fileURL] == YES) // Check first
		{
			UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];
            
			printInfo.duplex = UIPrintInfoDuplexLongEdge;
			printInfo.outputType = UIPrintInfoOutputGeneral;
			printInfo.jobName = document.fileName;
            
			printInteraction.printInfo = printInfo;
			printInteraction.printingItem = fileURL;
			printInteraction.showsPageRange = YES;
            
			if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				[printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
			}
			else // Presume UIUserInterfaceIdiomPhone
			{
				[printInteraction presentAnimated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
			}
		}
	}
    
#endif // end of READER_ENABLE_PRINT Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
#if (READER_ENABLE_MAIL == TRUE) // Option
    
	if ([MFMailComposeViewController canSendMail] == NO) return;
    
	if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
	unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
    
	if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
	{
		NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName; // Document
        
		NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
        
		if (attachment != nil) // Ensure that we have valid document file attachment data
		{
			MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
            
			[mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];
            
			[mailComposer setSubject:fileName]; // Use the document file name for the subject
            
			mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
            
			mailComposer.mailComposeDelegate = self; // Set the delegate
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
                [self presentModalViewController:mailComposer animated:YES];
            }
            else{
                [self presentViewController:mailComposer animated:YES completion:^{
                    
                }];
            }
		}
	}
    
#endif // end of READER_ENABLE_MAIL Option
}

-(void)widthSelect:(id)sender
{
    UIButton *widthButton = (UIButton *)sender;
    switch (widthButton.tag) {
        case 3000:
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    //view.userInteractionEnabled = YES;
                    [(ReaderContentView *)view penThickness:20 :20];
                    //[(ReaderContentView *)view DoImage];
                }
                
            }
            
            break;
        case 3001:
            
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    //view.userInteractionEnabled = YES;
                    [(ReaderContentView *)view penThickness:30 :30];                    //[(ReaderContentView *)view DoImage];
                }
                
            }
            
            break;
        case 3002:
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    //view.userInteractionEnabled = YES;
                    [(ReaderContentView *)view penThickness:40 :40];                    //[(ReaderContentView *)view DoImage];
                }
                
            }
            
            break;
        case 3003:
            
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    //view.userInteractionEnabled = YES;
                    [(ReaderContentView *)view penThickness:60 :60];                    //[(ReaderContentView *)view DoImage];
                }
                
            }
            
            break;
        case 3004:
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    //view.userInteractionEnabled = YES;
                    [(ReaderContentView *)view penThickness:80 :80];                    //[(ReaderContentView *)view DoImage];
                }
                
            }
            
            break;

            
        default:
            break;
            
    }
    if (popover) {
        [popover dismissPopoverAnimated:YES];
    }
}

-(void)colorSelect:(id)sender
{
    UIButton *colorButton = (UIButton *)sender;
    switch (colorButton.tag) {
        case 2000:
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    //view.userInteractionEnabled = YES;
                    [(ReaderContentView *)view redBrush];
                    isRed = YES;
                    isBlack = NO;
                    isBlue = NO;
                }
                
            }
            
            break;
        case 2001:
            
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    //view.userInteractionEnabled = YES;
                    [(ReaderContentView *)view blackBrush];
                    isRed = NO;
                    isBlack = YES;
                    isBlue = NO;
                }
                
            }
            
            break;
        case 2002:
            for (UIView *view in [theScrollView subviews] )
            {
                if ([view isKindOfClass:[ReaderContentView class]]) {
                    //view.userInteractionEnabled = YES;
                    [(ReaderContentView *)view blueBrush];
                    isRed = NO;
                    isBlack = NO;
                    isBlue = YES;
                }
                
            }
            
            break;
            
            
        default:
            break;
            
    }
    if (popover) {
        [popover dismissPopoverAnimated:YES];
    }
}
-(void)popover:(id)sender
{
    //the controller we want to present as a popover
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag) {
        case 1001:
        {
            outline = [[OutlineViewController alloc] init];
            outline.delegate = self;
            
            if (popover) {
                popover = nil;
            }
            popover = [[UIPopoverController alloc]initWithContentViewController:outline];
            popover.delegate = self;
            popover.popoverContentSize =CGSizeMake(outline.view.bounds.size.width/2, outline.view.bounds.size.height-130);
            outline.contentSizeForViewInPopover=outline.view.bounds.size;
            [popover presentPopoverFromRect:((UIView *)sender).bounds
                                     inView:(UIView *)sender
                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
            break;
        case 0:
        {
            if (popover) {
                popover = nil;
            }
            UINavigationController *navController = [[UINavigationController alloc] init];
            navController.view.backgroundColor = [UIColor whiteColor];
            navController.navigationBarHidden = YES;
            popover = [[UIPopoverController alloc]initWithContentViewController:navController];
            
            popover.delegate = self;
            popover.popoverContentSize = colorView.bounds.size;
            [popover presentPopoverFromRect:((UIView *)sender).bounds
                                     inView:(UIView *)sender
                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            //            colorView.backgroundColor = [UIColor greenColor];
            [popover.contentViewController.view addSubview:colorView];
        }
            break;
            
        case 1:
        {
            if (popover) {
                popover = nil;
            }
            UINavigationController *navController1 = [[UINavigationController alloc] init];
            navController1.view.backgroundColor = [UIColor whiteColor];
            navController1.navigationBarHidden = YES;
            popover = [[UIPopoverController alloc]initWithContentViewController:navController1];
            
            popover.delegate = self;
            popover.popoverContentSize = widthView.bounds.size;
            [popover presentPopoverFromRect:((UIView *)sender).bounds
                                     inView:(UIView *)sender
                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            //            colorView.backgroundColor = [UIColor greenColor];
            [popover.contentViewController.view addSubview:widthView];
        }
            break;
            
        default:
            break;
    }
    
    
}
-(void)tableView:(UITableView *)tableView didSelectIndex:(int)page
{
    [self showDocumentPage:page];
    [popover dismissPopoverAnimated:NO];
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController*)popoverController
{
    
    if (popover)
    {
        [popover dismissPopoverAnimated:YES];
        
        popover = nil;
    }
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar outlineButton:(UIButton *)button
{
    //
    //    }];
    [self popover:button];
    //目录
}
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
	if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
	NSInteger page = [document.pageNumber integerValue];
    
	if ([document.bookmarks containsIndex:page]) // Remove bookmark
	{
		[mainToolbar setBookmarkState:NO]; [document.bookmarks removeIndex:page];
        if ([document.bookmarks count]==0) {
            NSString *keepBookSql=[NSString stringWithFormat:update_sql_canleBookMark,bookId];
            [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:keepBookSql];

        }
	}
	else // Add the bookmarked page index to the bookmarks set
	{
        NSString *keepBookSql=[NSString stringWithFormat:update_sql_BookMark,bookId];
        [[SaffronClientSQLManager getInstance] modifyMainSqlWithSqlSentence:keepBookSql];

		[mainToolbar setBookmarkState:YES]; [document.bookmarks addIndex:page];
	}
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
    if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
   
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
	[self updateToolbarBookmarkIcon]; // Update bookmark icon
    
	[self dismissModalViewControllerAnimated:NO]; // Dismiss
}

//缩略图
- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
	[self showDocumentPage:page]; // Show the page
    
}

#pragma mark ReaderMainPagebarDelegate methods
//底部pagebar
- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
    [self showDocumentPage:page]; // Show the page
    
    if (!theScrollView.scrollEnabled) {
        for (UIView *view in [theScrollView subviews] )
        {
            if ([view isKindOfClass:[ReaderContentView class]]) {
                //                view.userInteractionEnabled = YES;
                [(ReaderContentView *)view canPainting];
                
            }
            
        }
        
    }
    
    
}

#pragma mark UIApplication notification methods

- (void)applicationWill:(NSNotification *)notification
{
	[document saveReaderDocument]; // Save any ReaderDocument object changes
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

@end
