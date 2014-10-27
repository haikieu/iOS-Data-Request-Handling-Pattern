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

@implementation HKDataRequest



@end

@implementation HKDataRequestSender

@dynamic previousSender;
@dynamic nextSender;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestStatus = HKDataRequestStatusDoing;
    }
    return self;
}

-(instancetype)initSender:(id<HKDataRequestDelegate>)sender withRoot:(HKDataRequestSender *)root
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

-(void)dataRequestComplete:(id<HKDataRequestResult>)result
{
    //TODO - need verify this condition
    if([self requestStatus]==HKDataRequestStatusCancel)
        return;
    
    self.requestStatus = HKDataRequestStatusCompleted;
    
    if([self.sender respondsToSelector:@selector(dataRequestPreComplete:)])
    {
        [self.sender dataRequestPreComplete:result];
    }

    [self.sender dataRequestComplete:result];
    
    if([self.sender respondsToSelector:@selector(dataRequestPostComplete:)])
    {
        [self.sender dataRequestPostComplete:result];
    }
    
    //forward the result to original sender
    [[self previousSender] dataRequestComplete:result];
    
    //decouple node linking by set all properties by weak
    [self decoupleRequestLinking];
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
    [self decoupleRequestLinking];
    objc_removeAssociatedObjects(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma node linking algorithm

-(void)foreach:(HKDataRequestSender*) root block:(void(^)(HKDataRequestSender* sender))doSomething
{
    if(doSomething)
        doSomething(root);
    
    [self foreach:root.nextSender block:doSomething];
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
