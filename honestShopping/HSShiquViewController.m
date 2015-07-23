//
//  HSShiquViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSShiquViewController.h"
#import "MJRefresh.h"

@interface HSShiquViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSURL *lastURL;

@end

@implementation HSShiquViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"食趣";
    [self initWebView];
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
        [wself.webView loadRequest:[wself loadREquest]];
    }];
    [self.webView.scrollView.header beginRefreshing];
}

- (NSURLRequest *)loadREquest
{
    NSURL *url = _webView.request.URL != nil ? _webView.request.URL : [NSURL URLWithString:kShiquURL];
    _lastURL = url;
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
    [_webView loadRequest:[self loadREquest]];
}

#pragma mark - webview delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[self showReqeustFailedMsg];
    [_webView.scrollView.header endRefreshing];
    if ([_lastURL isEqual:_webView.request.URL]) {
       [self showHudWithText:@"刷新失败"];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    //[self hiddenMsg];
    [_webView.scrollView.header endRefreshing];
    
    if ([_lastURL isEqual:_webView.request.URL]) {
        [self showHudWithText:@"刷新成功"];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[self showNetLoadingView];
}

@end
