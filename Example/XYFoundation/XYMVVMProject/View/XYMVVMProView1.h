//
//  XYMVVMProView1.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYMVVMProActionRespondable.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYMVVMProView1 : UIView
@property (nonatomic, weak) id<XYMVVMProActionRespondable1> actionResponder;
@end

NS_ASSUME_NONNULL_END
