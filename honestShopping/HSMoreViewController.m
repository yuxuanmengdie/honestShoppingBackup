//
//  HSMoreViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-3.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMoreViewController.h"

@interface HSMoreViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@end

@implementation HSMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationController.navigationBarHidden = YES;
    [self setTitle:@"更多"];
    
    [_mainImageView setImage:[UIImage imageNamed:@"icon_more.jpg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 
#pragma mark

@end
