//
//  HSIntroViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSIntroViewController.h"
#import "EAIntroView.h"

#import "UIView+HSLayout.h"
#import "UIImageView+WebCache.h"
#import "HSBannerModel.h"
#import "HSMainViewController.h"

@interface HSIntroViewController ()<
EAIntroDelegate>
{
    /// 用启动动画占位
    UIImageView *_placeImageView;
    
    NSArray *_guideImages;
    
    NSArray *_welcomeImages;
    
    /// 引导图 为 1   欢迎图 2
    int _bannerType;
    
    NSTimer *_timer;
}


@property (strong, nonatomic) IBOutlet EAIntroView *introView;

@end

@implementation HSIntroViewController

static NSString *const kIntroViewToMainBar = @"IntroViewToMainTabBar";

/// 启动图片最大持续时间 如果时间到 且 图片没有下载完成，则直接跳过引导图和欢迎图。
static const float kMaxLoadingTime = 5.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _bannerType = 0;
    
    [self initPlaceView];
//    [self showIntroWithSeparatePagesInitAndPageCallback];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    /// 获取版本号 判断是否需要引导页
    NSString *verson = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *saveedVerson = [[NSUserDefaults standardUserDefaults] objectForKey:kAPPCurrentVersion];
    
    if (saveedVerson == nil || ![verson isEqualToString:saveedVerson]) { // 加载引导图
        [self getGuideRequest];
    }
    else // 不加载引导图，就加载欢迎图
    {
        [self getWelcomeRequest];
    }
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kMaxLoadingTime target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - 
#pragma mark 启动图片占位图
- (void)initPlaceView
{
    _placeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_placeImageView];
    _placeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view HS_edgeFillWithSubView:_placeImageView];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGSize size = rect.size;
    
    NSString *imgName = @"icon_launcher_place.jpg";
    if ( CGSizeEqualToSize(size, CGSizeMake(320, 480))) { // 3.5寸
        
    }
    else if ( CGSizeEqualToSize(size, CGSizeMake(320, 568))) // 4寸
    {
        
    }
    else if ( CGSizeEqualToSize(size, CGSizeMake(375, 667))) // iphone 6 4.7寸 375x667
    {
        
    }
    else if ( CGSizeEqualToSize(size, CGSizeMake(414, 736))) // iphone 6 plus 414x736
    {
         
    }
    else
    {
        
    }
    
    [_placeImageView setImage:[UIImage imageNamed:imgName]];
    
}


