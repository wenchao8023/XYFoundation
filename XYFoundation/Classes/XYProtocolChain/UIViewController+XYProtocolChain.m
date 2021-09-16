//
//  UIViewController+XYProtocolChain.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import "UIViewController+XYProtocolChain.h"
#import "XYProtocolResponder.h"
#import <objc/runtime.h>
#import "XYProtocolHook.h"

typedef NSString * MapKeyType;
static MapKeyType mapKey(SEL sel) {
    return NSStringFromSelector(sel);
}

@interface UIViewController (XYProtocolChain)<xyProtocolHookInvocation>
@property (nonatomic, strong) XYProtocolResponderChain *protocolChain;
@property (nonatomic, strong) NSMapTable<Protocol *, XYProtocolResponderChain *> *chainMap;
@property (nonatomic, strong) NSMapTable<NSObject *, XYProtocolResponderChain *> *chainCacheMap;    // SEL 不是 objective-c 类型，不能做key，只能用字符串
@end


@implementation UIViewController (XYProtocolChain)

#pragma mark - xyProtocolHookInvocation
// 触发协议链
void xyProtocolChainInvocation(NSInvocation *anInvocation, SEL aSelector, SEL swizzleSel, XYProtocolResponder *responderChain) {
    XYProtocolResponder *responder = responderChain;
    while (responder) {
        xy_protocol_hook_invoke(anInvocation, responder.responder, aSelector, swizzleSel);
        responder = responder.nextResponder;
    }
}

- (void)xyProtocolHookInvocation:(NSInvocation *)anInvocation target:(id)target {
    SEL aSelector  = [anInvocation selector];
    SEL swizzleSel = xy_protocol_swizzle_selector(aSelector);
    if (!aSelector || !target) {
        return;
    }
    // 1. 从缓存中查找
    XYProtocolResponderChain *protocolChain = [self.chainCacheMap objectForKey:target];
    // 2. 从协议列表中查找 sel - protocol - protocolChain
    if (!protocolChain) {
        protocolChain = [self protocolChainWithTarget:target];
        if (protocolChain) {
            // 缓存查找结果
            [self.chainCacheMap setObject:protocolChain forKey:target];
        }
    }
    // 3. 查找失败：不调用协议链
    if (!protocolChain) {
        NSLog(@"protocolChain not found with selector : %@", mapKey(aSelector));
        return;
    }
    // 4. 第一响应者响应方法
    xy_protocol_hook_invoke(anInvocation, protocolChain.firstResponder,
                            aSelector, swizzleSel);
    // 5. 顺着方法响应链传递
    XYProtocolResponder *responder = [protocolChain responderForSelector:aSelector];
    if (responder) {
        xyProtocolChainInvocation(anInvocation, aSelector, swizzleSel, responder);
    }
}

#pragma mark - 构造协议链


- (XYProtocolBind)bind {
    __weak typeof(self) weakSelf = self;
    return ^(Protocol *aProtocol, NSObject *firstResponder){
        if (![firstResponder conformsToProtocol:aProtocol]) {
            NSLog(@"[bind err] %@ not conformsToProtocol %s", firstResponder, protocol_getName(aProtocol));
            return weakSelf;
        }
        XYProtocolResponderChain *protocolChain = [weakSelf.chainMap objectForKey:aProtocol];
        // 同一个类的方法只hook一次
        // 尽量避免第二个条件的成立（原因可参照 XYProtocolBind 的注释）
        if (!protocolChain || ![firstResponder isEqual:protocolChain.firstResponder]) {
            protocolChain = [[XYProtocolResponderChain alloc] initResponderChainWithProtocol:aProtocol
                                                                              firstResponder:firstResponder
                                                                                   invocator:weakSelf];
            [weakSelf.chainMap setObject:protocolChain forKey:aProtocol];
        }
        weakSelf.protocolChain = protocolChain;
        return weakSelf;
    };
}

- (XYResponderLink)link {
    if (!self.protocolChain) {
        NSLog(@"[link err] ProtocolChain is NULL, please bind a protocol first!");
        return NULL;
    }
    __weak typeof(self) weakSelf = self;
    return ^(NSObject *responder, SEL aSelector){
        if (![responder respondsToSelector:aSelector]) {
            NSLog(@"[link err] %@ not respondsToSelector %@", responder, NSStringFromSelector(aSelector));
            return weakSelf;
        }
        [weakSelf.protocolChain linkResponder:responder selector:aSelector];
        return weakSelf;
    };
}

- (XYResponderChainClose)close {
    __weak typeof(self) weakSelf = self;
    return ^(){
        weakSelf.protocolChain = nil;
    };
}

#pragma mark - set & get

const void *kXYProtocolChain            = &kXYProtocolChain;
const void *kXYProtocolChainMap         = &kXYProtocolChainMap;
const void *kXYProtocolChainCacheMap    = &kXYProtocolChainCacheMap;

- (XYProtocolResponder *)protocolChain {
    return objc_getAssociatedObject(self, kXYProtocolChain);
}

- (void)setProtocolChain:(XYProtocolResponder *)protocolChain {
    objc_setAssociatedObject(self, kXYProtocolChain, protocolChain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMapTable *)chainMap {
    if (!objc_getAssociatedObject(self, kXYProtocolChainMap)) {
        self.chainMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return objc_getAssociatedObject(self, kXYProtocolChainMap);
}

- (void)setChainMap:(NSMapTable *)chainMap {
    objc_setAssociatedObject(self, kXYProtocolChainMap, chainMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMapTable<NSString *,XYProtocolResponderChain *> *)chainCacheMap {
    if (!objc_getAssociatedObject(self, kXYProtocolChainCacheMap)) {
        self.chainCacheMap = [NSMapTable weakToWeakObjectsMapTable];
    }
    return objc_getAssociatedObject(self, kXYProtocolChainCacheMap);
}

- (void)setChainCacheMap:(NSMapTable<NSString *,XYProtocolResponderChain *> *)chainCacheMap {
    objc_setAssociatedObject(self, kXYProtocolChainCacheMap, chainCacheMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XYProtocolResponderChain *)protocolChainWithTarget:(id)target {
    __block XYProtocolResponderChain *protocolChain = nil;
    [[[self.chainMap objectEnumerator] allObjects] enumerateObjectsUsingBlock:^(XYProtocolResponderChain * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.firstResponder isEqual:target]) {
            *stop = YES;
            protocolChain = obj;
        }
    }];
    return protocolChain;
}

#pragma mark - 遍历响应链


- (void)traverseProtocolChain {
    __block NSString *desc = [NSString stringWithFormat:@"\n[Controller]\t【%@】\n", self.class];
    [[[self.chainMap keyEnumerator] allObjects] enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XYProtocolResponderChain *chain = [self.chainMap objectForKey:obj];
        desc = [desc stringByAppendingFormat:@"\t[ProtocolChain]\t<%s>\t【%@】\n", protocol_getName(obj), chain.firstResponder.class];
        desc = [desc stringByAppendingFormat:@"%@", chain];
    }];
    NSLog(@"%@", desc);
}


@end
