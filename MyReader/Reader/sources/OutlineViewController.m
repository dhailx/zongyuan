//
//  OutlineViewController.m
//  Viewer
//
//  Created by qintao on 13-5-3.
//
//

#import "OutlineViewController.h"
#import "ReaderDocumentOutline.h"

@interface OutlineViewController ()

@end

@implementation OutlineViewController
@synthesize tableView = _tableView;
@synthesize sourceArr = _sourceArr;
@synthesize pageArr = _pageArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       //self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect viewRect = self.view.bounds;
    viewRect.size.height = self.view.bounds.size.height- 130;
	// Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:viewRect style:UITableViewStylePlain ];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorColor:[UIColor clearColor]];
    _tableView.backgroundColor =  [UIColor colorWithRed:204.0/255 green:250.0/255 blue:207.0/255 alpha:1.0f];
//    titleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];

    //_sourceArr = [[NSMutableArray alloc] initWithCapacity:20];
    [_tableView reloadData];

    [self.view addSubview:_tableView];
}

//- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"Cell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    id entry = [_sourceArr objectAtIndex:indexPath.row];
    DocumentOutlineEntry *outlineEntry = (DocumentOutlineEntry *)entry;
    //NSLog(@"ddddddd%@",dic);
    cell.textLabel.text = outlineEntry.title;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
       
//    cell.textLabel.text = [_sourceArr objectAtIndex:indexPath.row] ;
//    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
//

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id entry = [_sourceArr objectAtIndex:indexPath.row];
    DocumentOutlineEntry *outlineEntry = (DocumentOutlineEntry *)entry;
   
         if (self.delegate&&[self.delegate respondsToSelector:@selector(tableView:didSelectIndex:)]) {
       
             [self.delegate tableView:_tableView didSelectIndex:[outlineEntry.target intValue]];
         }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
