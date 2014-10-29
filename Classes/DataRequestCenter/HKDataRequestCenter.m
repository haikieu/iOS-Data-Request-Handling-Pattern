//
//  HKDataRequestCenter.m
//  DataHandlerDemo
//
//  Created by HK on 10/15/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//
#import "HKDataRequestSender.h"
#import "HKDataRequestCenter.h"
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <objc/message.h>
#import <objc/runtime.h>

@implementation HKDataRequestCenter

static id __obj;
+(instancetype)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __obj = [[self class] new];
    });
    return __obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //Initialize reachability
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            if(status == AFNetworkReachabilityStatusNotReachable)
            {
                [self networkIsConnected:NO];
            }
            else if(status == AFNetworkReachabilityStatusUnknown)
            {
                [self networkSearching];
            }
            else
            {
                [self networkIsConnected:YES];
            }
        }];
        
        [self.reachabilityManager startMonitoring];
        
        //Initialize AFNetworking
        self.sessionManager = [AFHTTPSessionManager manager];
        
        [self.sessionManager setTaskDidCompleteBlock:imp_getBlock(method_getImplementation(class_getInstanceMethod([self class], @selector(taskDidCompleteBlock:task:error:))))];
        
    }
    return self;
}

#pragma mark - HKDataRequestCenter

-(void)addRequester:(HKDataRequester*)requester
{
    [self networkActivityStarted];
    
    if(requester.isBlockingUI)
    {
        [self.blockingRequestQueue addObject:requester];
    }
    else
    {
        [self.requestQueue addObject:requester];
    }
}

-(void)requester:(HKDataRequester*)requester dataRequestComplete:(id<HKDataRequestResult>) result
{
    [requester dataRequestComplete:result];
}

-(void)removeRequest:(HKDataRequester*)requester
{
    if(requester.isBlockingUI)
    {
        [self.blockingRequestQueue removeObject:requester];
    }
    else
    {
        [self.requestQueue removeObject:requester];
    }
    
    [self networkActivityEnded];
}

-(void)logRequest:(HKDataRequester*)requester task:(NSURLSessionDataTask*)task url:(NSString*)URLString parameters:(id)parameters
{
    //TODO
}

-(void)logResponse:(HKDataRequester*)requester task:(NSURLSessionDataTask*)task response:(id)responseObject
{
    //TODO
}

#pragma mark - AFNetworking callback

-(void)success:(NSURLSessionDataTask*)task responseObject:(id)responseObject
{
    //TODO - handling success request
    HKDataRequester* requester = objc_getAssociatedObject(task, (__bridge const void *)(kRequester));
    
    [self logResponse:requester task:task response:responseObject];
    
    id<HKDataRequestResult> result;
    [self requester:requester dataRequestComplete:result];
    
    objc_setAssociatedObject(task, (__bridge const void *)(kRequester), nil, OBJC_ASSOCIATION_ASSIGN);
    
    [self removeRequest:requester];
}

-(void)failure:(NSURLSessionDataTask*)task error:(NSError*)error
{
    //TODO - handling failture request
    HKDataRequester* requester = objc_getAssociatedObject(task, (__bridge const void *)(kRequester));
    
    id<HKDataRequestResult> result;
    [self requester:requester dataRequestComplete:result];
    
    objc_setAssociatedObject(task, (__bridge const void *)(kRequester), nil, OBJC_ASSOCIATION_ASSIGN);
    
    [self removeRequest:requester];
}

-(void)taskDidCompleteBlock:(NSURLSession *)session task:(NSURLSessionTask *)task error:(NSError *)error
{
    HKDataRequester* requester = objc_getAssociatedObject(task, (__bridge const void *)(kRequester));
    
    //TODO - do some stuff
    
    objc_setAssociatedObject(task, (__bridge const void *)(kRequester), nil, OBJC_ASSOCIATION_ASSIGN);
    
    [self removeRequest:requester];
}

#pragma mark - AFNetworking request

static const NSString * kRequester = @"kRequester";

- (void)requester:(HKDataRequester*)requester GET:(NSString *)URLString
                   parameters:(id)parameters

{
    [self addRequester:requester];
    
    NSURLSessionDataTask * task = [self.sessionManager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self success:task responseObject:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failure:task error:error];
    }];
    
    objc_setAssociatedObject(task, (__bridge const void *)(kRequester), requester, OBJC_ASSOCIATION_ASSIGN);
 
    [self logRequest:requester task:task url:URLString parameters:parameters];
}

- (void)requester:(HKDataRequester*) requester POST:(NSString *)URLString
                    parameters:(id)parameters

{
    [self addRequester:requester];
    
    NSURLSessionDataTask * task = [self.sessionManager POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self success:task responseObject:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failure:task error:error];
    }];
    
     objc_setAssociatedObject(task, (__bridge const void *)(kRequester), requester, OBJC_ASSOCIATION_ASSIGN);
    
    [self logRequest:requester task:task url:URLString parameters:parameters];
}

#pragma mark - memory management

-(void)dealloc
{
    [self.requestQueue removeAllObjects];
    [self.blockingRequestQueue removeAllObjects];
    [self blockingGUIEnded];
    [self networkActivityEnded];
    [self.reachabilityManager stopMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - delegate - HKDataRequestCenterDelegate

-(void)networkSearching
{
    [self.delegate networkSearching];
}
-(void)networkIsConnected:(BOOL) isOnline
{
    [self.delegate networkIsConnected:isOnline];
}

-(void)networkActivityStarted
{
    if(self.requestQueue.count + self.blockingRequestQueue.count)
        return;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if([_delegate respondsToSelector:@selector(networkActivityStarted)])
       [_delegate networkActivityStarted];
}
-(void)networkActivityEnded
{
    if(self.requestQueue.count + self.blockingRequestQueue.count)
        return;
    
    if([_delegate respondsToSelector:@selector(networkActivityEnded)])
        [_delegate networkActivityEnded];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


-(void)blockingGUIStarted
{
    if(self.blockingRequestQueue.count)
        return;
    
    [_delegate blockingGUIStarted];
}
-(void)blockingGUIEnded
{
    if(self.blockingRequestQueue.count)
        return;

    [_delegate blockingGUIEnded];
}
-(void)blockingGUIUpdating:(NSString*)status
{
    [_delegate blockingGUIUpdating:status];
}

@end
