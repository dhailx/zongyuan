//
//  NetworkMonitor.h
//  SaffronClient
//
//  Created by Sam on 12-4-18.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
// 此类为网络判断和实时监控。

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface NetworkMonitor : NSObject
{
	Reachability *hostReach;
}

//网络判断
enum {
	NotNetworkStatu = 0, //没有网络
	NetworkisWWAN, //3G网络
	NetworkisWiFi //wifi网络
	
};
typedef	uint32_t NetworkStatusType;

@property (nonatomic)NetworkStatusType netStatus;

+(id)getInstance;

@end
