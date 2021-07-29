//
//  XYProtocolResponder.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <Foundation/Foundation.h>
#import "XYProtocolHook.h"
NS_ASSUME_NONNULL_BEGIN

@interface XYProtocolResponder : NSObject;
// 构造响应者
- (instancetype)initResponder:(NSObject *)responder;
// 响应者
@property (nonatomic, weak, readonly) NSObject *responder;
// 下一响应者
@property (nonatomic, strong, nullable) XYProtocolResponder *nextResponder;
@end


@interface XYProtocolResponderChain : XYProtocolResponder
// 构造响应链
- (instancetype)initResponderChainWithProtocol:(Protocol *)protocol
                                    observable:(NSObject *)observable;
// 协议
@property (nonatomic, strong) Protocol *protocol;
// 协议hook类：hook observable 类
@property (nonatomic, strong, readonly) XYProtocolHook *protocolHook;
@end




NS_ASSUME_NONNULL_END
