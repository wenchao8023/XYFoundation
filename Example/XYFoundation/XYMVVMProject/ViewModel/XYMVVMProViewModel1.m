//
//  XYMVVMProViewModel1.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProViewModel1.h"

@interface XYMVVMProViewModel1 ()
@property (nonatomic, strong) XYMVVMProDataStore *dataStore;
@end

@implementation XYMVVMProViewModel1
@synthesize getColorBlock=_getColorBlock;
@synthesize updateColorBlock=_updateColorBlock;

- (instancetype)initWithDataStore:(XYMVVMProDataStore *)dataStore {
    self = [super init];
    if (self) {
        _dataStore = dataStore;
    }
    return self;
}


@end
