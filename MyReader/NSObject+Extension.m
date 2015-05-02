//
//  NSObject+Extension.m
//  MyReader
//
//  Created by YDJ on 13-5-26.
//  Copyright (c) 2013年 NJGuo. All rights reserved.
//

#import "NSObject+Extension.h"
#import <objc/runtime.h>

@implementation NSObject (Extension)

-(void)setUserInfo_Ext:(NSDictionary *)newUserInfo_Ext
{
    objc_setAssociatedObject(self, @"userInfo_Ext", newUserInfo_Ext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)userInfo_Ext
{
    return objc_getAssociatedObject(self, @"userInfo_Ext");
}
@end
