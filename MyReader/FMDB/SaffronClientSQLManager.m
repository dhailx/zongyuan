//
//  SaffronClientSQLManager.m
//  SaffronClient
//
//  Created by lushuang on 12-5-8.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SaffronClientSQLManager.h"
#import "FMDatabaseAdditions.h"
//#import "SaffronClientDefine.h"
//#import "SaffronClientHeader.h"
//#import "SaffronClientPublic.h"


#ifndef DocumentPath
#define DocumentPath [NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()]
#endif

#ifndef DBDoc
//主目录
#define DBDoc [NSString stringWithFormat:@"%@/dbdoc",DocumentPath]
#endif

#define CREATE_BOOK_TABLE  @"CREATE TABLE books(Id integer,bookName text,localPath text,bookType text)"



#define SafeReleaseObj(obj) \
{\
if (nil != obj)\
{\
[obj release];\
obj = nil;\
}\
}
@interface SaffronClientSQLManager(PrivateMethod)
-(void)openDB;
///-(void)closeDB;
//- (NSString*) copyDBFileToDocument:(NSString *)sqlName;

@end


@implementation SaffronClientSQLManager

static SaffronClientSQLManager* instance =nil; 
@synthesize bAll,strId;
+(SaffronClientSQLManager*) getInstance
{
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [[self alloc] init];
        }
        
        
        return instance;
    }
}


//-(id)init
//{
//    
//    self=[super init];
//    if (self) {
//        
//        NSFileManager * manager=[NSFileManager defaultManager];
//        if (![manager fileExistsAtPath:DBDoc]) {
//            [manager createDirectoryAtPath:DBDoc withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        
//        NSString * path=[NSString stringWithFormat:@"%@/sqlite.db",DBDoc];
//        
//        BOOL isHave=NO;
//        if ([manager fileExistsAtPath:path]) {
//            isHave=YES;
//        }
//        
//        dbFM=[[FMDatabase alloc] initWithPath:path];
//        [dbFM open];
//        
//        if (isHave==NO) {
//            [dbFM executeUpdate:CREATE_BOOK_TABLE];
//        }
//    }
//    
//    return self;
//}

-(id)init
{
	if (self = [super init]) 
	{
		dbname      = SaffronClientSQLManager_SQL_Name;
        openDbOK  = NO;
  //      dbFM = [[FMDatabase alloc] initWithPath:[SaffronClientPublic copyDBFileToDocument:@"Main.db"]];
        dbFM = [[FMDatabase alloc] initWithPath:[self copyDBFileToDocument:@"Book.db"]];
        [self openDB];
        bAll=YES;
        strId=@"";
	}
    
	return self;
}
-(NSString*) filePath
{
    return nil;//[SaffronClientPublic copyDBFileToDocument:@"Main.db"];
    
    // test
    //NSString *strDoc = @"/Users/goodoldshoes/Desktop/Temp/Main.db";
    
//    return [self copyDBFileToDocument:@"Main.db"];
    
    
    //NSString *strDoc = [[NSBundle mainBundle] pathForResource:dbname ofType:@"db"];
//    NSString *strDoc = [[NSBundle mainBundle] pathForResource:dbname ofType:@"db"];
    
    //NSLog(@"db path : %@",strDoc);
	//return strDoc;
}

