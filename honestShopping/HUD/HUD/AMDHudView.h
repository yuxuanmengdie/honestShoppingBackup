//
//  AMDHudView.h
//  EnAimodi
//
//  Created by Wang-xing on 14-3-24.
//  Copyright (c) 2014年 fuzhou Aimodi Technology Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMDHudView : UIView


+(AMDHudView *) shareView;
-(void) dismissHUDviewWithTitle:(NSString *)title andStates:(NSString *)state;
-(void) dismissWithFail:(NSString *)titles andStates:(NSString *)failmessage;
@end
