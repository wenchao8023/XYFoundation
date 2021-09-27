//
//  XYMVVMProDependencyFactory.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProDependencyFactory.h"
#import "XYMVVMProViewController.h"
#import "XYMVVMProDataStore.h"
#import "XYMVVMProViewModel.h"


@implementation XYMVVMProDependencyFactory
+ (UIViewController *)createMVVMProViewController:(NSString *)testName
                                            model:(nonnull id<XYMVVMProDataModel>)testModel
                                            block:(nonnull void (^)(NSString * _Nonnull))testBlock {
    XYMVVMProDataStore *dataStore = [[XYMVVMProDataStore alloc] initWithModel1:testModel];
    XYMVVMProViewModel *viewModel = [[XYMVVMProViewModel alloc] initWithDataStore:dataStore block:testBlock];
    XYMVVMProViewController *vc = [[XYMVVMProViewController alloc] initWithViewModel:viewModel];
    return vc;
}
@end
