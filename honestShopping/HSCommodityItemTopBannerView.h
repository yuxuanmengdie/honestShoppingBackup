//
//  HSCommodityItemTopBannerView.h
//  honestShopping
//
//  Created by 张国俗 on 15-4-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFScrollView.h"
#import "HSItemBuyInfoView.h"


typedef void(^HSCommodityItemTopBannerViewHeightChangeBlcok)(void);
/// 商品详情的顶部视图
@interface HSCommodityItemTopBannerView : UIView

@property (nonatomic, strong) FFScrollView *bannerView;

@property (nonatomic, strong) HSItemBuyInfoView *infoView;

@property (nonatomic, assign) float bannerHeight;

@property (nonatomic, copy) HSCommodityItemTopBannerViewHeightChangeBlcok heightChangeBlcok;

/// 三品一标的图片标志
- (void)sanpinImageTag:(HSSanpinCategoryType)sanpinType;

@end
