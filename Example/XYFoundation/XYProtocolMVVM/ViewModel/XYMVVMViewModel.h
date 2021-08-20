//
//  XYMVVMViewModel.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/9.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYMVVMBottomViewModel.h"
#import "XYMVVMTextFieldViewModel.h"
#import "XYMVVMProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMViewModel : NSObject<XYMVVMViewDelegate, XYMVVMTextFieldViewDelegate, XYMVVMBottomViewDelegate>
@property (nonatomic, strong, readonly) XYMVVMTextFieldViewModel *TFViewModel;
@property (nonatomic, strong, readonly) XYMVVMBottomViewModel *BTViewModel;
@end

NS_ASSUME_NONNULL_END
