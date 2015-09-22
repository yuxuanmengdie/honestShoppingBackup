//
//  HSMainViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-16.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMainViewController.h"
#import "define.h"
#import "HSIntroViewController.h"
#import "HSLoginInViewController.h"
#import "HSTabBarView.h"
#import "UIView+HSLayout.h"
#import "HSBannerModel.h"

#import "UIImageView+WebCache.h"

@interface HSMainViewController ()
{
    HSIntroViewController *_introVC;
}

@end

@implementation HSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tabBar.selectedImageTintColor =  kAPPTintColor;
    self.tabBar.translucent = NO;
    [self tabBarViewInit];
    
}

- (void)showIntroView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _introVC = [storyboard instantiateViewControllerWithIdentifier:@"introViewCOntrollerIndentifier"];
    
    [self.navigationController.view addSubview:_introVC.view];
    _introVC.view.bounds = self.navigationController.view.bounds;
    [self.view bringSubviewToFront:_introVC.view];
    
    __weak typeof(_introVC) wIntroVC = _introVC;
    [_introVC setIntroViewFinishedBlock:^{
        
        __strong typeof(wIntroVC) swIntroVC = wIntroVC;
        [wIntroVC.view removeFromSuperview];
        swIntroVC = nil;
    }];

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


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

//    UITabBarItem *tabBarItem1 = [self.tabBar.items objectAtIndex:2];
//    if (item == tabBarItem1) {
//        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        HSLoginInViewController *loginVC = [story instantiateViewControllerWithIdentifier:NSStringFromClass([HSLoginInViewController class])];
//        [self.navigationController pushViewController:loginVC animated:YES];
//        return;
//    }
}


#pragma mark -
#pragma mark 自定义tabbarView 代替tabbar
- (void)tabBarViewInit
{
    HSTabBarView *tabView = [[HSTabBarView alloc] initWithFrame:CGRectZero];
    tabView.backgroundColor = [UIColor clearColor];
    tabView.translatesAutoresizingMaskIntoConstraints = NO;
    tabView.tag = kTabBarViewTag;
    UIView *pView = self.view;
    [pView addSubview:tabView];
    //self.tabBar.hidden = YES;
    
    [self.view HS_dispacingWithFisrtView:pView fistatt:NSLayoutAttributeLeading secondView:tabView secondAtt:NSLayoutAttributeLeading constant:0 ];
    [self.view HS_dispacingWithFisrtView:pView fistatt:NSLayoutAttributeBottom secondView:tabView secondAtt:NSLayoutAttributeBottom constant:0 ];
    [self.view HS_dispacingWithFisrtView:pView fistatt:NSLayoutAttributeTrailing secondView:tabView secondAtt:NSLayoutAttributeTrailing constant:0 ];
    
    __weak typeof(self) wself = self;
    tabView.actionBlock = ^(int idx){
        __strong typeof(wself) swself = wself;
        
        [swself setSelectedIndex:idx];
    };
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBar setHidden:NO];
}

@end
