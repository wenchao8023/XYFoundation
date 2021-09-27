//
//  XYMVVMProDataModel.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/24.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 定义数据模型协议
@protocol XYMVVMProDataModel <NSObject>
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *address;
@end

NS_ASSUME_NONNULL_END
