//
//  HKDataRequestCenterDelegate.h
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

@protocol HKDataRequestCenterDelegate <NSObject>

-(void)networkActivityStarted;
-(void)networkActivityEnded;

-(void)networkActivityBlockingStarted;
-(void)networkActivityBlockingEnded;
-(void)networkActivityBlockingChanged:(NSString*)status;

@end