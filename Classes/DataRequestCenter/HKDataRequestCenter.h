//
//  HKDataRequestCenter.h
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKDataRequestCenterDelegate.h"
@class HKDataRequester;
@class AFHTTPSessionManager;
@class AFNetworkReachabilityManager;

@interface HKDataRequestCenter : NSObject

@property(nonatomic,weak) id<HKDataRequestCenterDelegate> delegate;

+(instancetype)defaultCenter;

@property(nonatomic,strong) NSMutableArray * blockingRequestQueue;
@property(nonatomic,strong) NSMutableArray * requestQueue;

#pragma mark - pods - AFNetworking
@property(nonatomic,weak) AFNetworkReachabilityManager * reachabilityManager;
@property(nonatomic,weak) AFHTTPSessionManager * sessionManager;

- (void)requester:(HKDataRequester*)requester GET:(NSString *)URLString parameters:(id)parameters;

- (void)requester:(HKDataRequester*) requester POST:(NSString *)URLString parameters:(id)parameters;

@end