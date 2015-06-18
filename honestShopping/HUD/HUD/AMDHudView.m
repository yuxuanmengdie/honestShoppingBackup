//
//  AMDHudView.m
//  EnAimodi
//
//  Created by Wang-xing on 14-3-24.
//  Copyright (c) 2014年 fuzhou Aimodi Technology Co. Ltd. All rights reserved.
//

#import "AMDHudView.h"
#import "MMProgressHUD.h"

@implementation AMDHudView
static AMDHudView *hudView = nil;
+(AMDHudView *) shareView
{
    if (hudView == nil) {
         @synchronized (self)//同步锁
        {
            hudView = [[AMDHudView alloc] init];
            
        }
    }
    return hudView;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeLinear];
        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
//        [MMProgressHUD showWithTitle:L_LanguageStr(EL_tips) status:L_LanguageStr(EL_loading)  images:nil];
    }
    return self;
}
-(void) dismissHUDviewWithTitle:(NSString *)title andStates:(NSString *)state
{
    [MMProgressHUD dismissWithSuccess:state title:title afterDelay:1.0];
    
}
-(void) dismissWithFail:(NSString *)titles andStates:(NSString *)failmessage
{
    [MMProgressHUD dismissWithError:failmessage title:titles afterDelay:2.0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
