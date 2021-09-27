//
//  XYMVVMProTraceServer.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYMVVMProActionRespondable.h"


NS_ASSUME_NONNULL_BEGIN
@class XYMVVMProDataStore;
@interface XYMVVMProTraceServer : NSObject
<
XYMVVMProActionRespondable,
XYMVVMProActionRespondable1,
XYMVVMProActionRespondable2
>
- (instancetype)initWithDataStore:(XYMVVMProDataStore *)dataStore;
@end

NS_ASSUME_NONNULL_END
