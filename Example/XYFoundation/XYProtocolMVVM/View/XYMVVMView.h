//
//  XYMVVMView.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/9.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYMVVMTextFieldView.h"
#import "XYMVVMBottomView.h"
#import "XYMVVMProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMView : UIView
@property (nonatomic, strong, readonly) XYMVVMTextFieldView *TFView;
@property (nonatomic, strong, readonly) XYMVVMBottomView *BTView;
@property (nonatomic, weak) id<XYMVVMViewDelegate> viewModel;
@end

NS_ASSUME_NONNULL_END
