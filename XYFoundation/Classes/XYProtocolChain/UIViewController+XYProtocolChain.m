//
//  UIViewController+XYProtocolChain.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import "UIViewController+XYProtocolChain.h"
#import "XYProtocolResponder.h"
#import <objc/runtime.h>
#import "XYMethodUtil.h"


@interface UIViewController (XYProtocolChain)<xyProtocolHookInvocation>
@property (nonatomic, strong) XYProtocolResponderChain *protocolChain;
@property (nonatomic, strong) NSMapTable<Protocol *, XYProtocolResponderChain *> *chainMap;
@property (nonatomic, strong) NSMapTable<NSString *, XYProtocolResponderChain *> *chainCacheMap;    // SEL 不是 objective-c 类型，不能做key，只能用字符串
@end


@implementation UIViewController (XYProtocolChain)

#pragma mark - xyProtocolHookInvocation
// 触发协议链
void xyProtocolChainInvocation(NSInvocation *anInvocation, id target, XYProtocolResponderChain *protocolChain) {
    SEL aSelector = [anInvocation selector];
    SEL swizzleSel = NSSelectorFromString([xyProtocolHookPrefix stringByAppendingString:NSStringFromSelector(aSelector)]);
    XYProtocolResponder *responder = protocolChain.nextResponder;
    while (responder) {
        xy_protocol_hook_invoke(anInvocation, responder.responder, aSelector, swizzleSel);
        responder = responder.nextResponder;
    }
}

- (void)xyProtocolHookInvocation:(NSInvocation *)anInvocation target:(id)target {
    NSLog(@"\n%s", __func__);
    SEL aSelector = [anInvocation selector];
    if (!aSelector) {
        return;
    }
    // 1. 从缓存中查找
    XYProtocolResponderChain *protocolChain = [self.chainCacheMap objectForKey:NSStringFromSelector(aSelector)];
    // 2. 从协议列表中查找 sel - protocol - protocolChain
    if (!protocolChain) {
        protocolChain = [self protocolChainWithSelector:aSelector];
    }
    // 3. 查找失败：不调用协议链
    if (!protocolChain) {
        NSLog(@"protocolChain not found with selector : %@", NSStringFromSelector(aSelector));
        return;
    }
    xyProtocolChainInvocation(anInvocation, target, protocolChain);
}

#pragma mark - 构造协议链


- (XYProtocolBind)bind {
    __weak typeof(self) weakSelf = self;
    return ^(Protocol *aProtocol, NSObject *observable){
        XYProtocolResponderChain *protocolChain = [weakSelf.chainMap objectForKey:aProtocol];
        if (!protocolChain) {   // 保证一个协议只hook一次
            protocolChain = [[XYProtocolResponderChain alloc] initResponderChainWithProtocol:aProtocol
                                                                               observable:observable];
            protocolChain.protocolHook.invocator = weakSelf;
            [weakSelf.chainMap setObject:protocolChain forKey:aProtocol];
        }
        protocolChain.nextResponder = nil;  // 释放上一次协议链，准备构造新的协议链
        weakSelf.protocolChain = protocolChain;
        return weakSelf;
    };
}

- (XYResponderLink)link {
    if (!self.protocolChain) {
        NSLog(@"ProtocolChain is NULL, please bind a protocol first!");
        return NULL;
    }
    __weak typeof(self) weakSelf = self;
    return ^(NSObject *responder){
        [weakSelf _linkResponder:responder];
        return weakSelf;
    };
}

- (XYResponderFilter)filter {
    if (!self.protocolChain) {
        NSLog(@"ProtocolChain is NULL, please bind a protocol first!");
        return NULL;
    }
    __weak typeof(self) weakSelf = self;
    return ^(SEL aSelector, BOOL isNeedResponderChain){
        
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
        self.chainCacheMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    return objc_getAssociatedObject(self, kXYProtocolChainCacheMap);
}

- (void)setChainCacheMap:(NSMapTable<NSString *,XYProtocolResponderChain *> *)chainCacheMap {
    objc_setAssociatedObject(self, kXYProtocolChainCacheMap, chainCacheMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XYProtocolResponderChain *)protocolChainWithSelector:(SEL)aSelector {
    __block XYProtocolResponderChain *protocolChain = nil;
    [[[self.chainMap keyEnumerator] allObjects] enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *targetSel = NSStringFromSelector(aSelector);
        __block BOOL findSel = NO;
        NSArray<NSString *> *methodArr = [XYMethodUtil getMethodListWithProtocol:obj];
        [methodArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:targetSel]) {
                findSel = YES;
                *stop = YES;
            }
        }];
        if (findSel) {
            protocolChain = [self.chainMap objectForKey:obj];
            [self.chainCacheMap setObject:protocolChain forKey:targetSel];
        }
    }];
    return protocolChain;
}

#pragma mark - 链接节点

- (UIViewController *)_linkResponder:(NSObject *)obj {
    XYProtocolResponder *responder = [[XYProtocolResponder alloc] initResponder:obj];
    // 头插法 - 构建链表 - 倒叙
//    responder.nextResponder = self.protocolChain.nextResponder;
//    self.protocolChain.nextResponder = responder;
    // 尾插发 - 构建链表 - 顺序
    XYProtocolResponder *tailResponder = self.protocolChain;
    while (tailResponder && tailResponder.nextResponder) {
        tailResponder = tailResponder.nextResponder;
    }
    if (tailResponder) {
        tailResponder.nextResponder = responder;
    }
    return self;
}


- (void)traverseProtocolChain {
    [[[self.chainMap keyEnumerator] allObjects] enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XYProtocolResponder *responder = [self.chainMap objectForKey:obj];
        while (responder) {
            NSLog(@"%@", responder);
            responder = responder.nextResponder;
        }
    }];
}


@end
