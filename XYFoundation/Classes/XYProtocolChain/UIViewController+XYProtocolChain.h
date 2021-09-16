//
//  UIViewController+XYProtocolChain.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 绑定一个协议，构造协议链，每次都会构造一个新的协议链
/// @param aProtocol 需要绑定的协议，默认所有方法都按协议响应链传递
/// @param firstResponder 协议的第一响应者，一般是协议的代理
/// 一般来说，这两个参数是一一对应的，尽量避免一个协议直接多个类使用的情况，
/// 响应者只处理消息，并不知道消息的发送者是谁，
/// 若多个发送者发送同一个消息，响应者是无法区分的，建议从命名上做好区分，更接近单一原则
typedef UIViewController *_Nonnull(^XYProtocolBind)(Protocol *aProtocol, NSObject *firstResponder);

/// 链接响应和对象
/// @param responder 下一个响应者，为指定的方法链接更多的响应者对象
/// @param aSelector 指定的方法
typedef UIViewController *_Nonnull(^XYResponderLink)(NSObject *responder, SEL aSelector);

/// 响应链构造结束的标识，仅仅表示构造过程的结束，构造的响应链会被保存起来
/// 从 bind - link ... link - close 是一个完整的响应链构造过程
/// 每次都从 bind 开始，以 close 结束
typedef void(^XYResponderChainClose)(void);

@interface UIViewController (XYProtocolChain)

/// 开始构造协议响应链
@property (nonatomic, copy) XYProtocolBind bind;

/// 链接下一响应者对象
@property (nonatomic, copy) XYResponderLink link;

/// 结束协议响应链构造
@property (nonatomic, copy) XYResponderChainClose close;

/// 遍历协议响应链结构
- (void)traverseProtocolChain;

@end
NS_ASSUME_NONNULL_END
