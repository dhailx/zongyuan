//
//  Decrypt.h
//  MyReader
//
//  Created by baby on 13-8-13.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Decrypt : NSObject
+(NSString *)filePath:(NSString *)dataPath DecryptKey:(NSString *)keyStr fileName:(NSString *)fileName;
+(NSData *)reSetDataMove:(NSData *)tmpData;
+(NSString *)dFlie:(NSString *)bookName;
@end
