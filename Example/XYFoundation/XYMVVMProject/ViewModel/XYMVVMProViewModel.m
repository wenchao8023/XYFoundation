//
//  XYMVVMProViewModel.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProViewModel.h"

@interface XYMVVMProViewModel ()
@property (nonatomic, strong) XYMVVMProViewModel1 *proViewModel1;
@property (nonatomic, strong) XYMVVMProViewModel2 *proViewModel2;
@property (nonatomic, strong) XYMVVMProDataStore *dataStore;
@end

@implementation XYMVVMProViewModel
- (instancetype)initWithDataStore:(XYMVVMProDataStore *)dataStore block:(nonnull void (^)(NSString * _Nonnull))testBlock  {
    self = [super init];
    if (self) {
        _dataStore = dataStore;
        _testBlock = testBlock;
    }
    return self;
}

- (XYMVVMProViewModel1 *)proViewModel1 {
    if (!_proViewModel1) {
        _proViewModel1 = [[XYMVVMProViewModel1 alloc] initWithDataStore:self.dataStore];
    }
    return _proViewModel1;
}

- (XYMVVMProViewModel2 *)proViewModel2 {
    if (!_proViewModel2) {
        _proViewModel2 = [[XYMVVMProViewModel2 alloc] initWithDataStore:self.dataStore];
    }
    return _proViewModel2;
}

@end
