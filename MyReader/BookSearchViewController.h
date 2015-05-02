//
//  BookSearchViewController.h
//  MyReader
//
//  Created by YDJ on 13-5-26.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BooksInfo.h"

@protocol BookSearchDelegate;
@interface BookSearchViewController : UITableViewController

@property (nonatomic,strong)NSMutableArray * dataArray;

@property (nonatomic,assign)id<BookSearchDelegate>delegate;

@end

@protocol BookSearchDelegate <NSObject>

@optional
-(void)didSelectBookInfo:(BooksInfo *)bookInfo withOther:(NSDictionary *)other;

@end