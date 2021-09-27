//
//  XYMVVMProViewController.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@class XYMVVMProViewModel;
@interface XYMVVMProViewController : UIViewController
- (instancetype)initWithViewModel:(XYMVVMProViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
