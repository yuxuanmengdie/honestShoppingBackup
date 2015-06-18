//
//  HSAddressPickerDelegate.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionSheetPicker.h"

typedef void(^HSAddressPickerBlock)(NSString *sheng, NSString *shi, NSString *qu);

@interface HSAddressPickerDelegate : NSObject<ActionSheetCustomPickerDelegate>
{
    NSArray *_areaArr;
    
    NSInteger _firstColumnIdx;
    
    NSInteger _secondColumnIdx;
    
    NSInteger _thirdColumnIdx;
}

@property (nonatomic, copy) NSString *sheng;
@property (nonatomic, copy) NSString *shi;
@property (nonatomic, copy) NSString *qu;

@property (copy, nonatomic) HSAddressPickerBlock addressBlock;

- (void)selctedLast:(UIPickerView *)pickerView;

@end
