//
//  XYProtocolHookCondition.h
//  ProtocolHook
//
//  Created by 郭文超 on 2021/7/6.
//

#ifndef XYProtocolHookCondition_h
#define XYProtocolHookCondition_h

@protocol XYProtocolHookCondition <NSObject>

/// 判断是否需要拦截Protocol中的方法的调用 - 默认不拦截 - 如果需要，可扩展对指定方法的拦截
- (BOOL)isXYProtocolNeedHookMethodCall;

@end

#endif /* XYProtocolHookCondition_h */
