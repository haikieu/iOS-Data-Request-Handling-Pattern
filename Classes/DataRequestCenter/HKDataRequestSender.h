//
//  HKDataRequestSender.h
//  DataHandlerDemo
//
//  Created by Hai Kieu on 10/14/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKDataRequestDelegate.h"

typedef NS_ENUM(NSUInteger, HKDataRequestStatus) {
    HKDataRequestStatusUnknown   = 0,
    HKDataRequestStatusDoing     = 1 << 0,
    HKDataRequestStatusCompleted = 1 << 1,
    HKDataRequestStatusCancel    = 1 << 2
};

@protocol HKDataRequestSender <HKDataRequestDelegate>

-(instancetype)initSender:(id<HKDataRequestDelegate>) sender withRoot:(id<HKDataRequestSender>) root;

@end


@interface HKDataRequestSender : NSObject <HKDataRequestSender>

#pragma node bodyß
@property(nonatomic,strong) id<HKDataRequestDelegate> sender;
@property(nonatomic,assign) HKDataRequestStatus requestStatus;
@property(nonatomic,strong) NSString * requestTag;

#pragma request business
- (void) cancel;

#pragma GUI display
@property(nonatomic,assign) BOOL isBlockingUI;
@property(nonatomic,strong) NSString * UITitle;
@property(nonatomic,strong) NSString * UIMessage;

#pragma node linking algorithm

@property(nonatomic,assign) HKDataRequestSender * previousSender;
@property(nonatomic,assign) HKDataRequestSender * nextSender;

@property(nonatomic,readonly) HKDataRequestSender * firstSender;
@property(nonatomic,readonly) HKDataRequestSender * lastSender;

- (NSUInteger) totalLevel;
- (NSUInteger) currentLevel;
- (NSUInteger) upLevel;
- (NSUInteger) downLevel;

- (BOOL) isFirstSender;
- (BOOL) isLastSender;
- (BOOL) isForwarder;

#pragma node debug

#if DEBUG

- (void) stackTrace;

#endif

@end
