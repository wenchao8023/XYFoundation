//
//  XYMVVMProDataStore.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProDataStore.h"

@interface XYMVVMProDataStore ()
@property (nonatomic, strong) id<XYMVVMProDataModel> model1;
@property (nonatomic, strong) XYMVVMProModel2 *model2;
@end

@implementation XYMVVMProDataStore
- (instancetype)initWithModel1:(id<XYMVVMProDataModel>)model1 {
    self = [super init];
    if (self) {
        _model1 = model1;
    }
    return self;
}

- (BOOL)isGetUserInfo {
    return (self.model1 && self.model1.name && self.model1.address);
}

- (XYMVVMProModel2 *)model2 {
    if (!_model2) {
        _model2 = [XYMVVMProModel2 new];
    }
    return _model2;
}

@end
