//
//  XYTimer.m
//  COMMONNOP
//
//  Created by 郭文超 on 2019/5/30.
//  Copyright © 2019 Mastercom. All rights reserved.
//

#import "XYTimer.h"


static dispatch_queue_t xy_timer_queue() {
    static dispatch_queue_t _xyTimerQueue;
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _xyTimerQueue = dispatch_queue_create("cn.xy.timer", DISPATCH_QUEUE_CONCURRENT);
    });
    return _xyTimerQueue;
}

static NSString * const XYTimerLockName = @"cn.xy.timer.lock";


typedef enum : NSUInteger {
    XYTimerStatusUnInit,//未初始化，默认状态，，，或者是调用stopTimer之后的被释放的状态
    XYTimerStatusResumed,//调用startTimer，处于运行状态
    XYTimerStatusSusponded,//调用pauseTimer，处于挂起状态
} XYTimerStatus;


@interface XYTimer ()
//定时器
@property (nonatomic, strong) dispatch_source_t timer;
//多久之后开始执行定时任务，单位s，默认0
@property (nonatomic, assign) NSTimeInterval timeStart;
//多久之后停止定时任务，单位s，默认0
@property (nonatomic, assign) NSTimeInterval timeEnd;
//多久重复一次定时任务
@property (nonatomic, assign) NSTimeInterval timeInterval;
//每次定时任务回调
@property (nonatomic, copy   ) void (^inBlock)();
//定时器当前的状态
@property (nonatomic, assign) XYTimerStatus status;
//锁
@property (nonatomic, strong) NSLock *lock;

@end


@implementation XYTimer

#pragma mark - Lazy Load
- (dispatch_source_t)timer {
    if (_timer == NULL) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, xy_timer_queue());
        //设置何时开始任务
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0);
        //设置重复时间间隔
        uint64_t interval = (uint64_t)(self.timeInterval * NSEC_PER_SEC);
        //设置定时器
        dispatch_source_set_timer(_timer, startTime, interval, 0);
        // 设置回调
        dispatch_source_set_event_handler(_timer, ^{
            [self runTimer];
        });
    }
    return _timer;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
        _lock.name = XYTimerLockName;
    }
    return _lock;
}

#pragma mark - Inits
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                             inBlock:(void (^)())inBlock {
    return [self initWithTimeInterval:timeInterval
                                start:0
                                  end:0
                              inBlock:inBlock];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                                 end:(NSTimeInterval)timeEnd
                             inBlock:(void (^)())inBlock {
    return [self initWithTimeInterval:timeInterval
                                start:0
                                  end:timeEnd
                              inBlock:inBlock];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                               start:(NSTimeInterval)timeStart
                             inBlock:(void (^)())inBlock {
    return [self initWithTimeInterval:timeInterval
                                start:timeStart
                                  end:0
                              inBlock:inBlock];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                               start:(NSTimeInterval)timeStart
                                 end:(NSTimeInterval)timeEnd
                             inBlock:(void (^)())inBlock {
    if ([self init]) {
        self.timeInterval = timeInterval;
        self.timeStart    = timeStart;
        self.timeEnd      = timeEnd;
        self.inBlock      = inBlock;
        
        if (self.timeEnd) {
            
        }
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeInterval = 1;
        self.timeStart    = 0;
        self.timeEnd      = 0;
        self.inBlock      = NULL;
        self.status       = XYTimerStatusUnInit;
    }
    return self;
}

#pragma mark - Timer Action
//运行定时器
- (void)runTimer {
    //将事件回调出去
    if (self.inBlock) {
        self.inBlock();
    }
}

- (void)startTimer {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeStart * NSEC_PER_SEC)), xy_timer_queue(), ^{
        [self resumeTimer];
    });
    
    if (self.timeEnd>0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeEnd * NSEC_PER_SEC)), xy_timer_queue(), ^{
            [self stopTimer];
        });
    }
}

- (void)pauseTimer {
    [self.lock lock];
    dispatch_suspend(self.timer);
    self.status = XYTimerStatusSusponded;
    [self.lock unlock];
}

- (void)resumeTimer {
    [self.lock lock];
    dispatch_resume(self.timer);
    self.status = XYTimerStatusResumed;
    [self.lock unlock];
}

- (void)cancerTimer {
    [self.lock lock];
    dispatch_source_cancel(self.timer);
    self.status = XYTimerStatusUnInit;
    [self.lock unlock];
}

- (void)stopTimer {
    
    if (self.status == XYTimerStatusUnInit) {
        return ;
    }
    
    //定时器在挂起状态是不能被释放的，必须要先恢复
    if (self.status == XYTimerStatusSusponded) {
        [self resumeTimer];
    }
    
    [self cancerTimer];
    
    self.timer = NULL;
}

#pragma mark - Dealloc
- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
