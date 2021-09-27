//
//  XYMVVMProDependencyFactory.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYMVVMProDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMProDependencyFactory : NSObject
+ (UIViewController *)createMVVMProViewController:(NSString *)testName
                                            model:(nonnull id<XYMVVMProDataModel>)testModel
                                            block:(nonnull void (^)(NSString * _Nonnull))testBlock;
@end

NS_ASSUME_NONNULL_END
