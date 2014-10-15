//
//  HKDataRequestCenterDelegate.h
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

@protocol HKDataRequestCenterDelegate <NSObject>

-(void)networkActivityStarted:(BOOL) isBlock;
-(void)networkActivityEnded:(BOOL) isBlock;
-(void)networkActivityChanged:(BOOL) isBlock status:(NSString*)status;

@end