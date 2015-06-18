//
//  HSAddressPickerDelegate.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSAddressPickerDelegate.h"

@implementation HSAddressPickerDelegate

- (id)init
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"area" ofType:@".plist"];
        _areaArr = [[NSArray alloc] initWithContentsOfFile:path];
        
        _firstColumnIdx = 0;
        _secondColumnIdx = 0;
        _thirdColumnIdx = 0;
    }
    return self;
}

- (void)selctedLast:(UIPickerView *)pickerView
{
    [pickerView reloadComponent:0];
    [pickerView selectRow:_firstColumnIdx inComponent:0 animated:NO];
    [pickerView reloadComponent:1];
    [pickerView selectRow:_secondColumnIdx inComponent:1 animated:NO];
    [pickerView reloadComponent:2];
    [pickerView selectRow:_thirdColumnIdx inComponent:2 animated:NO];
    
    
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - ActionSheetCustomPickerDelegate Optional's
/////////////////////////////////////////////////////////////////////////
- (void)configurePickerView:(UIPickerView *)pickerView
{
    // Override default and hide selection indicator
    pickerView.showsSelectionIndicator = NO;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
//    NSString *resultMessage = [NSString stringWithFormat:@"%@ %@ selected.",
//                               self.selectedKey,
//                               self.selectedScale];
//    
//    [[[UIAlertView alloc] initWithTitle:@"Success!" message:resultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - UIPickerViewDataSource Implementation
/////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // Returns
    NSInteger num = 0;
    switch (component) {
        case 0:
        {
            num = [_areaArr count];
        }
            break;
        case 1:
        {
            NSDictionary *city = [_areaArr objectAtIndex:_firstColumnIdx];
            NSArray *shi = [city.allValues firstObject];
            num = [shi count];
        }
            break;
        case 2:
        {
            NSDictionary *city = [_areaArr objectAtIndex:_firstColumnIdx];
            NSArray *shi = [city.allValues firstObject];
            NSDictionary *quDic = [shi objectAtIndex:_secondColumnIdx];
            NSArray *qu = [quDic.allValues firstObject];
            num = [qu count];
        }
            break;

        default:break;
    }
    return num;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark UIPickerViewDelegate Implementation
/////////////////////////////////////////////////////////////////////////

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
//    switch (component) {
//        case 0: return 60.0f;
//        case 1: return 260.0f;
//        default:break;
//    }
//    
//    return 0;
    return pickerView.frame.size.width/3.0;
}
/*- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
 {
 return
 }
 */
// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *result = @"";
    switch (component) {
        case 0:
        {
            NSDictionary *sheng = [_areaArr objectAtIndex:row];
            result = [sheng.allKeys firstObject];
        }
            break;
        case 1:
        {
            NSDictionary *sheng = [_areaArr objectAtIndex:_firstColumnIdx];
            NSArray *shi = [sheng.allValues firstObject];
            NSDictionary *shiDic = [shi objectAtIndex:row];
            
            result = [shiDic.allKeys firstObject];

        }
             break;
        case 2:
        {
            NSDictionary *sheng = [_areaArr objectAtIndex:_firstColumnIdx];
            NSArray *shi = [sheng.allValues firstObject];
            NSDictionary *shiDic = [shi objectAtIndex:_secondColumnIdx];
            NSArray *qu = [shiDic.allValues firstObject];
            result = qu[row];
        }
             break;
            
        default:break;
    }
    return result;
}

/////////////////////////////////////////////////////////////////////////

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Row %li selected in component %li", (long)row, (long)component);
    switch (component) {
        case 0:
        {
            _firstColumnIdx = row;
            _secondColumnIdx = 0;
            _thirdColumnIdx = 0;
            [pickerView reloadComponent:1];
            [pickerView selectRow:_secondColumnIdx inComponent:1 animated:NO];
            [pickerView reloadComponent:2];
            [pickerView selectRow:_thirdColumnIdx inComponent:2 animated:NO];
        }
            break;
        case 1:
        {
            _secondColumnIdx = row;
            _thirdColumnIdx = 0;
            [pickerView reloadComponent:2];
            [pickerView selectRow:_thirdColumnIdx inComponent:2 animated:NO];
        }
            break;
        case 2:
        {
            _thirdColumnIdx = row;
        }
            break;
        default:break;
    }
    
    
    NSDictionary *sheng = [_areaArr objectAtIndex:_firstColumnIdx];
    NSArray *shi = [sheng.allValues firstObject];
    NSDictionary *shiDic = [shi objectAtIndex:_secondColumnIdx];
    NSArray *qu = [shiDic.allValues firstObject];
    _sheng =  [sheng.allKeys firstObject];;
    _shi = [shiDic.allKeys firstObject];
    _qu = qu[_thirdColumnIdx];
    
    if (self.addressBlock) {
        self.addressBlock(_sheng,_shi,_qu);
    }
}


- (NSString *)p_dicKeyFromInt:(NSInteger)row
{
   return [NSString stringWithFormat:@"%ld",(long)row];
}

@end
