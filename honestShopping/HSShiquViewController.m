//
//  HSShiquViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSShiquViewController.h"
#import "MJRefresh.h"
#import "HSUserInfoModel.h"

@interface HSShiquViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSURL *lastURL;

@end

@implementation HSShiquViewController

static NSString *const kShiquDiscussURL = @"http://ecommerce.news.cn/index.php?g=home&m=Cxggs&a=pllist&wzid=144&username=";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"食趣";
    [self initWebView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_lastURL != nil && [_lastURL.absoluteString containsString:kShiquURL]) { // 在食趣的主页时，每次出现刷新
        NSLog(@"qq");
        [self.webView.scrollView.header beginRefreshing];
    }
}

- (void)initWebView
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    id topGuide = self.topLayoutGuide;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView,topGuide)]];
    
//    [_webView loadRequest:[self loadREquest]];
    __weak typeof(self) wself = self;
    // 添加下拉刷新控件
    [self.webView.scrollView addLegendHeaderWithRefreshingBlock:^{
        [wself.webView loadRequest:[wself loadRequest]];
    }];
    [self.webView.scrollView.header beginRefreshing];
}

- (NSURLRequest *)loadRequest
{
    NSURL *url = (_webView.request.URL != nil && ![_webView.request.URL.absoluteString containsString:kShiquURL]) ? _webView.request.URL : [NSURL URLWithString:[self fullURL]];
   // _lastURL = url;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return request;
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

- (void)reloadRequestData
{
    [_webView loadRequest:[self loadRequest]];
}

#pragma mark - webview delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_webView.scrollView.header endRefreshing];
    if ([_lastURL isEqual:_webView.request.URL]) {
       [self showHudWithText:@"刷新失败"];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [_webView.scrollView.header endRefreshing];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"url=%@",webView.request.URL.absoluteString);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"!!!%@",request.URL);
    _lastURL = request.URL;
    if ([request.URL.absoluteString hasPrefix:kShiquDiscussURL] && ![request.URL.absoluteString isEqualToString:[self fullURLWithOri:kShiquDiscussURL]]) {
        
        NSURL *url = [NSURL URLWithString:[self fullURLWithOri:kShiquDiscussURL]];
//        request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        return  NO;
    }
    
    return YES;
}

#pragma mark -
- (NSString *)fullURL
{
    NSString *result = kShiquURL;
    
    if ([HSPublic isLoginInStatus]) {
        
        result = [NSString stringWithFormat:@"%@%@",kShiquURL,[HSPublic controlNullString:[self getLastetUserInfoModel].username]];
    }
    
    return result;
}

- (NSString *)fullURLWithOri:(NSString *)ori
{
    if (ori.length == 0) {
        return nil;
    }
    
    NSString *result = ori;
    
    if ([HSPublic isLoginInStatus]) {
        
        result = [NSString stringWithFormat:@"%@%@",ori,[HSPublic controlNullString:[self getLastetUserInfoModel].username]];
    }
    
    return result;

}

- (HSUserInfoModel *)getLastetUserInfoModel
{
    HSUserInfoModel *userInfo = nil;
    
    if ([HSPublic isLoginInStatus]) {
        NSDictionary *dic = [HSPublic userInfoFromPlist];
        userInfo = [[HSUserInfoModel alloc] initWithDictionary:dic error:nil];
    }
    
    return userInfo;
}


@end
