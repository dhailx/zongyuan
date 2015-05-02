//
//  ImgViewController.m
//  MyReader
//
//  Created by baby on 14-6-12.
//  Copyright (c) 2014年 NJGuo. All rights reserved.
//

#import "ImgViewController.h"

@interface ImgViewController ()

@end

@implementation ImgViewController
@synthesize img;
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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"newbg.png"]]];

    // Do any additional setup after loading the view.
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navtitle.png"] forBarMetrics:UIBarMetricsDefault];
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(5, 2, 40, 40)];
    [backBtn setImage:[UIImage imageNamed:@"newback.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction1:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * barBtn=[[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = barBtn;
    
    UIImage *image=[UIImage imageWithContentsOfFile:img];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    CGSize newSize = CGSizeMake(self.view.frame.size.width , self.view.frame.size.height);
    
    [scrollView setContentSize:newSize];
    scrollView.delegate = self;
    
    scrollView.minimumZoomScale = 1;
    
    scrollView.maximumZoomScale = 30.0;
    
    scrollView.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:scrollView];
    
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame=scrollView.frame;
    [scrollView addSubview:imageView];
    
    imageView.tag = 22;
    
}
-(void)backAction1:(UIButton *)sender{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    UIView *subView = [scrollView viewWithTag:22];
    
    return subView;
    
}




- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    
    
    
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

@end
