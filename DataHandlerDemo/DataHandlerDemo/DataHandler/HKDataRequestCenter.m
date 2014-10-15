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

-(void)networkActivityStarted:(BOOL) isBlock
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if([_delegate respondsToSelector:@selector(networkActivityStarted:)])
       [_delegate networkActivityStarted:isBlock];
}
-(void)networkActivityEnded:(BOOL) isBlock
{
    if([_delegate respondsToSelector:@selector(networkActivityEnded:)])
        [_delegate networkActivityEnded:isBlock];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
-(void)networkActivityChanged:(BOOL) isBlock status:(NSString*)status
{
    if([_delegate respondsToSelector:@selector(networkActivityChanged:status:)])
        [_delegate networkActivityChanged:isBlock status:status];
}

@end
