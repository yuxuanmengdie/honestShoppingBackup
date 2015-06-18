//
//  HSDBManager.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-6.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSDBManager.h"

@implementation HSDBManager

#define dataBaseName @"dataBase.sqlite"

#define dataBasePath [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)) lastObject]stringByAppendingPathComponent:dataBaseName]

static NSString *const kCartTableName = @"cartList";

static NSString *const kColumnIDKey = @"id";

static NSString *const kColumnDataDicKey = @"dataDic";

+ (FMDatabase *)shareDataBase {
    static dispatch_once_t onceToken;
    static FMDatabase *dataBase = nil;
    dispatch_once(&onceToken, ^{
        dataBase = [FMDatabase databaseWithPath:dataBasePath] ;
        
        });
    return dataBase;
}

/**
 判断数据库中表是否存在
 **/
+ (BOOL) isTableExist:(NSString *)tableName
{
    FMResultSet *rs = [[self shareDataBase] executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        int count = [rs intForColumn:@"count"];
        NSLog(@"%@ isOK %d", tableName,count);
        
        if (0 == count)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

/**
 创建表
 **/
+ (BOOL)createTableWithTableName:(NSString *)tableName
{
    NSLog(@"%@",dataBasePath);
    
    
    if ([[self shareDataBase] open]) {
        if (![HSDBManager isTableExist:tableName]) {
            //                    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE \"%@\" (\"message_id\" TEXT PRIMARY KEY  NOT NULL  check(typeof(\"message_id\") = 'text') , \"att\" BLOB)",tableName];
            NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@  (%@ text  primary key, %@ BLOB)",tableName,kColumnIDKey,kColumnDataDicKey];
            
            NSLog(@"no Medicine ");
            [[self shareDataBase] executeUpdate:sql];
            
            
        }
        [[self shareDataBase] close];
    }
    
    
    return YES;

}

/**
 关闭数据库
 **/
+ (void)closeDataBase {
    if(![[self shareDataBase] close]) {
        NSLog(@"数据库关闭异常，请检查");
        return;
    }
}

/**
 删除数据库
 **/
+ (void)deleteDataBase {
    if ([self shareDataBase] != nil) {
        //这里进行数据库表的删除工作
    }
}

+ (BOOL)deleteTableName:(NSString *)tableName
{
 
    BOOL isSuc = NO;
    if ([[self shareDataBase] open]) {
        if ([HSDBManager isTableExist:tableName]) {
            NSString *sql = [NSString stringWithFormat:@"Drop TABLE %@",tableName];
            isSuc = [[self shareDataBase] executeUpdate:sql];
           
        }
        [[self shareDataBase] close];
    }

    return isSuc;
}

+ (NSString *)tableNameWithUid
{
    if (![HSPublic isLoginInStatus]) {
        return kCartTableName;
    }
    
    NSDictionary *userInfo = [HSPublic userInfoFromPlist];
    NSString *uid = userInfo[kPostJsonid];
    NSString *result = [NSString stringWithFormat:@"%@%@",kCartTableName,uid];
    return result;
    
}

/// 保存单个记录
+ (BOOL)saveCartListWithTableName:(NSString *)tableName keyID:(NSString *)keyID data:(NSDictionary *)dataDic
{
    BOOL isOk = NO;
    [HSDBManager createTableWithTableName:tableName];
    if ([[self shareDataBase] open]) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@) VALUES(?,?)",tableName,kColumnIDKey,kColumnDataDicKey];
       
        isOk = [[self shareDataBase] executeUpdate:
                sql,keyID,[NSKeyedArchiver archivedDataWithRootObject:dataDic]];
        [[self shareDataBase] close];
    }
    return isOk;

}

+ (NSDictionary *)selectedItemWithTableName:(NSString *)tableName keyID:(NSString *)keyID
{
    NSDictionary *resultDic = nil;
    if ([[self shareDataBase] open]) {
        FMResultSet *s = [[self shareDataBase] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,kColumnIDKey,keyID]];
        if ([s next]) {
            resultDic = [NSKeyedUnarchiver unarchiveObjectWithData:[s dataForColumn:kColumnDataDicKey]];
        }
        [[self shareDataBase] close];
    }
    return resultDic;
}

