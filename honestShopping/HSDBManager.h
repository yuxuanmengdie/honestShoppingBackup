//
//  HSDBManager.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-6.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface HSDBManager : NSObject

/****/
/**
 *	@brief	数据库对象单例方法
 *
 *	@return	返回FMDateBase数据库操作对象
 */
+ (FMDatabase *)shareDataBase;


/**
 *	@brief	关闭数据库
 */
+ (void)closeDataBase;

/**
 *	@brief	清空数据库内容
 */
+ (void)deleteDataBase;

/**
 *	@brief	判断表是否存在
 *
 *	@param 	tableName 	表明
 *
 *	@return	创建是否成功
 */
+ (BOOL) isTableExist:(NSString *)tableName;


/**
 *	@brief	创建所有表
 *
 *	@return
 */
//+ (BOOL)createTable;
+ (BOOL)createTableWithTableName:(NSString *)tableName;
/**
 *	@brief	添加chatdata  如果主键重复就更新
 *
 *	@param 	chatData 	要保存的chatdata
 *
 *	@return	返回是否保存或者更新成功
 */

/// 删除表
+ (BOOL)deleteTableName:(NSString *)tableName;

/// 返回根据用户uid 返回不同的tableName
+ (NSString *)tableNameWithUid;

/// 新增单个记录
+ (BOOL)saveCartListWithTableName:(NSString *)tableName keyID:(NSString *)keyID data:(NSDictionary *)dataDic;

///  查找单个记录
+ (NSDictionary *)selectedItemWithTableName:(NSString *)tableName keyID:(NSString *)keyID;

/// 删除单个记录
+ (BOOL)deleteItemWithTableName:(NSString *)tableName keyID:(NSString *)keyID;

/// 遍历所有的
+ (NSMutableArray *)selectAllWithTableName:(NSString *)tableName;


#pragma mark -
#pragma mark 收藏的数据表
+ (NSString *)tableNameFavoriteWithUid;

+ (BOOL)saveFavoriteWithTableName:(NSString *)tableName keyID:(NSString *)keyID;

+ (BOOL)saveFavoriteArrayWithTableName:(NSString *)tableName arr:(NSArray *)keyArr;

+ (NSString *)selectFavoritetemWithTableName:(NSString *)tableName keyID:(NSString *)keyID;

+ (BOOL)deleteFavoriteItemWithTableName:(NSString *)tableName keyID:(NSString *)keyID;

+ (NSMutableArray *)selectFavoriteAllWithTableName:(NSString *)tableName;

+ (BOOL)deleteAllWithTableName:(NSString *)tableName;
@end
