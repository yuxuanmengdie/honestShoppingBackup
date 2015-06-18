//
//  HSBaseViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-4-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kImageURLKey @"imageURLKey"

#define kImageSizeKey  @"imageSizeKey"


@interface HSBaseViewController : UIViewController

/// 保存图片size的数组
@property (strong, nonatomic) NSMutableDictionary *imageSizeDic;

/// 请求的manger
@property (strong, nonatomic) AFHTTPRequestOperationManager *httpRequestOperationManager;
/// 是否在请求中
@property (assign, nonatomic, readonly) BOOL isRequestLoading;

/// 导航栏rightitem
- (void)setNavBarRightBarWithTitle:(NSString *)rightTitle action:(SEL)seletor;

/// 默认文字显示加载失败
- (void)showReqeustFailedMsg;

/// 定义加载失败的文字
- (void)showReqeustFailedMsgWithText:(NSString *)text;

/// 隐藏并从父视图移除等待视图
- (void)hiddenMsg;

/// 点击重新加载后的响应  子类可重写
- (void)reloadRequestData;

/// 显示等待视图
- (void)showNetLoadingView;

/// hud 2秒后隐藏
- (void)showHudWithText:(NSString *)text;

/// hud 等待视图
- (void)showhudLoadingWithText:(NSString *)text isDimBackground:(BOOL)isDim;

/// hud 显示在window上
- (void)showhudLoadingInWindowWithText:(NSString *)text isDimBackground:(BOOL)isDim;

/// 在window层 hud 2秒后hidden
- (void)showHudInWindowWithText:(NSString *)text;

/// 隐藏并移除 hud 等待视图
- (void)hiddenHudLoading;

/// 返回按钮的响应
- (void)backAction:(id)sender;

/// 占位视图 当界面内容为空时
- (void)placeViewWithImgName:(NSString *)imgName text:(NSString *)text;

/// 移除占位视图
- (void)removePlaceView;

/// push stroyborad viewcontroller identifier 为类名
- (void)pushViewControllerWithIdentifer:(NSString *)identifier;

/// 返回imagesize的key
- (NSString *)keyFromIndex:(NSIndexPath *)index;

/// 商品item的完整路径
- (NSString *)commodityIntroImgFullUrl:(NSString *)oriUrl;

/// pop到顶层的navigation
- (void)popToRootNav;

@end
