//
//  XYMVVMProTraceServer.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProTraceServer.h"
#import "XYMVVMProDataStore.h"

@interface XYMVVMProTraceServer ()
@property (nonatomic, strong) XYMVVMProDataStore *dataStore;
@end

@implementation XYMVVMProTraceServer

- (instancetype)initWithDataStore:(XYMVVMProDataStore *)dataStore {
    self = [super init];
    if (self) {
        _dataStore = dataStore;
    }
    return self;
}

- (void)mvvmViewActionCallback {
    NSLog(@"【埋点】%s", __func__);
}

- (void)mvvmView1ActionCallback {
    NSLog(@"【埋点】%s", __func__);
}

- (void)mvvmView2ActionCallback {
    NSLog(@"【埋点】%s", __func__);
}

@end
