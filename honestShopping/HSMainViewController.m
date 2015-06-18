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
//    self.navigationController.navigationBarHidden = YES;
//    self.title = @"放心吃";
    self.tabBar.selectedImageTintColor =  kAPPTintColor;
    self.tabBar.translucent = NO;
//    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightNavItemAction)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    
//    /// 获取版本号 判断是否需要引导页
//    NSString *verson = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    
//    NSString *saveedVerson = [[NSUserDefaults standardUserDefaults] objectForKey:kAPPCurrentVersion];
//    
//    if (saveedVerson == nil || ![verson isEqualToString:saveedVerson]) {
//        [self showIntroView];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:verson forKey:kAPPCurrentVersion];
//    }
    
    [self tabBarViewInit];
    
//    [self getGuideRequest];
//    [self getWelcomeRequest];
    
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


#pragma mark -
#pragma mark 引导图
- (void)getGuideRequest
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]]};
    // 142346261  123456
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:kGetGuideURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        if (operation.responseData == nil) {
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSArray class]]) {
            NSArray *jsonArr = (NSArray *)json;
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                HSBannerModel *bannerModel = [[HSBannerModel alloc] initWithDictionary:obj error:nil];
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,[HSPublic controlNullString:bannerModel.content]]];
                BOOL isCache = [[SDWebImageManager sharedManager] cachedImageExistsForURL:url];
                if (!isCache) {
                    [self downloadImageWihtURL:url];
                }
                
            }];
        }
        else
        {
            
        }

        }];

}

#pragma mark -
#pragma mark 欢迎图
- (void)getWelcomeRequest
{
    
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]]};
    // 142346261  123456
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:kGetWelcomeURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
       
        if (operation.responseData == nil) {
                        return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSArray class]]) {
            NSArray *jsonArr = (NSArray *)json;
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                HSBannerModel *bannerModel = [[HSBannerModel alloc] initWithDictionary:obj error:nil];
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,[HSPublic controlNullString:bannerModel.content]]];
                BOOL isCache = [[SDWebImageManager sharedManager] cachedImageExistsForURL:url];
                if (!isCache) {
                    [self downloadImageWihtURL:url];
                }
                
            }];
        }
        else
        {
            
        }
    }];

}

#pragma mark-
#pragma mark 图片下载
- (void)downloadImageWihtURL:(NSURL *)url
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        if (error != nil) { /// 下载失败
            [self downloadImageWihtURL:url];
        }
    }];

}

@end
