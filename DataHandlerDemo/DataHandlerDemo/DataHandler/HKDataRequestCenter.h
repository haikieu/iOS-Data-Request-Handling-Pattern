//
//  HKDataRequestCenter.h
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKDataRequestCenterDelegate.h"
@interface HKDataRequestCenter : NSObject

@property(nonatomic,weak) id<HKDataRequestCenterDelegate> delegate;

+(instancetype)defaultCenter;

@property NSOperationQueue * blockingRequestQueue;
@property NSOperationQueue * requestQueue;

@end
