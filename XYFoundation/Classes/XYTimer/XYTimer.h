//
//  XYTimer.h
//
//  Created by 郭文超 on 2019/5/30.
//  Copyright © 2019 Mastercom. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  基于GCD开发的一个定时器
 *  1. 解决NSTimer在滑动scroll时不准确问题
 *  2. 解决NSTimer造成的循环引用问题
 *  3. 解决子线程runloop不自启对NSTimer的影响
 *  4. 提供更加灵活、直观的API
 *  5. 未提供不重复的场景，如果要不重复，直接使用dispatch_after即可
 */


NS_ASSUME_NONNULL_BEGIN

@interface XYTimer : NSObject

/**
 创建定时器初始化方法
 
 @param timeInterval 时间间隔     默认为1
 @param timeStart    第几秒开始（调用startTimer之后开始计时）  默认为0
 @param timeEnd      第几秒结束（调用startTimer之后开始计时）  默认为0
 @param inBlock      事件处理回调
 @return 定时器实例
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                               start:(NSTimeInterval)timeStart
                                 end:(NSTimeInterval)timeEnd
                             inBlock:(void (^)())inBlock;

/**
 创建定时器初始化方法
 
 @param timeInterval 时间间隔     默认为1
 @param timeStart    第几秒开始（调用startTimer之后开始计时）  默认为0
 @param inBlock      事件处理回调
 @return 定时器实例
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                               start:(NSTimeInterval)timeStart
                             inBlock:(void (^)())inBlock;

/**
 创建定时器初始化方法
 
 @param timeInterval 时间间隔     默认为1
 @param timeEnd      第几秒结束（调用startTimer之后开始计时）  默认为0
 @param inBlock      事件处理回调
 @return 定时器实例
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                                 end:(NSTimeInterval)timeEnd
                             inBlock:(void (^)())inBlock;

/**
 创建定时器初始化方法
 
 @param timeInterval 时间间隔     默认为1
 @param inBlock      事件处理回调
 @return 定时器实例
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                             inBlock:(void (^)())inBlock;

/** 开启定时器 */
- (void)startTimer;

/** 暂停定时器 */
- (void)pauseTimer;

/** 恢复定时器 */
- (void)resumeTimer;

/** 停止定时器（释放） */
- (void)stopTimer;

@end

NS_ASSUME_NONNULL_END
