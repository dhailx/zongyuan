//
//	ReaderMainToolbar.m
//	Reader v2.6.1
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
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"
#import "PublicClassHeader.h"
#import <MessageUI/MessageUI.h>

#import "SaffronClientSQLManager.h"
#import "NetworkMonitor.h"
#import "AsyRequestServer.h"
#import "Reachability.h"
#import "BooksInfo.h"
#import "SBJson.h"
#import "MBProgressHUD.h"
@implementation ReaderMainToolbar
{
	UIButton *markButton;

	UIImage *markImageN;
	UIImage *markImageY;
}

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define DONE_BUTTON_WIDTH 56.0f
#define THUMBS_BUTTON_WIDTH 40.0f
#define PRINT_BUTTON_WIDTH 40.0f
#define EMAIL_BUTTON_WIDTH 40.0f
#define MARK_BUTTON_WIDTH 40.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame document:nil];
}

- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object
{
	assert(object != nil); // Must have a valid ReaderDocument

	if ((self = [super initWithFrame:frame]))
	{
		CGFloat viewWidth = self.bounds.size.width;

		UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H"];
		UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N"];

		UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];

		CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));

		CGFloat leftButtonX = BUTTON_X; // Left button start X position

#if (READER_STANDALONE == FALSE) // Option

		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];

		doneButton.frame = CGRectMake(leftButtonX, BUTTON_Y, THUMBS_BUTTON_WIDTH, BUTTON_HEIGHT);
		//[doneButton setTitle:NSLocalizedString(@"Done", @"button") forState:UIControlStateNormal];
        [doneButton setTitle:@"返回" forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[doneButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[doneButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		doneButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
		doneButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:doneButton]; leftButtonX += (DONE_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (DONE_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);

#endif // end of READER_STANDALONE Option

#if (READER_ENABLE_THUMBS == TRUE) // Option

		UIButton *thumbsButton = [UIButton buttonWithType:UIButtonTypeCustom];

		thumbsButton.frame = CGRectMake(leftButtonX-15, BUTTON_Y, THUMBS_BUTTON_WIDTH, BUTTON_HEIGHT);
		[thumbsButton setImage:[UIImage imageNamed:@"Reader-Thumbs"] forState:UIControlStateNormal];
		[thumbsButton addTarget:self action:@selector(thumbsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[thumbsButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[thumbsButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		thumbsButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:thumbsButton]; //leftButtonX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

#endif // end of READER_ENABLE_THUMBS Option


#if (READER_BOOKMARKS == TRUE || READER_ENABLE_MAIL == TRUE || READER_ENABLE_PRINT == TRUE)

        NSLog(@"%f",ScreenWidth);
		CGFloat rightButtonX = ScreenWidth; // Right button start X position

#endif // end of READER_BOOKMARKS || READER_ENABLE_MAIL || READER_ENABLE_PRINT Options

#if (READER_BOOKMARKS == TRUE) // Option

		rightButtonX -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);

		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];

		flagButton.frame = CGRectMake(rightButtonX, BUTTON_Y, MARK_BUTTON_WIDTH, BUTTON_HEIGHT);
		//[flagButton setImage:[UIImage imageNamed:@"Reader-Mark-N"] forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(markButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[flagButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[flagButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		flagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

		[self addSubview:flagButton]; titleWidth -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);

		markButton = flagButton; markButton.enabled = NO; markButton.tag = NSIntegerMin;

		markImageN = [UIImage imageNamed:@"Reader-Mark-N"]; // N image
		markImageY = [UIImage imageNamed:@"Reader-Mark-Y"]; // Y image

#endif // end of READER_BOOKMARKS Option
        //目录按钮
        
        UIButton *outlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
//		outlineButton.frame = CGRectMake(rightButtonX-100, BUTTON_Y, EMAIL_BUTTON_WIDTH, BUTTON_HEIGHT);
        outlineButton.frame =CGRectMake(leftButtonX+50-15, BUTTON_Y, THUMBS_BUTTON_WIDTH, BUTTON_HEIGHT);
        outlineButton.tag = 1001;
//		[outlineButton setImage:[UIImage imageNamed:@"contents"] forState:UIControlStateNormal];
        [outlineButton setTitle:@"目录" forState:UIControlStateNormal];
        [outlineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        outlineButton.titleLabel.textColor = [UIColor blackColor];
        outlineButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [outlineButton addTarget:self action:@selector(outlineButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[outlineButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[outlineButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		outlineButton.autoresizingMask = UIViewAutoresizingNone;
        
//		[self addSubview:outlineButton];
        
        
        UIButton *noteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        noteButton.frame = CGRectMake(rightButtonX-60, BUTTON_Y, EMAIL_BUTTON_WIDTH, BUTTON_HEIGHT);
        [noteButton setTitle:@"批注" forState:UIControlStateNormal];
        // noteButton.titleLabel.textColor = [UIColor blackColor];
        [noteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        noteButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [noteButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[noteButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		noteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [noteButton addTarget:self action:@selector(noteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:noteButton];
//        UIButton *piZhuBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//        [piZhuBtn setFrame:CGRectMake(rightButtonX-100, BUTTON_Y, EMAIL_BUTTON_WIDTH, BUTTON_HEIGHT)];
//        [piZhuBtn setTitle:@"目录" forState:UIControlStateNormal];
//        [piZhuBtn setBackgroundColor:[UIColor grayColor]];
//        [self addSubview:piZhuBtn];
#if (READER_ENABLE_MAIL == TRUE) // Option

		if ([MFMailComposeViewController canSendMail] == YES) // Can email
		{
			unsigned long long fileSize = [object.fileSize unsignedLongLongValue];

			if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
			{
				rightButtonX -= (EMAIL_BUTTON_WIDTH + BUTTON_SPACE);

				UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];

				emailButton.frame = CGRectMake(rightButtonX, BUTTON_Y, EMAIL_BUTTON_WIDTH, BUTTON_HEIGHT);
				[emailButton setImage:[UIImage imageNamed:@"Reader-Email"] forState:UIControlStateNormal];
				[emailButton addTarget:self action:@selector(emailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
				[emailButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
				[emailButton setBackgroundImage:buttonN forState:UIControlStateNormal];
				emailButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

				//[self addSubview:emailButton]; titleWidth -= (EMAIL_BUTTON_WIDTH + BUTTON_SPACE);
			}
		}

#endif // end of READER_ENABLE_MAIL Option

#if (READER_ENABLE_PRINT == TRUE) // Option

		if (object.password == nil) // We can only print documents without passwords
		{
			Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

			if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
			{
				rightButtonX -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);

				UIButton *printButton = [UIButton buttonWithType:UIButtonTypeCustom];

				printButton.frame = CGRectMake(rightButtonX, BUTTON_Y, PRINT_BUTTON_WIDTH, BUTTON_HEIGHT);
				[printButton setImage:[UIImage imageNamed:@"Reader-Print"] forState:UIControlStateNormal];
				[printButton addTarget:self action:@selector(printButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
				[printButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
				[printButton setBackgroundImage:buttonN forState:UIControlStateNormal];
				printButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

				//[self addSubview:printButton]; titleWidth -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);
			}
		}

#endif // end of READER_ENABLE_PRINT Option

		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth-50, TITLE_HEIGHT);

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];

			titleLabel.textAlignment = NSTextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:19.0f];
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
			titleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumScaleFactor = 14.0f;
			titleLabel.text = [object.fileName stringByDeletingPathExtension];

			[self addSubview:titleLabel]; 
		}
	}

	return self;
}

- (void)setBookmarkState:(BOOL)state
{
#if (READER_BOOKMARKS == TRUE) // Option

	if (state != markButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (state ? markImageY : markImageN);

			[markButton setImage:image forState:UIControlStateNormal];
		}

		markButton.tag = state; // Update bookmarked state tag
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#if (READER_BOOKMARKS == TRUE) // Option

	if (markButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = markButton.tag; // Bookmarked state

		UIImage *image = (state ? markImageY : markImageN);

		[markButton setImage:image forState:UIControlStateNormal];
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
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
#pragma mark UIButton action methods
- (void)noteButtonTapped:(UIButton *)button
{
//    if (!button.selected) {
//        button.selected = YES;
//    }else{
//        button.selected = NO;
//    }
//
    
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
    bookinfo.urlStr=(NSMutableString *)[NSString stringWithFormat:isPizhu_request_url,[self getIpUrl]];
    bookinfo.UUID=uuidstring;
    bookinfo.userName=userName;

    ASIFormDataRequest * request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:bookinfo.urlStr]];
 //   request.delegate=delegate;
//    [request setDidFailSelector:@selector(requestFailed:)];//失败的代理方法
//    [request setDidFinishSelector:@selector(requestFinished:)];//成功的代理方法
    [request setRequestMethod:@"POST"];
    [request setPostValue:bookinfo.userName forKey:@"userId"];
    [request setPostValue:bookinfo.UUID forKey:@"deviceid"];
   
    [request setUserInfo:[NSDictionary dictionaryWithObject:bookinfo forKey:ASY_UpLoadRequestObjet_UseInfo]];  //设置详细信息
 
    
    [request startSynchronous];

    NSLog(@"-=-=-=-=-=   %@",[request responseString]);
    if ([[request responseString] isEqualToString:@"0"]) {
        
        UIAlertView *alt=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"未被授权批注功能，如需要，请联系后台管理人员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alt show];
        
    }else{
        
        [delegate tappedInToolbar:self noteButton:button];

    }


}


- (void)doneButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self doneButton:button];
}

- (void)thumbsButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self thumbsButton:button];
}

- (void)printButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self printButton:button];
}

- (void)emailButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self emailButton:button];
}

- (void)outlineButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self outlineButton:button];
}



- (void)markButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self markButton:button];
}

@end
