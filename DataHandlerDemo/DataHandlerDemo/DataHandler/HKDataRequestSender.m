//
//  HKDataRequestSender.m
//  DataHandlerDemo
//
//  Created by Hai Kieu on 10/14/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "HKDataRequestSender.h"
#import <UIKit/UIKit.h>
@implementation HKDataRequestSender
{
    HKDataRequestStatus _requestStatus;
}

-(HKDataRequestStatus)requestStatus
{
    return _requestStatus;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _requestStatus = HKDataRequestStatusDoing;
    }
    return self;
}

-(instancetype)initSender:(id<HKDataRequestDelegate>)sender withRoot:(HKDataRequestSender *)root
{
    self = [super init];
    if (self) {
        root.roofSender = self;
        self.rootSender = root;
        _sender = sender;
        root.requestStatus = self.requestStatus = root ? root.requestStatus : HKDataRequestStatusDoing;
    }
    return self;
}

-(void)networkActivityStarted {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)networkActivityEnded {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)cancel
{
    [[self finalRoot] cancelRequest];
}

-(void)cancelRequest
{
    _requestStatus |= HKDataRequestStatusCancel;
    [[self roofSender] cancelRequest];
}

-(void)dataRequestComplete:(id<HKDataRequestResult>)result
{
    if([self requestStatus]==HKDataRequestStatusCancel)
        return;
    
    _requestStatus = HKDataRequestStatusCompleted;
    
    if([self respondsToSelector:@selector(dataRequestPreComplete:)])
    {
        [self dataRequestPreComplete:result];
    }

    [[self sender] dataRequestComplete:result];
    
    if([self respondsToSelector:@selector(dataRequestPostComplete:)])
    {
        [self dataRequestPostComplete:result];
    }
    
    [[self rootSender] dataRequestComplete:result];
}

-(HKDataRequestSender *)finalRoot
{
    if([self isFinalRoot])
        return self;
    else
        return [self rootSender];
}

-(HKDataRequestSender *)finalRoof
{
    if([self isFinalRoof])
        return self;
    else
        return [self roofSender];
}

-(BOOL)isFinalRoot
{
    return [self rootSender] == nil;
}

-(BOOL)isMediator
{
    return ![self isFinalRoot];
}

-(BOOL)isFinalRoof
{
    return [self roofSender] == nil;
}

-(NSUInteger)totalLevel
{
    return [self currentLevel] + [self upLevel];
}

-(NSUInteger)currentLevel
{
    return [self downLevel] + 1;
}

-(NSUInteger)upLevel
{
    return (self.roofSender != nil) + [self.roofSender upLevel];
}

-(NSUInteger)downLevel
{
    return (self.rootSender != nil) + [self.rootSender downLevel];
}

-(void)stackTrace
{
    [[self finalRoot] printTraceInfo];
}

-(void)printTraceInfo
{
    NSLog(@"%@", [self traceInfo]);
    [[self roofSender] printTraceInfo];
}

-(NSString *)statusInfo
{
    switch (_requestStatus) {
        case HKDataRequestStatusCancel | HKDataRequestStatusDoing:
            return @"Doing & Cancel";
        case HKDataRequestStatusCancel:
            return @"Cancel";
        case HKDataRequestStatusCompleted:
            return @"Completed";
        case HKDataRequestStatusDoing:
            return @"Doing";
        case HKDataRequestStatusUnknown:
            return @"N/A";
    }
}

-(NSString *)traceInfo
{
    NSUInteger requestOrder = [self currentLevel];
    NSString * statusInfo = [self statusInfo];
    NSString * senderClass = NSStringFromClass([self.sender class]);

    return [NSString stringWithFormat:@"[%lu]%@ status:%@",requestOrder, senderClass,statusInfo];
}

@end
