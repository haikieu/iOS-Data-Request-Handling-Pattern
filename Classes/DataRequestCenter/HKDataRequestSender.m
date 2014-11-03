//
//  HKDataRequestSender.m
//  DataHandlerDemo
//
//  Created by Hai Kieu on 10/14/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "HKDataRequestSender.h"
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>


@implementation HKDataRequester @end

@implementation HKDataRequestAppCache @end
@implementation HKDataRequestAppFilter @end
@implementation HKdataRequestAppForwarder @end
@implementation HKDataRequestAppManager @end

@implementation HKDataRequestSender

@dynamic previousSender;
@dynamic nextSender;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestStatus = HKDataRequestStatusUnknown;
    }
    return self;
}

#pragma mark - Initializer

-(instancetype)initWithSender:(id<HKDataRequestDelegate>)sender withRoot:(HKDataRequestSender *)root
{
    self = [self init];
    if (self) {
        root.nextSender = self;
        self.previousSender = root;
        self.sender = sender;
        root.requestStatus = self.requestStatus = root ? root.requestStatus : HKDataRequestStatusDoing;
    }
    return self;
}

-(instancetype)initWithSender:(id<HKDataRequestDelegate>)sender
{
    self = [self initWithSender:sender withRoot:nil];
    if (self) {

    }
    return self;
}

-(instancetype)viaCache:(id<HKDataRequestDelegate>)objc
{
    id returnObj = [[HKDataRequestAppCache alloc] initWithSender:objc withRoot:self];
    return returnObj;
}

-(instancetype)viaFilter:(id<HKDataRequestDelegate>)objc
{
    id returnObj = [[HKDataRequestAppFilter alloc] initWithSender:objc withRoot:self];
    return returnObj;
}

-(instancetype)viaForwarder:(id<HKDataRequestDelegate>)objc
{
    id returnObj = [[HKdataRequestAppForwarder alloc] initWithSender:objc withRoot:self];
    return returnObj;
}

-(instancetype)viaManager:(id<HKDataRequestDelegate>)objc
{
    id returnObj = [[HKDataRequestAppManager alloc] initWithSender:objc withRoot:self];
    return returnObj;
}

#pragma node body

-(NSString *)requestTag
{
    if([self isFirstSender])
        return self.requestTag;
    else
        return [[self firstSender] requestTag];
}

-(void)setRequestTag:(NSString *)requestTag
{
    if([self isFirstSender])
        self.requestTag = requestTag;
    else
        return [[self firstSender] setRequestTag:requestTag];
}

#pragma request business

-(void)cancel
{
    [[self firstSender] cancelRequest];
}

-(void)cancelRequest
{
    self.requestStatus |= HKDataRequestStatusCancel;
    [[self nextSender] cancelRequest];
}

-(id<HKDataRequestResult>)dataRequestComplete:(id<HKDataRequestResult>)result
{
    //TODO - need verify this condition
    if([self requestStatus]==HKDataRequestStatusCancel)
        return nil;
    
    self.requestStatus = HKDataRequestStatusCompleted;
   
    id returnResult = [self.sender dataRequestComplete:result];
    
    if(!self.isFirstSender)
    {
        //forward the result to original sender
        [[self previousSender] dataRequestComplete:returnResult];
    }
    
    return nil;
}

#pragma memory management

-(void)setPreviousSender:(HKDataRequestSender *)previousSender
{
    objc_setAssociatedObject(self, @selector(previousSender), previousSender,OBJC_ASSOCIATION_RETAIN);
}

-(void)setNextSender:(HKDataRequestSender *)nextSender
{
    objc_setAssociatedObject(self, @selector(nextSender), nextSender,OBJC_ASSOCIATION_RETAIN);
}

-(HKDataRequestSender *)nextSender
{
    id objc = objc_getAssociatedObject(self, @selector(nextSender));
    return objc;
}
-(HKDataRequestSender *)previousSender
{
    id objc = objc_getAssociatedObject(self, @selector(previousSender));
    return objc;
}

- (void) tightRequestLinking
{
    [self foreach:[self firstSender] block:^(HKDataRequestSender *sender) {
        [self tightRequestLinking:sender];
    }];
}

-(void) tightRequestLinking:(HKDataRequestSender *)sender
{
    id objc = sender.previousSender;
    if(objc)
        objc_setAssociatedObject(sender, @selector(previousSender), objc, OBJC_ASSOCIATION_RETAIN);
    
    objc = sender.nextSender;
    if(objc)
        objc_setAssociatedObject(sender, @selector(nextSender), objc, OBJC_ASSOCIATION_RETAIN);
}

- (void) decoupleRequestLinking
{
    [self foreach:[self firstSender] block:^(HKDataRequestSender *sender) {
        [self decoupleRequestLinking:sender];
    }];
}

- (void) decoupleRequestLinking:(HKDataRequestSender *)sender
{
    id objc = sender.previousSender;
    if(objc)
        objc_setAssociatedObject(sender, @selector(previousSender), objc, OBJC_ASSOCIATION_ASSIGN);
    
    objc = sender.nextSender;
    if(objc)
        objc_setAssociatedObject(sender, @selector(nextSender), objc, OBJC_ASSOCIATION_ASSIGN);
}


-(void)dealloc
{
    [self decoupleRequestLinking:self];
    objc_removeAssociatedObjects(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma node linking algorithm

-(void)foreach:(HKDataRequestSender*) root block:(void(^)(HKDataRequestSender* sender))doSomething
{
    if(doSomething)
        doSomething(root);
    
//    [self foreach:root.nextSender block:doSomething];
}

-(HKDataRequestSender *)firstSender
{
    if([self isFirstSender])
        return self;
    else
        return [self previousSender];
}

-(HKDataRequestSender *)lastSender
{
    if([self isLastSender])
        return self;
    else
        return [self nextSender];
}

-(BOOL)isFirstSender
{
    return [self previousSender] == nil;
}

-(BOOL)isForwarder
{
    return ![self isFirstSender];
}

-(BOOL)isLastSender
{
    return [self nextSender] == nil;
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
    return (self.nextSender != nil) + [self.nextSender upLevel];
}

-(NSUInteger)downLevel
{
    return (self.previousSender != nil) + [self.previousSender downLevel];
}

#ifdef DEBUG

#pragma stack trace

-(void)stackTrace
{
    [[self firstSender] printTraceInfo];
}

-(void)printTraceInfo
{
    NSLog(@"%@", [self traceInfo]);
    [[self nextSender] printTraceInfo];
}

-(NSString *)statusInfo
{
    switch (self.requestStatus) {
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

#endif

@end
