//
//  XYMVVMProDataStore.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYMVVMProModel1.h"
#import "XYMVVMProModel2.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMProDataStore : NSObject
@property (nonatomic, strong, readonly) id<XYMVVMProDataModel> model1;
@property (nonatomic, strong, readonly) XYMVVMProModel2 *model2;
- (instancetype)initWithModel1:(id<XYMVVMProDataModel>)model1;
@property (nonatomic, assign, readonly) BOOL isGetUserInfo;
@end

NS_ASSUME_NONNULL_END
