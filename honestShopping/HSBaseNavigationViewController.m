//
//  HSBaseNavigationViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-4-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseNavigationViewController.h"

@interface HSBaseNavigationViewController ()

@end

@implementation HSBaseNavigationViewController


// 判断是否为iOS7
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


#pragma mark 一个类只会调用一次
+ (void)initialize
{
    // 1.取出设置主题的对象
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:[HSBaseNavigationViewController class], nil];
    
    if (iOS7) { // iOS7
       
       
    } else { // 非iOS7
      
    }
//    navBar.translucent = NO;
    navBar.tintColor = [UIColor whiteColor];
    [navBar setBarTintColor:kAPPTintColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    //navBar.translucent = NO;  // 在iOS 7 上会崩溃！！！！！！！
    
    
    // 3.标题
#ifdef __IPHONE_7_0
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont boldSystemFontOfSize:18]}];
#else
    [navBar setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor]}];
#endif
}

#pragma mark 控制状态栏的样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
