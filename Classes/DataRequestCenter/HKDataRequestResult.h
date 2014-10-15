//
//  HKDataRequestResult.h
//  DataHandlerDemo
//
//  Created by Hai Kieu on 10/14/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HKDataRequestResultStatus) {
    HKDataRequestResultSuccess,
    HKDataRequestResultFailure
};

@protocol HKDataRequestResult <NSObject>

@end

@interface HKDataRequestResult : NSObject <HKDataRequestResult>

@property HKDataRequestResultStatus status;
@property NSString * url;
@property NSString * error;
@property id body;

@end
