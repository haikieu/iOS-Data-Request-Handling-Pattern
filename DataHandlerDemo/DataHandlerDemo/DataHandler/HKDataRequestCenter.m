//
//  HKDataRequestCenter.m
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "HKDataRequestCenter.h"
#import <UIKit/UIKit.h>
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

-(void)networkActivityBlockingStarted
{
    if([_delegate respondsToSelector:@selector(networkActivityBlockingStarted)])
        [_delegate networkActivityBlockingStarted];
}
-(void)networkActivityBlockingEnded
{
    if([_delegate respondsToSelector:@selector(networkActivityBlockingEnded)])
        [_delegate networkActivityBlockingEnded];
}
-(void)networkActivityBlockingChanged:(NSString*)status
{
    if([_delegate respondsToSelector:@selector(networkActivityBlockingChanged:)])
        [_delegate networkActivityBlockingChanged:status];
}

@end
