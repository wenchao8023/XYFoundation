//
//  XYMVVMProViewModel.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYMVVMProActionRespondable.h"
#import "XYMVVMProViewModel1.h"
#import "XYMVVMProViewModel2.h"
#import "XYMVVMProDataStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMProViewModel : NSObject<XYMVVMProActionRespondable>
@property (nonatomic, strong, readonly) XYMVVMProViewModel1 *proViewModel1;
@property (nonatomic, strong, readonly) XYMVVMProViewModel2 *proViewModel2;
@property (nonatomic, strong, readonly) XYMVVMProDataStore *dataStore;
@property (nonatomic, copy, readonly)   void (^testBlock)(NSString * _Nonnull);
- (instancetype)initWithDataStore:(XYMVVMProDataStore *)dataStore block:(nonnull void (^)(NSString * _Nonnull))testBlock;
@end

NS_ASSUME_NONNULL_END