+ (BOOL)deleteItemWithTableName:(NSString *)tableName keyID:(NSString *)keyID
{
    BOOL isOK = NO;
    if ([[self shareDataBase] open])
    {
        //   NSString *str = [];
        isOK = [[self shareDataBase] executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",tableName,kColumnIDKey,keyID]];
        [[self shareDataBase] close];
    }
    return isOK;
}


+ (NSMutableArray *)selectAllWithTableName:(NSString *)tableName
{

    if ([[self shareDataBase] open])
    {
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        FMResultSet *Result = [[self shareDataBase] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ",tableName]];
        while ([Result next])
        {
           NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData: [Result objectForColumnName:kColumnDataDicKey] ];
           
            [arr addObject:dic];
        }
        [[self shareDataBase] close];
        
        return arr;
    }
    return nil;
}

#pragma -
#pragma mark 已经收藏的表

static NSString *const kFavoriteTableName = @"favoriteTable";

static NSString *const kFavoriteColumnID = @"favoriteID";

+ (NSString *)tableNameFavoriteWithUid
{
    if (![HSPublic isLoginInStatus]) {
        return [HSPublic controlNullString:kFavoriteTableName];
    }
    
    NSDictionary *userInfo = [HSPublic userInfoFromPlist];
    NSString *uid = userInfo[kPostJsonid];
    NSString *result = [NSString stringWithFormat:@"%@%@",kFavoriteTableName,uid];
    return result;

}

+ (BOOL)createFavoriteTableWithTableName:(NSString *)tableName
{
    NSLog(@"%@",dataBasePath);
    
    
    if ([[self shareDataBase] open]) {
        if (![HSDBManager isTableExist:tableName]) {
            //                    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE \"%@\" (\"message_id\" TEXT PRIMARY KEY  NOT NULL  check(typeof(\"message_id\") = 'text') , \"att\" BLOB)",tableName];
            NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@  (%@ text  primary key)",tableName,kFavoriteColumnID];
            
            NSLog(@"no Medicine ");
            [[self shareDataBase] executeUpdate:sql];
            
            
        }
        [[self shareDataBase] close];
    }
    
    
    return YES;
    
}

/// 保存单个记录
+ (BOOL)saveFavoriteWithTableName:(NSString *)tableName keyID:(NSString *)keyID
{
    BOOL isOk = NO;
    [HSDBManager createFavoriteTableWithTableName:tableName];
    if ([[self shareDataBase] open]) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES(?)",tableName,kFavoriteColumnID];
        
        isOk = [[self shareDataBase] executeUpdate:
                sql,keyID];
        [[self shareDataBase] close];
    }
    return isOk;
    
}

+ (BOOL)saveFavoriteArrayWithTableName:(NSString *)tableName arr:(NSArray *)keyArr
{
    __block BOOL isOk = NO;
    [HSDBManager createFavoriteTableWithTableName:tableName];
    if ([[self shareDataBase] open]) {
        [keyArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES(?)",tableName,kFavoriteColumnID];
            
            isOk = [[self shareDataBase] executeUpdate:
                    sql,obj];

        }];
        [[self shareDataBase] close];
    }
    return isOk;

}

+ (NSString *)selectFavoritetemWithTableName:(NSString *)tableName keyID:(NSString *)keyID
{
    NSString *resultDic = nil;
    if ([[self shareDataBase] open]) {
        FMResultSet *s = [[self shareDataBase] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,kFavoriteColumnID,keyID]];
        if ([s next]) {
            resultDic = [s objectForColumnName:kFavoriteColumnID];
        }
        [[self shareDataBase] close];
    }
    return resultDic;
}

+ (BOOL)deleteFavoriteItemWithTableName:(NSString *)tableName keyID:(NSString *)keyID
{
    BOOL isOK = NO;
    if ([[self shareDataBase] open])
    {
        //   NSString *str = [];
        isOK = [[self shareDataBase] executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",tableName,kFavoriteColumnID,keyID]];
        [[self shareDataBase] close];
    }
    return isOK;
}


+ (NSMutableArray *)selectFavoriteAllWithTableName:(NSString *)tableName
{
    
    if ([[self shareDataBase] open])
    {
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        FMResultSet *Result = [[self shareDataBase] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ",tableName]];
        while ([Result next])
        {
            NSString *text = [Result objectForColumnName:kFavoriteColumnID];
            [arr addObject:text];
        }
        [[self shareDataBase] close];
        
        return arr;
    }
    return nil;
}


+ (BOOL)deleteAllWithTableName:(NSString *)tableName
{
    BOOL isOK = NO;
    if ([[self shareDataBase] open])
    {
        //   NSString *str = [];
        isOK = [[self shareDataBase] executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@",tableName]];
        [[self shareDataBase] close];
    }
    return isOK;

}

@end
