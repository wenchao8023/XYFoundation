//
//  XYProtocolResponder.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <Foundation/Foundation.h>
#import "XYProtocolHook.h"
NS_ASSUME_NONNULL_BEGIN

// 方法响应者
@interface XYProtocolResponder : NSObject;
- (instancetype)initResponder:(NSObject *)responder;

// 响应者
@property (nonatomic, weak, readonly) NSObject *responder;

// 下一响应者
@property (nonatomic, strong, nullable) XYProtocolResponder *nextResponder;

@end


/// 协议响应链
@interface XYProtocolResponderChain : NSObject
- (instancetype)initResponderChainWithProtocol:(Protocol *)protocol
                                    observable:(NSObject *)observable;

// 协议的遵循对象、变化源、第一响应者
@property (nonatomic, weak,  readonly) NSObject *observable;

// 协议
@property (nonatomic, strong, readonly) Protocol *protocol;

// 方法响应者
@property (nonatomic, strong, readonly) NSMapTable<NSString *, XYProtocolResponder *> *responderMap;

// 协议hook类：hook observable 类
@property (nonatomic, strong, readonly) XYProtocolHook *protocolHook;

// 构建方法响应链
- (void)linkResponder:(NSObject *)responder selector:(SEL)selector;

// 获取方法响应链
- (XYProtocolResponder *)resonderForSelector:(SEL)selector;

@end




NS_ASSUME_NONNULL_END
