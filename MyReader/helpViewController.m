//
//  helpViewController.m
//  MyReader
//
//  Created by baby on 14-6-9.
//  Copyright (c) 2014年 NJGuo. All rights reserved.
//

#import "helpViewController.h"

@interface helpViewController ()

@end

@implementation helpViewController
@synthesize myWebView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor=[UIColor clearColor];
//    UIImageView *bgImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newbg.png"]];
//    [bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.view addSubview:bgImageView];

    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(5, 2, 40, 40)];
    [backBtn setImage:[UIImage imageNamed:@"newback.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * barBtn=[[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = barBtn;

    CGRect frame = [self frameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.view.frame = frame;//重新定义frame
    myWebView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    NSString *urlStr=[NSString stringWithFormat:@"http://%@:8080/zongyuan/help/index.html",[self getIpUrl]];
    
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url];
    
    [myWebView loadRequest:request];
    
    [myWebView setUserInteractionEnabled:YES];
    [self.view addSubview:myWebView];

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

-(void)backAction
{
    
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = [self frameForOrientation:interfaceOrientation];
    self.view.frame = frame;//重新定义frame
    [myWebView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

}
@end