- (NSString *) copyDBFileToDocument:(NSString *)sqlName
{
	BOOL bSuccess;
	NSFileManager *fileManager=[NSFileManager defaultManager];
	NSError *error;
	
	NSArray * paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString * documentDirectory=[paths objectAtIndex:0];
    NSString *localPath = [documentDirectory stringByAppendingPathComponent:@"Local"];
    bSuccess = [fileManager fileExistsAtPath:localPath];
    if (!bSuccess)
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
	NSString *destDBPath=[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Local/%@",sqlName]];
	bSuccess=[fileManager fileExistsAtPath:destDBPath];
    NSLog(@"&&&:\n%@",destDBPath);
	if(bSuccess) return destDBPath;
	
	NSString *defaultDBPath=[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:sqlName];
    NSLog(@"defaultDBPath = %@======================",defaultDBPath);
	bSuccess=[fileManager copyItemAtPath:defaultDBPath toPath:destDBPath error:&error];
	if(!bSuccess)
	{
		NSLog(@"Failed to create writable database %@,%@",sqlName,error.localizedFailureReason);
        return nil;
	}
    return destDBPath;
}

-(void) openDB
{
    if (![dbFM open])   
    {
        //NSLog(@"SaffronClientSQLManager open Fail");
    }
    else 
    {
        openDbOK = YES;
        //NSLog(@"SaffronClientSQLManager open OK");
    }
}

-(void)closeDB
{
    if (![dbFM close])
    {
        //NSLog(@"SaffronClientSQLManager close Fail");
    }
    else 
    {
        openDbOK = NO;
        //NSLog(@"SaffronClientSQLManager close OK");
    }
    
}

#pragma mark modifyMainSql --
-(BOOL)modifyMainSqlWithSqlSentence:(NSString*)sqlSentence;
{
    @synchronized(self)
    {
        if (!openDbOK)
        {
            [self openDB];
        }
        
        BOOL result = YES;
        NSError *err = 0x00;
        
        result = result && [dbFM update:sqlSentence withErrorAndBindings:&err];

        if (NO == result)
        {
            //NSLog(@"modify failed");
            if (err != nil) 
            {
                NSLog(@"*********FMDB err is %@ !!",[err localizedFailureReason]);
            }
        }
        else 
        {
            NSLog(@"modify successed");
        }
        
        return result;
    }
}

-(BOOL)modifyMainSqlWithSqlSentenceWithKeys:(NSMutableArray*)arrKeys wityValues:(NSMutableArray*)arrValues withTableName:(NSString*)tableName
{
    @synchronized(self)
    {
        //NSLog(@"*****************Data");
        if (!openDbOK)
        {
            [self openDB];
        }
        
        BOOL result = YES;
        NSError *err = 0x00;
        
        NSMutableString *keys = [NSMutableString new];
        NSMutableString *values = [NSMutableString new];
        int iKeyCount = (int)[arrKeys count];
        int iValueCount = (int)[arrValues count];
        if (iKeyCount != iValueCount)
        {
            SafeReleaseObj(keys);
            SafeReleaseObj(values);
            return NO;
        }
        
        for (int i =0; i<iKeyCount; i++)
        {
            [keys appendString:[arrKeys objectAtIndex:i]];
            if (i != iKeyCount-1)
            {
                [keys appendString:@","];
            }
        }
        
        for (int i =0; i<iValueCount; i++)
        {
            [values appendString:@"?"];
            if (i != iValueCount-1)
            {
                [values appendString:@","];
            }
        }
        
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)",tableName,keys,values];
        //result = result && [dbFM executeUpdate:insertSql,[arrValues objectAtIndex:0],[arrValues objectAtIndex:1]];
        result = result && [dbFM executeUpdate:insertSql withArgumentsInArray:arrValues];
        
        if (NO == result)
        {
            //NSLog(@"modify failed");
            if (err != nil) 
            {
                NSLog(@"FMDB err is %@ !!",[err localizedFailureReason]);
            }
        }
        else 
        {
            //NSLog(@"modify successed");
        }
        
        SafeReleaseObj(keys);
        SafeReleaseObj(values);
        return result;
    }
}


//系统数据库Main.db查询方法
#pragma mark selectMethods -- 
//-(FMResultSet*)selectWithSqlSentence:(NSString*)sqlSentence
//{
//	@synchronized(self) {
//        if (!openDbOK) {
//            [self openDB];
//        }
//        
//		FMResultSet *rs = [dbFM executeQuery:sqlSentence];
//		
//		return rs;
//    }
//	
//}

-(NSMutableArray*)selectWithSqlSentenceN:(NSString*)sqlSentence
{
	@synchronized(self) 
    {
        if (!openDbOK) {
            [self openDB];
        }
        
		FMResultSet *rs = [dbFM executeQuery:sqlSentence];
		
        NSMutableArray *arrTemp = [[NSMutableArray new] autorelease];
        
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        while ([rs next])
        {
            NSDictionary *dicTemp = [[NSDictionary alloc] initWithDictionary:[rs resultDictionary]];
            [arrTemp addObject:dicTemp];
            
            [dicTemp release];
        }
        
        [rs close];
        
        [pool release];
        
		return arrTemp;
    }
}

#pragma mark 批量
-(void)beginTransaction
{
    //[dbFM beginTransaction];
    [dbFM beginDeferredTransaction];
}

-(void)endTransactionWithResult:(BOOL)bResult
{
    if(!bResult)
        [dbFM rollback];
    else
        [dbFM commit];
}


-(NSString*)getSafeValueWithDic:(NSDictionary*)rsDic withName:(NSString*)name
{
    NSString *Value = nil;
    
    if ((![rsDic objectForKey:name]) || ([[rsDic objectForKey:name] isKindOfClass:[NSNull class]]))
    {
        NSLog(@"=============================================================================================== nil");
        Value =@"";
    }
    else
    {
        Value = [NSString stringWithFormat:@"%@",[rsDic objectForKey:name]];
    }
    
    return Value;
}



-(void)dealloc
{ 
    [dbFM close];
    [dbFM release];
    
	[super dealloc];
}
@end