- (void)showIntroWithSeparatePagesInitAndPageCallback {
    
    
    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"1";
    page1.bgImage = [UIImage imageNamed:@"start_first"];
//    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
//    page1.bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"start_first"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.desc = @"2";
    page2.bgImage = [UIImage imageNamed:@"start_second"];
//    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title2"]];
//    page2.bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"start_second"]];
    page2.onPageDidAppear = ^{
        NSLog(@"Page 2 did appear block");
    };
    
    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"3";
    page3.bgImage = [UIImage imageNamed:@"icon_more.jpg"];// @"start_third"
//    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];
//    page3.bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"start_third"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
//    page4.title = @"This is page 4";
//    page4.desc = @"4";
    page4.bgImage = [UIImage imageNamed:@"start_fourth"];
//    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];
//    page4.bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"start_fourth"]];
    
    _introView = [[EAIntroView alloc] initWithFrame:self.view.bounds];
    [_introView setDelegate:self];
//    [_introView layoutIfNeeded];
    [_introView setSkipButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    _introView.skipButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
    [_introView.skipButton setTitle:@"体验新版" forState:UIControlStateNormal];
    [_introView.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_introView.skipButton setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    _introView.skipButton.layer.masksToBounds = YES;
    _introView.skipButton.layer.cornerRadius = 5.0;
//    CGPoint center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, _introView.pageControlY - 40);
    [_introView.skipButton sizeToFit];
//    _introView.center = center;
     _introView.skipButtonAlignment = EAViewAlignmentCenter;
//    _introView.backgroundColor = [UIColor blueColor];
    
    // show skipButton only on 3rd page + animation
//    _introView.skipButton.alpha = 0.f; // 0.f;
//    _introView.skipButton.enabled = NO; // NO
    _introView.showSkipButtonOnlyOnLastPage = YES;
    _introView.useMotionEffects = NO;
    _introView.backgroundColor = [UIColor whiteColor];
    
//    [_introView.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
//    page4.onPageDidAppear = ^{
//        _introView.skipButton.enabled = YES;
//        [UIView animateWithDuration:0.3f animations:^{
//            _introView.skipButton.alpha = 1.f;
//        }];
//    };
//    page4.onPageDidDisappear = ^{
//        _introView.skipButton.enabled = NO;
//        [UIView animateWithDuration:0.3f animations:^{
//            _introView.skipButton.alpha = 0.f;
//        }];
//    };
    
    
    
    [_introView setPages:@[page1,page2,page3,page4]];
    
    [_introView showInView:self.view animateDuration:0.3];
    _introView.bgViewContentMode = UIViewContentModeScaleToFill;
}

#pragma mark - EAIntroView delegate

- (void)introDidFinish:(EAIntroView *)introView {
    NSLog(@"introDidFinish callback");
//    [self performSegueWithIdentifier:kIntroViewToMainBar sender:self];
//    if (self.introViewFinishedBlock) {
//        self.introViewFinishedBlock();
//    }
    [self presentToMainTabbar];
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark -
#pragma mark 根据banner 数组生成intro page
- (void)introPagesWithBannerArr:(NSArray *)bannerArr;
{
    [_placeImageView removeFromSuperview];
    _placeImageView = nil;
    
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    
    if (bannerArr.count == 0) {
        [self presentToMainTabbar];
        return;
    }

    if (_bannerType == 1) { /// 引导图
         NSString *verson = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [[NSUserDefaults standardUserDefaults] setObject:verson forKey:kAPPCurrentVersion];
    }
    
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:bannerArr.count];
    [bannerArr enumerateObjectsUsingBlock:^(HSBannerModel *obj, NSUInteger idx, BOOL *stop) {
        EAIntroPage *page = [EAIntroPage page];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,[HSPublic controlNullString:obj.content]]];
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
        page.bgImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        [tmp addObject:page];

    }];
    
    _introView = [[EAIntroView alloc] initWithFrame:self.view.bounds];
    
    [_introView setDelegate:self];
    //    [_introView layoutIfNeeded];
    [_introView setSkipButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    _introView.skipButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
    [_introView.skipButton setTitle:@"体验新版" forState:UIControlStateNormal];
    [_introView.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_introView.skipButton setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    _introView.skipButton.layer.masksToBounds = YES;
    _introView.skipButton.layer.cornerRadius = 5.0;
    [_introView.skipButton sizeToFit];
    _introView.skipButtonY = (CGRectGetHeight(self.view.bounds)-CGRectGetHeight(_introView.skipButton.frame)) / 2.0;
    _introView.skipButtonAlignment = EAViewAlignmentCenter;
    _introView.showSkipButtonOnlyOnLastPage = YES;
    _introView.swipeToExit = NO;
    
    _introView.useMotionEffects = NO;
    _introView.backgroundColor = [UIColor whiteColor];
    //_introView.bgImage = [UIImage imageNamed:@"icon_header"];
    
    if (_bannerType == 2) {
        _introView.swipeToExit = YES;
        _introView.skipButton.hidden = YES;
    }

    [_introView setPages:tmp];
    [_introView showInView:self.view animateDuration:0.3];
    _introView.bgViewContentMode = UIViewContentModeScaleToFill;
    
    if (_bannerType == 2) {
        //_introView.scrollingEnabled = NO;
        _introView.tapToNext = YES;
        _introView.skipButton.hidden = YES;
        //_introView.swipeToExit = NO;
        [self welcomeAutoGo:_introView];
    }

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
            _bannerType = 1;
            NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                HSBannerModel *bannerModel = [[HSBannerModel alloc] initWithDictionary:obj error:nil];
                [temp addObject:bannerModel];
            }];
            
            _guideImages = temp;
            [self downloadImageInArr:temp];
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
            _bannerType = 2;
            NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                HSBannerModel *bannerModel = [[HSBannerModel alloc] initWithDictionary:obj error:nil];
                [temp addObject:bannerModel];
                
            }];
            [self downloadImageInArr:temp];
        }
        else
        {
            
        }
    }];
    
}

