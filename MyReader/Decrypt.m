//
//  Decrypt.m
//  MyReader
//
//  Created by baby on 13-8-13.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import "Decrypt.h"

@implementation Decrypt

+(NSData *)reSetDataMove:(NSData *)tmpData
{
    
    NSUInteger len = [tmpData length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [tmpData bytes], len);
    for (int i=0; i<[tmpData length]; i++) {
        
        UInt8 cc=byteData[i];
        switch (cc) {
            case 10:
            { byteData[i]=1;
                break;
            }
            case 1:
            {
                byteData[i]=10;
                break;
            }
            case 30:
            {
                byteData[i]=3;
                break;
            }
            case 3:
            {
                byteData[i]=30;
                break;
            }
            case 50:
            {
                byteData[i]=5;
                break;
            }
            case 5:
            {
                byteData[i]=50;
                break;
            }
            case 70:
            {
                byteData[i]=7;
                break;
            }
            case 7:
            {
                byteData[i]=70;
                
                break;
            }
            case 90:
            {
                byteData[i]=9;
                break;
            }
            case 9:
            {
                byteData[i]=90;
                break;
            }
            case 110:
            {
                byteData[i]=11;
                break;
            }
            case 11:
            {
                byteData[i]=110;
                break;
            }
            default:
                break;
        }
        
    }
    NSData * ttData=[NSData dataWithBytes:byteData length:[tmpData length]];
    free(byteData);
    return ttData;
}

+(NSString *)filePath:(NSString *)dataPath DecryptKey:(NSString *)keyStr fileName:(NSString *)fileName
{
    NSData * pngData=[NSData dataWithContentsOfFile:dataPath];

    NSData * tempData=[keyStr dataUsingEncoding:NSUTF8StringEncoding];

    //先对调
    //    NSData *  data1=[self reSetDataMove:pngData];
    //    //再移除
    //    NSData * reData=[data1 subdataWithRange:NSMakeRange(tempData.length, pngData.length-tempData.length)];
    
    //移除
    NSData *reData =[pngData subdataWithRange:NSMakeRange(tempData.length,pngData.length-tempData.length)];    
    NSData *  data1=[self reSetDataMove:reData];
//    NSLog(@"--775%@",reData);

    NSString * ePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * doc=[ePath stringByAppendingPathComponent:@"fileTemp"];
    NSFileManager *fileManager = [NSFileManager defaultManager];			//创建文件管理器
	//判断temp文件夹是否存在
	BOOL fileExists = [fileManager fileExistsAtPath:doc];
	if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
		[fileManager createDirectoryAtPath:doc withIntermediateDirectories:YES attributes:nil error:nil];
	}
    NSString * fileTmp=[doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    [data1 writeToFile:fileTmp atomically:YES];
    NSLog(@"--%@,%@",fileTmp,doc);
    return fileTmp;
}

+(NSString *)dFlie:(NSString *)bookName{
    NSString * ePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * doc=[ePath stringByAppendingPathComponent:@"fileTemp"];
    NSString * fileTmp=[doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",bookName]];
    return fileTmp;
}

@end
