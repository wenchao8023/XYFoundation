//
//  UIViewController+XYProtocolSignal.h
//  Masonry
//
//  Created by 郭文超 on 2021/9/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 创建信号
// 1. create：hook observable 的指定协议列表，存在map，key:observable，value:protocol
// 2. subscribe：构建sel的响应链，
typedef UIViewController *_Nonnull(^XYProtocolSignalCreate)(NSObject * observable, Protocol *aProtocol);

// 订阅信号
typedef UIViewController *_Nonnull(^XYProtocolSignalSubscribe)(NSObject *observer, SEL aSel);

typedef UIViewController *_Nonnull(^XYProtocolSignalSubscribeAll)(NSObject *observer);

// 关闭响应链，构造协议链之后，关闭当前协议链
typedef void(^XYProtocolSignalClose)(void);

@interface UIViewController (XYProtocolSignal)
@property (nonatomic, copy) XYProtocolSignalCreate create;              ///< 创建信号源
@property (nonatomic, copy) XYProtocolSignalSubscribe subscribe;        ///< 订阅单个方法
@property (nonatomic, copy) XYProtocolSignalSubscribeAll subscribeAll;  ///< 订阅协议中的所有方法
@property (nonatomic, copy) XYProtocolSignalClose close;                ///< 关闭本次订阅
@end

NS_ASSUME_NONNULL_END
