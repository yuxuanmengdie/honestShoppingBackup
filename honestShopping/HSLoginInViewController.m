//
//  HSLoginInViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-4-29.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSLoginInViewController.h"
#import "UIView+HSLayout.h"
#import "HSUserInfoModel.h"
#import "HSRegisterViewController.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialSnsPlatformManager.h"
#import "UMSocialAccountManager.h"
#import "UMSocial.h"

@interface HSLoginInViewController ()<UITextFieldDelegate>
{
    HSUserInfoModel *_userInfoModel;
    
    HSRegisterViewController *_registerViewController;
}

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIView *textFieldBackView;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passWordTextFiled;

@property (weak, nonatomic) IBOutlet UIButton *remeberPWButton;

@property (weak, nonatomic) IBOutlet UIButton *findPWButton;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end

@implementation HSLoginInViewController

///用户textfield表示图片
static NSString *const kUserImageName = @"icon_userName";
/// 密码表示图片
static NSString *const kPassWordImageName = @"icon_findPW";
/// 记住密码选中图片
static NSString *const kRemeberPWSeletedImageName = @"icon_remeberPW";
///
static NSString *const kRemeberPWNormalImageName = @"icon_remeberPW_unsel";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"登录";
    [self setNavBarRightBarWithTitle:@"注册" action:@selector(accoutRegister)];
    self.navigationController.navigationBarHidden = NO;
    [self buttonStyle];
    _iconImageView.image = [UIImage imageNamed:@"icon_logo"];
    [self leftViewWithTextFiled:_userNameTextField imgName:kUserImageName];
    [self leftViewWithTextFiled:_passWordTextFiled imgName:kPassWordImageName];
    
    if ([HSPublic loginType] == kAccountLoginType) { /// 帐号登录
        _userNameTextField.text = [HSPublic controlNullString:[HSPublic lastUserName]];
        
        if ([HSPublic isRemeberPassword]) {
            _passWordTextFiled.text = [HSPublic controlNullString:[HSPublic lastPassword]];
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *result = [userDefaults objectForKey:kRemeberPassword];
    if (result == nil) {
        [HSPublic setRemeberPassword:YES];
    }
    else
    {
        _remeberPWButton.selected = [HSPublic isRemeberPassword];
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark 注册
- (void)accoutRegister
{
    [self SetUpregisterVC];
    _registerViewController.title = @"注册";
    _registerViewController.isRegister = YES;
}

- (void)SetUpregisterVC
{
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _registerViewController = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSRegisterViewController class])];
    [self.navigationController pushViewController:_registerViewController animated:YES];
    
    __weak typeof(self) wself = self;
    _registerViewController.registerSuccessBlock = ^(NSString *userName, NSString *password){
        [wself loginRequest:userName password:password];
    };
    

}

#pragma mark -
#pragma mark textfiled 属性 样式
- (void)leftViewWithTextFiled:(UITextField *)textField imgName:(NSString *)imgName
{
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    [img sizeToFit];
    UIView *tmpView = [[UIView alloc] init];
    tmpView.backgroundColor = [UIColor clearColor];
    [tmpView addSubview:img];
    img.frame = CGRectMake(8, 0, img.image.size.width, img.image.size.height);
    tmpView.frame = CGRectMake(0, 0, img.image.size.width+8, img.image.size.height);
    tmpView.bounds = CGRectMake(0, 0, img.image.size.width+8, img.image.size.height);
    textField.leftView = tmpView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = kAPPTintColor.CGColor;
    textField.tintColor = kAPPTintColor;
    textField.layer.cornerRadius = 8.0;
    textField.layer.borderWidth = 1.0;
    textField.delegate = self;
    
}

