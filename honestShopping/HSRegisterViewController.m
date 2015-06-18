//
//  HSRegisterViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-4-30.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSRegisterViewController.h"
#import "HSRegisterContainterTableViewController.h"

@interface HSRegisterViewController ()<UITextFieldDelegate>
{
    HSRegisterContainterTableViewController *_containterTableVC;
}

@end

@implementation HSRegisterViewController

///用户textfield表示图片
static NSString *const kUserImageName = @"icon_activity";
/// 验证码重新获取时间
static const int kMaxLoadingTimeout = 60;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"regidterEmbed"]) {
        
        _containterTableVC = [segue destinationViewController];
        [_containterTableVC.confirmButton setTitle:self.title forState:UIControlStateNormal];
        
        __weak typeof(self) wself = self;
        
        _containterTableVC.CaptchasBlcok = ^{
            __strong typeof(wself) swself = wself;
            
            NSString *errorTip = nil;
            if (swself->_containterTableVC.phoneTextFiled.text.length < 1) { ///手机号码 为空
                errorTip = @"手机号码不能为空";
                [swself showHudWithText:errorTip];
                return ;
            }
            
            if (![HSPublic isPhoneNumberRegex:swself->_containterTableVC.phoneTextFiled.text]) { /// 手机号码不合法
                errorTip = @"输入正确的手机号码";
                [swself showHudWithText:errorTip];
                return;
            }

            __block int timeout = kMaxLoadingTimeout; //倒计时时间
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                if(timeout<=0){ //倒计时结束，关闭
                    dispatch_source_cancel(_timer);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //设置界面的按钮显示 根据自己需求设置
                        [swself->_containterTableVC.getCaptchasButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                        swself->_containterTableVC.getCaptchasButton.enabled = YES;
                    });
                }else{
                    int seconds = timeout % (timeout + 1);
                    NSString *strTime = [NSString stringWithFormat:@"%.2d秒后重新获取",seconds];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //设置界面的按钮显示 根据自己需求设置
                        [swself->_containterTableVC.getCaptchasButton setTitle:strTime forState:UIControlStateNormal];
                    });
                    timeout--;
                    
                }  
            });  
            dispatch_resume(_timer);
            
            swself->_containterTableVC.getCaptchasButton.enabled = NO;
            [swself sendCaptchas:swself->_containterTableVC.phoneTextFiled.text];

        };
        
        _containterTableVC.confirmBlock = ^{
            
            __strong typeof(wself) swself = wself;
            
            NSString *errorTip = nil;
            /// 判断条件是否都满足
            if (swself->_containterTableVC.phoneTextFiled.text.length < 1) { ///手机号码 为空
                errorTip = @"手机号码不能为空";
                [swself showHudWithText:errorTip];
                return ;
            }
            
            if (![HSPublic isPhoneNumberRegex:swself->_containterTableVC.phoneTextFiled.text]) { /// 手机号码不合法
                errorTip = @"输入正确的手机号码";
                [swself showHudWithText:errorTip];
                return;
            }
            
            if (swself->_containterTableVC.verifyTextFiled.text.length < 1) { /// 验证码为空
                errorTip = @"验证码不能为空";
                [swself showHudWithText:errorTip];
                return;

            }
            
            if (swself->_containterTableVC.passwordTextField.text.length < 1 || swself->_containterTableVC.confirmPWTextField.text.length < 1) {
                errorTip = @"密码不能为空";
                [swself showHudWithText:errorTip];
                return;

            }
            
            if (![swself->_containterTableVC.passwordTextField.text isEqualToString:swself->_containterTableVC.confirmPWTextField.text]) {
                errorTip = @"密码不一致";
                [swself showHudWithText:errorTip];
                return;
            }
            
            /// 验证验证码
            [swself vefiryCodeWithPhone:swself->_containterTableVC.phoneTextFiled.text code:swself->_containterTableVC.verifyTextFiled.text];
        
        };
    }
}


- (IBAction)commitAction:(id)sender {
    
}

#pragma mark -
#pragma mark 注册
- (void)registerRequest:(NSString *)phone password:(NSString *)passWord
{
    [self showhudLoadingWithText:nil isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonPhone:phone,
                                    kPostJsonUserName:phone,
                                    kPostJsonPassWord:passWord
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kRegisterURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        [self showHudWithText:@"注册失败"];
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"注册失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)json;
            BOOL isSuccess = [tmpDic[@"status"] boolValue];
            if (isSuccess) {
                [self showHudInWindowWithText:@"注册成功"];
                [self.navigationController popViewControllerAnimated:YES];
                if (self.registerSuccessBlock) {
                    self.registerSuccessBlock(phone,passWord);
                }
            }
            else
            {
                [self showHudWithText:@"注册失败"];
            }

        }
        else
        {
            [self showHudWithText:@"注册失败"];
        }
    }];

}

#pragma mark -
#pragma mark 找回密码
- (void)FindPWRequest:(NSString *)phone password:(NSString *)passWord
{
    [self showhudLoadingWithText:nil isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonPhone:phone,
                                    kPostJsonUserName:phone,
                                    kPostJsonPassWord:passWord
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kSetPasswordURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        [self showHudWithText:@"设置失败"];
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"设置失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)json;
            BOOL isSuccess = [tmpDic[@"status"] boolValue];
            if (isSuccess) {
                [self showHudInWindowWithText:@"设置成功"];
                [self.navigationController popViewControllerAnimated:YES];
                if (self.registerSuccessBlock) {
                    self.registerSuccessBlock(phone,passWord);
                }
            }
            else
            {
                [self showHudWithText:@"设置失败"];
            }
            
        }
        else
        {
            [self showHudWithText:@"设置失败"];
        }
    }];
    
}



#pragma mark -
#pragma mark textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark  发送验证码
- (void)sendCaptchas:(NSString *)phone
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonPhone:phone
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kGetVerifyCodeURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        [self showHudWithText:@"发送失败"];
        NSLog(@"success\n%@",operation.responseString);
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"发送失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *tmpDic = (NSDictionary *)json;
            BOOL isSuccess = [tmpDic[@"status"] boolValue];
            if (isSuccess) {
                [self showHudWithText:@"发送成功"];
            }
            else
            {
                [self showHudWithText:@"发送失败"];
            }
        }
        else
        {
            [self showHudWithText:@"发送失败"];
        }
    }];
    

}


#pragma mark -
#pragma mark  验证验证码
- (void)vefiryCodeWithPhone:(NSString *)phone code:(NSString *)code
{
    
    [self showhudLoadingWithText:nil isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonPhone:phone,
                                    kPostJsonCode:code
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kVerifyCodeURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        [self showHudWithText:@"验证失败"];
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"验证失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *tmpDic = (NSDictionary *)json;
            BOOL isSuccess = [tmpDic[@"status"] boolValue];
            if (isSuccess) {
                [self showHudWithText:@"验证成功"];
                if (_isRegister) {
                    [self registerRequest:_containterTableVC.phoneTextFiled.text password:_containterTableVC.passwordTextField.text];
                }
                else
                {
                    [self FindPWRequest:_containterTableVC.phoneTextFiled.text password:_containterTableVC.passwordTextField.text];
                }
                
            }
            else
            {
                [self showHudWithText:@"验证码错误"];
            }
        }
        else
        {
            [self showHudWithText:@"验证失败"];
        }
    }];

    
}
@end
