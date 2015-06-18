//
//  HSRegisterContainterTableViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-1.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSRegisterContainterTableViewController.h"
#import "UIView+HSLayout.h"

@interface HSRegisterContainterTableViewController ()<UITextFieldDelegate>

@end

@implementation HSRegisterContainterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self p_textFieldStlye:_phoneTextFiled];
    [self p_textFieldStlye:_verifyTextFiled];
    [self p_textFieldStlye:_passwordTextField];
    [self p_textFieldStlye:_confirmPWTextField];
    
    [_getCaptchasButton setTitleColor:kAPPTintColor forState:UIControlStateNormal];
     [_getCaptchasButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getCaptchasButton addTarget:self action:@selector(captchAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self footerView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self footerView];
    
}

#pragma mark - 
#pragma mark 设置的textfiled颜色 delegate
///
- (void)p_textFieldStlye:(UITextField *)textField
{
    textField.delegate = self;
    textField.tintColor = kAPPTintColor;
}

- (void)footerView
{
    UIView *footerView = [[UIView alloc] init];
    CGRect rect = self.tableView.bounds;
    rect.size.height = 100;
    footerView.frame = rect;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmButton = button;
    button.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16);
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5.0;
    [button addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];
    [footerView HS_centerXYWithSubView:button];
    [footerView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:16]];
    
    self.tableView.tableFooterView = footerView;

}

- (void)confirmAction
{
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}


- (void)captchAction
{
     
    if (self.CaptchasBlcok) {
        self.CaptchasBlcok();
    }
}
#pragma mark -
#pragma mark textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
