//
//  DBItem.m
//  MyReader
//
//  Created by YDJ on 13-6-1.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import "DBItem.h"

#ifndef DocumentPath
#define DocumentPath [NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()]
#endif

#ifndef DBDoc
//主目录
#define DBDoc [NSString stringWithFormat:@"%@/dbdoc",DocumentPath]
#endif

#define CREATE_BOOK_TABLE  @"CREATE TABLE books(Id integer,bookName text,localPath text,bookType text)"



#define Select_Into_Notes_SQL_ @"select * from 'T_ReportNote' where PageID = '%@' and ReportID= '%@' and UserID = '%@' order by OID"
#define Insert_Into_Notes_SQL_ @"insert into 'T_ReportNote'(ID,PageID,ReportID,UserID,OID,Name,PositionX,PositionY,Content,Password,LockState,IsUpload,CreateTime,ModifyTime) values('%@','%@','%@','%@',%d,'%@',%f,%f,'%@','%@','%@','%@','%@','%@')"
#define UpDate_Into_Notes_SQL_ @"update T_ReportNote set Content = '%@',PositionX = %f,PositionY = %f,LockState = '%@',IsUpload = '%@',ModifyTime = '%@' where ID = '%@' and PageID = '%@' and ReportID = '%@'"
#define Delete_Into_Notes_SQL_ @"update T_ReportNote set LockState = '%@',IsUpload = '%@' where ID = '%@' and PageID = '%@' and ReportID = '%@'"


@implementation DBItem

static DBItem * dbitem= nil;

+(DBItem *)getDBtem
{
    
    @synchronized(self)
    {
        if(dbitem == nil)
        {
            dbitem = [[self alloc] init];
        }
        
        return dbitem;
    }

}
-(id)init
{

    self=[super init];
    if (self) {
        
        NSFileManager * manager=[NSFileManager defaultManager];
        if (![manager fileExistsAtPath:DBDoc]) {
            [manager createDirectoryAtPath:DBDoc withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString * path=[NSString stringWithFormat:@"%@/sqlite.db",DBDoc];
        
        BOOL isHave=NO;
        if ([manager fileExistsAtPath:path]) {
            isHave=YES;
        }
        
        _dataBase=[[FMDatabase alloc] initWithPath:path];
        [_dataBase open];

        if (isHave==NO) {
          [_dataBase executeUpdate:CREATE_BOOK_TABLE];
        }
    }
    
    return self;
}

-(void)insertDataBaseSql:(NSString *)string
{
    
    
}
-(void)upLoadDataBaseSql:(NSString *)string
{
    
    
}
@end
