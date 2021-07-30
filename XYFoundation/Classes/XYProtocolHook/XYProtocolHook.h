//
//  XYProtocolHook.h
//  ProtocolHook
//
//  Created by 郭文超 on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import <XYProtocolHookCondition.h>
NS_ASSUME_NONNULL_BEGIN


extern SEL  xy_protocol_swizzle_selector(SEL originSel);
extern void xy_protocol_hook_invoke(NSInvocation *anInvocation, id target, SEL originSel, SEL swizzleSel);

@interface XYProtocolHook : NSObject

@property (nonatomic, strong) id<xyProtocolHookInvocation> invocator;

/// 初始化hook
/// @param hookObj 需要拦截的对象
/// @param protocols 需要拦截对象的指定协议列表 内部是copy
- (instancetype)initWithHookObj:(NSObject *)hookObj andProtocolList:(NSArray <Protocol *>*)protocols;

@end

NS_ASSUME_NONNULL_END
