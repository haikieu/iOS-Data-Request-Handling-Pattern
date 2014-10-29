//
//  HKDataRequestCenterDelegate.h
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

@protocol HKDataRequestCenterDelegate <NSObject>

-(void)networkSearching;
-(void)networkIsConnected:(BOOL) isOnline;

-(void)networkActivityStarted;
-(void)networkActivityEnded;

-(void)blockingGUIStarted;
-(void)blockingGUIEnded;
-(void)blockingGUIUpdating:(NSString*)status;

@end