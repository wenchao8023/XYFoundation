//
//  XYMVVMProViewModel2.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYMVVMProActionRespondable.h"
#import "XYMVVMProDataStore.h"


NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMProViewModel2 : NSObject<XYMVVMProActionRespondable2>
@property (nonatomic, strong, readonly) XYMVVMProDataStore *dataStore;
- (instancetype)initWithDataStore:(XYMVVMProDataStore *)dataStore;
@end

NS_ASSUME_NONNULL_END
