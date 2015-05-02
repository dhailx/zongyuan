//
//  SaffronClientSQLManager.h
//  SaffronClient
//
//  Created by lushuang on 12-5-8.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
//#import "SaffronClientDefine.h"

#define SaffronClientSQLManager_SQL_Name         @"Book"

@class FMDatabase;
@class FMResultSet;
@interface SaffronClientSQLManager : NSObject
{
@private
	NSString*   dbname;
    FMDatabase  *dbFM;
    BOOL        openDbOK;
}

+(SaffronClientSQLManager*) getInstance;

-(BOOL)modifyMainSqlWithSqlSentence:(NSString*)sqlSentence;

-(BOOL)modifyMainSqlWithSqlSentenceWithKeys:(NSMutableArray*)arrKeys wityValues:(NSMutableArray*)arrValues withTableName:(NSString*)tableName;

// 注意：返回的FMResultSet *rs; 需要对rs进行close [rs close];
//-(FMResultSet*)selectWithSqlSentence:(NSString*)sqlSentence; // 废弃
-(NSMutableArray*)selectWithSqlSentenceN:(NSString*)sqlSentence;

-(NSString*)getSafeValueWithDic:(NSDictionary*)rsDic withName:(NSString*)name;

-(void)beginTransaction;
-(void)endTransactionWithResult:(BOOL)bResult;

-(NSString*) filePath;

-(void)closeDB;


@property BOOL bAll;

@property (copy,nonatomic)NSString *strId;

@end