#pragma mark-
#pragma mark 图片下载
- (void)downloadImageInArr:(NSArray *)bannerArr
{
    if ([self isCacheFinished:bannerArr]) {
        [self introPagesWithBannerArr:bannerArr];
        return;
    }
    
    [bannerArr enumerateObjectsUsingBlock:^(HSBannerModel *obj, NSUInteger idx, BOOL *stop) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,[HSPublic controlNullString:obj.content]]];
        BOOL isCache = [[SDWebImageManager sharedManager] cachedImageExistsForURL:url];
        if (!isCache) {
            [self downloadImageWihtURL:url arr:bannerArr];
        }
        
    }];

}

- (void)downloadImageWihtURL:(NSURL *)url arr:(NSArray *)arr
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        if (error != nil) { /// 下载失败
            [self downloadImageWihtURL:url arr:arr];
        }
        
        if ([self isCacheFinished:arr]) { //缓存完成
            
            if ([_timer isValid]) {
                [_timer invalidate];
                _timer = nil;
                
                [self introPagesWithBannerArr:arr];
            }
            else
            {
                 //[self introPagesWithBannerArr:arr];
            }
           
        }
    }];
    
}

#pragma mark -
#pragma mark 是否全部cache完成
- (BOOL)isCacheFinished:(NSArray *)bannerArr
{
    __block BOOL isSuc = YES;
    
    [bannerArr enumerateObjectsUsingBlock:^(HSBannerModel *obj, NSUInteger idx, BOOL *stop) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,[HSPublic controlNullString:obj.content]]];
        BOOL isCache = [[SDWebImageManager sharedManager] cachedImageExistsForURL:url];
        if (!isCache) {
            isSuc = NO;
            *stop = YES;
        }
    }];
    
    return isSuc;
}


#pragma mark -
#pragma mark 移到首页
- (void)presentToMainTabbar
{
    if (self.presentedViewController != nil) { /// 已经presented
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([HSMainViewController class])];
//    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    __weak typeof(self) wself = self;
    [self presentViewController:vc animated:YES completion:^{
        __strong typeof(wself) swself = wself;
        if (swself == nil) {
            return ;
        }
        
        for (UIView *subView in swself.view.subviews) {
            [subView removeFromSuperview];
        }
    }];
}

#pragma mark -
#pragma mark 定时器响应
- (void)timerAction
{
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    [self presentToMainTabbar];
    _bannerType = 0;
}

#pragma mark - 
#pragma mark 自动触发欢迎页
- (void)welcomeAutoGo:(EAIntroView *)introView
{
    __block int num = 0;
    //GCD定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC), 3ull*NSEC_PER_SEC, 0ull*NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"wakeup");
        NSUInteger current = introView.currentPageIndex;
        [introView setCurrentPageIndex:current + 1 animated:YES];
        num++;
        if (num >= introView.pages.count || current + 1 >= introView.pages.count) {
             dispatch_source_cancel(timer);
        }
       
    });
    
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"cancel");
        [self presentToMainTabbar];
    });
    //启动
    dispatch_resume(timer);
}

- (void)dealloc
{
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }

}
@end
