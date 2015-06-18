//
//  HSTabBarView.h
//  testFrame
//
//  Created by 张国俗 on 15-5-13.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ HSTabBarActionBlock)(int idx);

@interface HSTabBarView : UIView

@property (copy, nonatomic) HSTabBarActionBlock actionBlock;

@end
