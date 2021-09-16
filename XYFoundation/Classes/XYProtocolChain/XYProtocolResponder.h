//
//  XYProtocolResponder.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 方法响应者
@interface XYProtocolResponder : NSObject;

/// 构造响应者
- (instancetype)initResponder:(NSObject *)responder;

// 响应者
@property (nonatomic, weak, readonly) NSObject *responder;

// 下一响应者
@property (nonatomic, strong, nullable) XYProtocolResponder *nextResponder;

@end


/// 协议响应链
@protocol xyProtocolHookInvocation;
@interface XYProtocolResponderChain : NSObject

/// 构造协议响应链
/// @param protocol 指定的协议
/// @param firstResponder 协议的第一响应者
/// @param invocator 需要接受消息的对象
- (instancetype)initResponderChainWithProtocol:(Protocol *)protocol
                                    firstResponder:(NSObject *)firstResponder
                                     invocator:(id<xyProtocolHookInvocation> __weak)invocator;

// 第一响应者
@property (nonatomic, weak,  readonly) NSObject *firstResponder;

// 构建方法响应链
- (void)linkResponder:(NSObject *)responder selector:(SEL)selector;

// 获取方法响应链
- (XYProtocolResponder *)responderForSelector:(SEL)selector;

@end




NS_ASSUME_NONNULL_END
