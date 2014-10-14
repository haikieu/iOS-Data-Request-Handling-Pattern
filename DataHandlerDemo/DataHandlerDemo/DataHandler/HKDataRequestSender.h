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
    HKDataRequestStatusUnknown = 0,
    HKDataRequestStatusDoing = 1<<0,
    HKDataRequestStatusCompleted = 1 << 1,
    HKDataRequestStatusCancel = 1 << 2
};

@protocol HKDataRequestSender <HKDataRequestDelegate>

@required

- (id<HKDataRequestSender>) rootSender;
- (id<HKDataRequestSender>) roofSender;
- (id<HKDataRequestDelegate>) sender;
- (HKDataRequestStatus) requestStatus;
- (void) cancel;

@optional

- (id<HKDataRequestSender>) finalRoot;
- (id<HKDataRequestSender>) finalRoof;

- (BOOL) isFinalRoot;
- (BOOL) isFinalRoof;
- (BOOL) isMediator;

#if DEBUG

- (void) stackTrace;

#endif

@end

@interface HKDataRequestSender : NSObject <HKDataRequestSender>

-(instancetype)initSender:(id<HKDataRequestDelegate>) sender withRoot:(HKDataRequestSender*) root;
@property(nonatomic,readonly) id<HKDataRequestDelegate> sender;
@property(nonatomic,weak) HKDataRequestSender * rootSender;
@property(nonatomic,weak) HKDataRequestSender * roofSender;

@property(nonatomic,readonly) HKDataRequestSender * finalRoot;
@property(nonatomic,readonly) HKDataRequestSender * finalRoof;

@property(nonatomic,assign) HKDataRequestStatus requestStatus;

- (NSUInteger) totalLevel;
- (NSUInteger) currentLevel;
- (NSUInteger) upLevel;
- (NSUInteger) downLevel;

@end
