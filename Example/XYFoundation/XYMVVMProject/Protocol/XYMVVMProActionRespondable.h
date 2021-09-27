//
//  XYMVVMProActionRespondable.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 定义事件流转的协议
@protocol XYMVVMProActionRespondable <NSObject>
- (void)mvvmViewActionCallback;
@property (nonatomic, copy) void (^hideView2Block)(BOOL isHidden);
@end


@protocol XYMVVMProActionRespondable1 <NSObject>
- (void)mvvmView1ActionCallback;
@property (nonatomic, copy) void (^updateColorBlock)(UIColor *color);
@property (nonatomic, copy) UIColor *(^getColorBlock)();
@end


@protocol XYMVVMProActionRespondable2 <NSObject>
- (void)mvvmView2ActionCallback;
@end

NS_ASSUME_NONNULL_END
