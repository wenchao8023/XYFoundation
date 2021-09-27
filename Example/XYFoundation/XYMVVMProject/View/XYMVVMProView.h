//
//  XYMVVMProView.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYMVVMProActionRespondable.h"
#import "XYMVVMProView1.h"
#import "XYMVVMProView2.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMProView : UIView
@property (nonatomic, weak) id<XYMVVMProActionRespondable> actionResponder;
@property (nonatomic, strong, readonly) XYMVVMProView1 *proView1;
@property (nonatomic, strong, readonly) XYMVVMProView2 *proView2;
@end

NS_ASSUME_NONNULL_END
