//
//  XYMVVMProModel1.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProModel1.h"

@interface XYMVVMProModel1 ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@end

@implementation XYMVVMProModel1
- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (NSString *)address {
    return @"address 可以改";
}
@end
