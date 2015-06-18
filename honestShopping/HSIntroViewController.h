//
//  HSIntroViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
/// 引导页结束
typedef void(^kIntroViewFinishedBlock)(void);


@interface HSIntroViewController : UIViewController

@property (copy, nonatomic) kIntroViewFinishedBlock introViewFinishedBlock;

@end
