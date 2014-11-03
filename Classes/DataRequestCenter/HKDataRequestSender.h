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

@interface HKDataRequester : NSObject <HKDataRequestDelegate>

#pragma request body
@property(nonatomic,strong) id<HKDataRequestDelegate> sender;
@property(nonatomic,assign) HKDataRequestStatus requestStatus;
@property(nonatomic,strong) NSString * requestTag;

#pragma GUI display
@property(nonatomic,assign) BOOL isBlockingUI;
@property(nonatomic,strong) NSString * UITitle;
@property(nonatomic,strong) NSString * UIMessage;

#pragma request business
- (void) cancel;



#if DEBUG

#pragma node debug

- (void) stackTrace;

#endif

@end

@interface HKDataRequestSender : HKDataRequester

#pragma node linking algorithm
@property(nonatomic,weak) HKDataRequestSender * previousSender;
@property(nonatomic,weak) HKDataRequestSender * nextSender;

@property(nonatomic,weak,readonly) HKDataRequestSender * firstSender;
@property(nonatomic,weak,readonly) HKDataRequestSender * lastSender;

- (NSUInteger) totalLevel;
- (NSUInteger) currentLevel;
- (NSUInteger) upLevel;
- (NSUInteger) downLevel;

- (BOOL) isFirstSender;
- (BOOL) isLastSender;
- (BOOL) isForwarder;

-(instancetype)initWithSender:(id<HKDataRequestDelegate>)sender;

-(instancetype) viaFilter:(id<HKDataRequestDelegate>) objc;
-(instancetype) viaCache:(id<HKDataRequestDelegate>) objc;
-(instancetype) viaForwarder:(id<HKDataRequestDelegate>) objc;
-(instancetype) viaManager:(id<HKDataRequestDelegate>) objc;

@end

@interface HKDataRequestAppFilter    : HKDataRequestSender @end
@interface HKDataRequestAppCache     : HKDataRequestSender @end
@interface HKdataRequestAppForwarder : HKDataRequestSender @end
@interface HKDataRequestAppManager   : HKDataRequestSender @end


