//
//  HKDataRequestCenter.h
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;
@class AFNetworkReachabilityManager;
@protocol HKDataRequestCenterDelegate <NSObject>

-(void)networkSearching;
-(void)networkIsConnected:(BOOL) isOnline;

-(void)networkActivityStarted;
-(void)networkActivityEnded;

-(void)blockingGUIStarted;
-(void)blockingGUIEnded;
-(void)blockingGUIUpdating:(NSString*)status;

@end

@interface HKDataRequestCenter : NSObject

@property(nonatomic,weak) id<HKDataRequestCenterDelegate> delegate;

+(instancetype)defaultCenter;


@property(nonatomic,strong) NSMutableArray * blockingRequestQueue;
@property(nonatomic,strong) NSMutableArray * requestQueue;

#pragma mark - pods - AFNetworking
@property(nonatomic,weak) AFNetworkReachabilityManager * reachabilityManager;
@property(nonatomic,weak) AFHTTPSessionManager * sessionManager;

@end
