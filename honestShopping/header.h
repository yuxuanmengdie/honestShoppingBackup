//
//  header.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-17.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#ifndef honestShopping_header_h
#define honestShopping_header_h



#define iOS_7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f     //  判断是不是 iOS 7 以上系统

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define Main_Rect_Width [UIScreen mainScreen].bounds.size.width
#define Main_Rect_Height [UIScreen mainScreen].bounds.size.height

#define ColorRGB(r,g,b) [UIColor colorWithRed:(r*1.0/255) green:(g*1.0/255) blue:(b*1.0/255) alpha:1.0]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define LogFunc NSLog(@"%s",__PRETTY_FUNCTION__)

#ifdef DEBUG
#else
#define NSLog(...){}; //#define NSLog(...){};
#endif



#endif
