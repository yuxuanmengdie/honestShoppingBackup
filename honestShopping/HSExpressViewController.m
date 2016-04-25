//
//  HSExpressViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-11-21.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSExpressViewController.h"
#import "HSExpressTableViewCell.h"

@interface HSExpressViewController (){
    UIWebView *_webView;
    
    HSExpressTableViewCell *_holderCell;
}

@end

@implementation HSExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self webViewInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewInit {
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    //_webView.delegate = self;
    [self.view addSubview:_webView];
    
    id topGuide = self.topLayoutGuide;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView,topGuide)]];
    NSURL *url = [NSURL URLWithString:@"http://m.kuaidi100.com/index_all.html?type=quanfengkuaidi&postid=123456"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

#pragma mark - tableview dataSource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