- (void)buttonStyle
{
    [_remeberPWButton setTitle:@"记住密码" forState:UIControlStateNormal];
    [_remeberPWButton setBackgroundColor:[UIColor clearColor]];
    [_remeberPWButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_remeberPWButton setImage:[UIImage imageNamed:kRemeberPWNormalImageName] forState:UIControlStateNormal];
    [_remeberPWButton setImage:[UIImage imageNamed:kRemeberPWSeletedImageName] forState:UIControlStateSelected];
    _remeberPWButton.selected = YES;
    
    [_findPWButton setTitle:@"找回密码" forState:UIControlStateNormal];
    [_findPWButton setBackgroundColor:[UIColor clearColor]];
    [_findPWButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_findPWButton setImage:[UIImage imageNamed:kPassWordImageName] forState:UIControlStateNormal];
    
    [_commitButton setTitle:@"登录" forState:UIControlStateNormal];
    [_commitButton setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    _commitButton.layer.masksToBounds = YES;
    _commitButton.layer.cornerRadius = 5.0;
    [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _commitButton.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16);
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -
#pragma mark 按钮响应

- (IBAction)remeberPWAction:(id)sender {
    _remeberPWButton.selected = !_remeberPWButton.selected;
    [HSPublic setRemeberPassword:_remeberPWButton.isSelected];
}

- (IBAction)findPWAction:(id)sender {
    [self SetUpregisterVC];
    _registerViewController.title = @"找回密码";
    _registerViewController.isRegister = NO;
}

- (IBAction)commitAction:(id)sender {
    
    if (_userNameTextField.text.length < 1 || _passWordTextFiled.text.length < 1) {
        [self showHudWithText:@"用户名或密码不能为空"];
        return;
    }
    
//    [self weixinLogin];
//    [self qqLogin];
    [self loginRequest:_userNameTextField.text password:_passWordTextFiled.text];
}

#pragma mark -
#pragma mark 登录请求
- (void)loginRequest:(NSString *)userName password:(NSString *)passWord
{
    [self showhudLoadingWithText:@"正在登录..." isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUserName:userName,
                                    kPostJsonPassWord:passWord
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kLoginURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        [self showHudWithText:@"登录失败"];
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"登录失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            
            _userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:json error:nil];
            if (_userInfoModel.id.length > 0) { /// 登录后返回有数据
                [self showHudInWindowWithText:@"登录成功"];
                [HSPublic saveUserInfoToPlist:[_userInfoModel toDictionary]];
                [HSPublic setLoginInStatus:YES type:kAccountLoginType];
                
                [HSPublic saveLastUserName:userName];
                [HSPublic saveLastPassword:passWord];
                if (_remeberPWButton.selected) {
                    
                }
                [self backAction:nil];
            }
        }
        else
        {
            [self showHudWithText:@"登录失败"];
        }
    }];
}

- (void)backAction:(id)sender
{
    [super backAction:sender];
//    self.navigationController.navigationBarHidden = YES;
}


#pragma mark -
#pragma mark textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -

- (IBAction)weixinLoginAction:(id)sender {
    [self weixinLogin];
}

- (IBAction)qqLoginAction:(id)sender {
    [self qqLogin];
}

#pragma mark -
#pragma mark 微信登录
- (void)weixinLogin
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            
            NSLog(@"username is %@, uid is %@, token is %@ url is %@ , ",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            [self loginInWithOtherID:[HSPublic controlNullString:snsAccount.openId] type:kWenxiLoginType userName:snsAccount.userName headerImgURL:snsAccount.iconURL];
            
        }
        
    });
    
    //得到的数据在回调Block对象形参respone的data属性
    [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
        NSLog(@"SnsInformation is %@",response.data);
    }];
}

#pragma mark -
#pragma mark 新浪登录
- (void)sinaLogin
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
            
           
            
        }});
    
    //获取accestoken以及新浪用户信息，得到的数据在回调Block对象形参respone的data属性
    [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina  completion:^(UMSocialResponseEntity *response){
        NSLog(@"SnsInformation is %@",response.data);
    }];
}

#pragma mark -
#pragma mark qq登录
- (void)qqLogin
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
             [self loginInWithOtherID:[HSPublic controlNullString:snsAccount.openId] type:kQQLoginType userName:snsAccount.userName headerImgURL:snsAccount.iconURL];
            
        }});
    
    //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
    [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
        NSLog(@"SnsInformation is %@",response.data);
    }];
    
}

#pragma mark -
#pragma mark 根据第三方的ID 注册
- (void)loginInWithOtherID:(NSString *)openID type:(HSLoginType)loginType userName:(NSString *)userName headerImgURL:(NSString *)imgURL
{
    [self showhudLoadingWithText:@"正在登录..." isDimBackground:YES];
    
    // 142346261  123456
    
    NSString *logintypeStr = nil;
    if (loginType == kWenxiLoginType) {
        logintypeStr = kOtherLoginWeixinType;
    }
    else
    {
        logintypeStr = kOtherLoginQQType;
    }
    
    NSDictionary *parametersDic = @{kPostJsonOpenid:openID,
                                    kPostJsonType:logintypeStr};
    [self.httpRequestOperationManager POST:kOtherLoginURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        [self showHudWithText:@"登录失败"];
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"登录失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            
            _userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:json error:nil];
            if (_userInfoModel.id.length > 0) { /// 登录后返回有数据
                [self showHudInWindowWithText:@"登录成功"];
                [HSPublic saveUserInfoToPlist:[_userInfoModel toDictionary]];
                [HSPublic setLoginInStatus:YES type:loginType];
                [HSPublic saveOtherOpenID:openID];
                [HSPublic saveLastOtherUserName:userName];
                [HSPublic savelastOtherHeaderImgURL:imgURL];
                if (_remeberPWButton.selected) {
                    
                }
                [self backAction:nil];
            }
        }
        else
        {
            [self showHudWithText:@"登录失败"];
        }
    }];

}




@end
