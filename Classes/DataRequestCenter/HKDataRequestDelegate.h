//
//  HkDataRequestDelegate.h
//  DataHandlerDemo
//
//  Created by Hai Kieu on 10/14/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//
#import "HKDataRequestResult.h"

@protocol HKDataRequestDelegate <NSObject>

@required

- (void) dataRequestComplete:(id<HKDataRequestResult>) result;

@optional

- (void) dataRequestPreComplete:(id<HKDataRequestResult>) result;
- (void) dataRequestPostComplete:(id<HKDataRequestResult>) result;

@end