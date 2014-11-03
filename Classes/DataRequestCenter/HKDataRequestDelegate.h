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

- (id<HKDataRequestResult>) dataRequestComplete:(id<HKDataRequestResult>) result;

@end