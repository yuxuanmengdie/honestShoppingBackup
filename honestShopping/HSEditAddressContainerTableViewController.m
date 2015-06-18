//
//  HSEditAddressContainerTableViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSEditAddressContainerTableViewController.h"
#import "ActionSheetCustomPicker.h"
#import "HSAddressPickerDelegate.h"

@interface HSEditAddressContainerTableViewController ()<UITextViewDelegate,
UITextFieldDelegate>
{
    HSAddressPickerDelegate *_pickerdelegate;
    
    ActionSheetCustomPicker *_picker;
}


@end

@implementation HSEditAddressContainerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    _addressPlaceHolder = _addressLabel.text;
    _detailPlaceHolder = _detailAddressTextView.text;
    _detailAddressTextView.delegate = self;
    
    _userNameTextFiled.delegate = self;
    _phoneTextFiled.delegate = self;
    _userNameTextFiled.clearButtonMode = UITextFieldViewModeNever;
    _phoneTextFiled.clearButtonMode = UITextFieldViewModeNever;
    
    if (_addressModel != nil) { /// 不为nil 认为是更新的
        [self updateAddressWithOrigeModel:_addressModel];
    }
    
}



- (void)updateAddressWithOrigeModel:(HSAddressModel *)addressModel
{
    if (addressModel == nil) {
        return;
    }
    
    _userNameTextFiled.text = [HSPublic controlNullString:addressModel.consignee];
    _phoneTextFiled.text = [HSPublic controlNullString:addressModel.mobile];
    _addressLabel.text = [NSString stringWithFormat:@"%@%@%@",[HSPublic controlNullString:addressModel.sheng],[HSPublic controlNullString:addressModel.shi],[HSPublic controlNullString:addressModel.qu]];
    _detailAddressTextView.text = [HSPublic controlNullString:addressModel.address];
    
    _sheng = [HSPublic controlNullString:addressModel.sheng];
    _shi = [HSPublic controlNullString:addressModel.shi];
    _qu = [HSPublic controlNullString:addressModel.qu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark textView delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark textView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:_detailPlaceHolder]) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        textView.text = _detailPlaceHolder;
        textView.textColor = [UIColor grayColor];
    }
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

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

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hei = 44;
    
    if (indexPath.row == 3) {
        hei = 80;
    }
    
    return hei;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 2) {
        [self.view endEditing:YES];
        [self selectAddress];
    }
}

- (void)selectAddress
{
    if (_pickerdelegate == nil) {
       _pickerdelegate = [[HSAddressPickerDelegate alloc] init];
        __weak typeof(self) wself = self;
        _pickerdelegate.addressBlock = ^(NSString *sheng, NSString *shi, NSString *qu){
            wself.sheng = sheng;
            wself.shi = shi;
            wself.qu = qu;
            wself.addressLabel.text = [NSString stringWithFormat:@"%@%@%@",[HSPublic controlNullString:sheng],[HSPublic controlNullString:shi],[HSPublic controlNullString:qu]];
        };

    }
    
    if (_picker == nil) {
       _picker = [[ActionSheetCustomPicker alloc] initWithTitle:@"" delegate:_pickerdelegate showCancelButton:YES origin:self.tableView];
    }

    [_picker showActionSheetPicker];
    
    [_pickerdelegate selctedLast:(UIPickerView *)_picker.pickerView];

}



@end
