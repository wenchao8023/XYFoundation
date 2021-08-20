//
//  XYMVVMTextFieldView.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/11.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYMVVMProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMTextFieldView : UIView
@property (weak, nonatomic) id<XYMVVMTextFieldViewDelegate> viewModel;
@end

NS_ASSUME_NONNULL_END
