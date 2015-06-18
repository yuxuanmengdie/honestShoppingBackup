//
//  HSRotateAnimationView.h
//  honestShopping
//
//  Created by 张国俗 on 15-4-29.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSRotateAnimationView : UIView

@property(nonatomic,strong) UIImage* image;
@property(nonatomic) BOOL showRotateImage;

- (void)startRotating;
- (void)stopRotating;

@end
