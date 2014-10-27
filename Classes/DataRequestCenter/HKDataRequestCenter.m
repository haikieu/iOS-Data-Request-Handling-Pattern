//
//  HKDataRequestCenter.m
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "HKDataRequestCenter.h"
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

@implementation HKDataRequestCenter

static id __obj;
+(instancetype)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __obj = [[self class] new];
    });
    return __obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            if(status == AFNetworkReachabilityStatusNotReachable)
            {
                [self.delegate networkIsConnected:NO];
            }
            else if(status == AFNetworkReachabilityStatusUnknown)
            {
                [self.delegate networkSearching];
            }
            else
            {
                [self.delegate networkIsConnected:YES];
            }
        }];
        
        self.sessionManager = [AFHTTPSessionManager manager];
        
    }
    return self;
}

-(void)networkActivityStarted
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if([_delegate respondsToSelector:@selector(networkActivityStarted)])
       [_delegate networkActivityStarted];
}
-(void)networkActivityEnded
{
    if([_delegate respondsToSelector:@selector(networkActivityEnded)])
        [_delegate networkActivityEnded];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


-(void)blockingGUIStarted
{
//    if([_delegate respondsToSelector:@selector(blockingGUIStarted)])
        [_delegate blockingGUIStarted];
}
-(void)blockingGUIEnded
{
//    if([_delegate respondsToSelector:@selector(blockingGUIEnded)])
        [_delegate blockingGUIEnded];
}
-(void)blockingGUIUpdating:(NSString*)status
{
//    if([_delegate respondsToSelector:@selector(blockingGUIUpdating:)])
        [_delegate blockingGUIUpdating:status];
}

@end
