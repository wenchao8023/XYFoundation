//
//  UIViewController+XYProtocolChain.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 绑定一个协议，构造协议链，每次都会构造一个新的协议链
// 第一个参数：需要绑定的协议，默认所有方法都按协议响应链传递
// 第二个参数：可观察的对象，一般为代理者，也即协议的第一响应者
typedef UIViewController *_Nonnull(^XYProtocolBind)(Protocol *, NSObject *);

// 连接响应者对象，构造协议响应链
typedef UIViewController *_Nonnull(^XYResponderLink)(NSObject *);

// 指定协议链中某个方法是否需要按协议链传递
// 第一个参数：指定方法
// 第二个参数：是否需要按协议链传递，NO，表示不顺协议链传递，只回调给observable
typedef UIViewController *_Nonnull(^XYResponderFilter)(SEL, BOOL);

// 关闭响应链，构造协议链之后，关闭当前协议链
typedef void(^XYResponderChainClose)(void);

@interface UIViewController (XYProtocolChain)
@property (nonatomic, copy) XYProtocolBind bind;
@property (nonatomic, copy) XYResponderLink link;
@property (nonatomic, copy) XYResponderFilter filter;
@property (nonatomic, copy) XYResponderChainClose close;
- (void)traverseProtocolChain;
@end
NS_ASSUME_NONNULL_END
