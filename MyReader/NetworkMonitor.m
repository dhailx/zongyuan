//
//  NetworkMonitor.m
//  SaffronClient
//
//  Created by Sam on 12-4-18.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkMonitor.h"

#define NetworkMonitor_Net_									@"www.baidu.com"
#define DispatcherManager_Task_MSG_NetWork_Change         @"DispatcherManager_Task_MSG_NetWork_Change"

@implementation NetworkMonitor
@synthesize netStatus;

static NetworkMonitor *uniqueNetworkMonitor = nil;

+(id)getInstance
{
    @synchronized(self)
    {
        if (nil == uniqueNetworkMonitor)
        {
            // 唯一实例
            uniqueNetworkMonitor = [[NetworkMonitor alloc] init];
        }
    }
	
	return uniqueNetworkMonitor;
}

-(id)init
{
	if (self=[super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
		
		hostReach=[[Reachability reachabilityWithHostName:NetworkMonitor_Net_] retain];//可以以多种形式初始化
		[hostReach startNotifier];  //开始监听,会启动一个run loop
	}
	
	return self;
}

- (void) updateInterfaceWithReachability:(Reachability*) curReach

{
    //对连接改变做出响应的处理动作。
	
	NetworkStatus staus = [curReach currentReachabilityStatus];
	
	NSString *objSend = [NSString stringWithFormat:@"%i",staus];
	[[NSNotificationCenter defaultCenter] postNotificationName:DispatcherManager_Task_MSG_NetWork_Change 
                                                        object:objSend];
}

- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	[self updateInterfaceWithReachability: curReach];
	
}

-(void)dealloc
{
    [hostReach release];
	[super dealloc];
}

@end
