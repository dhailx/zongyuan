//
//  OutlineViewController.h
//  Viewer
//
//  Created by qintao on 13-5-3.
//
//

#import <UIKit/UIKit.h>

@protocol OutlineViewControllerDelegate;
@interface OutlineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

{
   // id <OutlineViewControllerDelegate>_delegate;
    UITableView *_tableView;
}

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)    NSMutableArray *sourceArr;
@property (nonatomic, strong)    NSMutableArray *pageArr;
@property (nonatomic, unsafe_unretained, readwrite) id <OutlineViewControllerDelegate>delegate;


@end
@protocol OutlineViewControllerDelegate <NSObject>
@optional
- (void)tableView:(UITableView *)tableView didSelectIndex:(int)page;

@end