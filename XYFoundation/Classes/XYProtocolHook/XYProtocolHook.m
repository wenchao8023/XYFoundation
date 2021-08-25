//
//  XYProtocolHook.m
//  ProtocolHook
//
//  Created by 郭文超 on 2021/7/5.
//

#import "XYProtocolHook.h"
#import <objc/runtime.h>
#import "XYMethodUtil.h"
#import "XYSelectorUtil.h"
#import "XYProtocolHookMap.h"

@interface XYProtocolHook()
@property (nonatomic, weak) NSObject *hookObj;                  ///< 记录对象类型，用于方法交互和还原
@property (nonatomic, strong) Class hookClass;                  ///< 记录对象类型，用于方法交互和还原
@property (nonatomic, copy) NSArray<Protocol *> *protocols;     ///< 记录原始协议列表
@property (nonatomic, assign) BOOL containForwardInvocation;    ///< 记录当前类是否包含 forwardInvocation 方法
///< 记录最终需要hook的协议和方法列表     key：protocol，value：方法列表
@property (nonatomic, strong) NSMapTable<Protocol *, NSSet<NSString *> *> *originMethodMap;
@end

@implementation XYProtocolHook


#pragma mark - ForwardInvocation
// 这个方法中的 self 不再是 XYProtocolHook
// 而是 self.hookObj
const void * kXYProtocolInvocator = &kXYProtocolInvocator;

void xy_protocol_hook_invoke(NSInvocation *anInvocation, id target, SEL originSel, SEL swizzleSel) {
    if (!target || !anInvocation || !originSel || !swizzleSel) {
        return;
    }
    if ([target respondsToSelector:swizzleSel]) {
        anInvocation.selector = swizzleSel;
        [anInvocation invokeWithTarget:target];
    } else if ([target respondsToSelector:originSel]) {
        anInvocation.selector = originSel;
        [anInvocation invokeWithTarget:target];
    } else {
        NSString *desc = [NSString stringWithFormat:@"%@ -- %@ -- 方法未实现",
                          [target class], NSStringFromSelector(originSel)];
        NSLog(@"%@", desc);
    }
}

- (void)setInvocator:(id<xyProtocolHookInvocation>)invocator {
    if (!self.hookObj) {
        return;
    }
    __weak typeof(invocator) weakInvocator = invocator;
    objc_setAssociatedObject(self.hookObj, kXYProtocolInvocator,
                             weakInvocator, OBJC_ASSOCIATION_ASSIGN);
}

- (void)xy_protocol_hook_forwardInvocation:(NSInvocation *)anInvocation {
    // 代理是否处理消息转发
    id<xyProtocolHookInvocation> invocator = objc_getAssociatedObject(self, kXYProtocolInvocator);
    if (invocator && [invocator respondsToSelector:@selector(xyProtocolHookInvocation:target:)]) {
        [invocator xyProtocolHookInvocation:anInvocation target:self];
        return;
    }
    // 是否需要拦截消息转发
    if ([self respondsToSelector:@selector(isXYProtocolNeedHookMethodCall)]) {
        BOOL isNeedHook = [(id<XYProtocolHookCondition>)self isXYProtocolNeedHookMethodCall];
        if (isNeedHook) {
            return;
        }
    }
    // 调用方法
    SEL aSelector = [anInvocation selector];
    SEL swizzleSel = xy_swizzle_selector_from_selector(aSelector);
    xy_protocol_hook_invoke(anInvocation, self, aSelector, swizzleSel);
}

#pragma mark -
- (NSString *)description {
    return [NSString stringWithFormat:@"\n[xyprotocolhook]--[description]----%@----%@", self.hookClass, self.originMethodMap];
}
- (void)dealloc {
    NSLog(@"%s", __func__);
    [self recoverHookProtocols];
}

- (instancetype)initWithHookObj:(NSObject *)hookObj andProtocolList:(NSArray<Protocol *> *)protocols {
    if (!hookObj || !protocols || !protocols.count) {
        return nil;
    }
    self = [super init];
    if (self) {
        _hookObj   = hookObj;
        _hookClass = object_getClass(hookObj);
        _protocols = protocols;
        [self startHookProtocols];
    }
    return self;
}

- (void)startHookProtocols {
    if (![self checkIsNeedSwizzle]) {
        return;
    }

    NSLog(@"[xyprotocolhook]--[hook]---->>>>>>");
    
    [self swizzleMethodInNeedHook];
    
    [self swizzleForwardInvocation];
    
//    NSLog(@"%@\n[xyprotocolhook]--[hook]----<<<<<<", [XYMethodUtil getMethodList:self.hookClass]);
}

- (void)recoverHookProtocols {
    if (![self checkIsNeedRecover]) {
        return;
    }
    
    NSLog(@"[xyprotocolhook]--[recover]---->>>>>>");
    
    [self recoverMethodInNeedHook];
    
    [self recoverForwardInvocation];
    
//    NSLog(@"%@\n[xyprotocolhook]--[recover]----<<<<<<", [XYMethodUtil getMethodList:self.hookClass]);
}


- (BOOL)checkIsNeedSwizzle {
    if (!self.hookClass) {
        return NO;
    }
    
    if (!self.protocols || !self.protocols.count) {
        return NO;
    }
    
    if (!self.originMethodMap.count) {
        return NO;
    }
    return YES;
}

- (BOOL)checkIsNeedRecover {
    return [self checkIsNeedSwizzle];
}

#pragma mark - Runtime

#pragma mark -- Runtime: Swizzle
// 交换需要hook的方法
- (void)swizzleMethodInNeedHook {
    [[[self.originMethodMap keyEnumerator] allObjects] enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSet <NSString *> *methodSet = [self.originMethodMap objectForKey:obj];
        // 保证一个 class 的 一个 protocol 整个工程下只会 hook 一次，recover 还原之后才可再次 hook
        if (![XYProtocolHookMap.shareHookMap isProtocolHooked:self.hookClass protocol:obj]) {
            [methodSet enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                [self _swizzelMethodWithOriginSelector:obj];
            }];
            
            NSLog(@"[xyprotocolhook]--[swizzle]----%@----%@----%@", self.hookClass, xy_prototocol_name(obj), methodSet);
        }
        // 记录 class 的 protocol 已经 hook 次数
        [XYProtocolHookMap.shareHookMap retainHookClass:self.hookClass protocol:obj];
    }];
}

- (void)_swizzelMethodWithOriginSelector:(NSString *)selStr {
    SEL srcSel     = xy_selector_from_string(selStr);
    SEL swizzleSel = xy_swizzle_selector_from_string(selStr);
    // 1. 获取原始方法
    Method srcMethod = xy_class_getInstanceMethod(self.hookClass, srcSel);
    // 2. 构造swizzle方法
    Method swizzleMethod = xy_method_get_swizzleMethod(swizzleSel, srcSel, self.hookClass);
    // 3. 交换两个方法实现
    xy_method_exchangeImplementations(srcMethod, swizzleMethod);
}

// 设置慢速转发流程方法
- (void)swizzleForwardInvocation {
    Method srcMethod = xy_class_getInstanceMethod(self.hookClass, @selector(forwardInvocation:));
    Method swizzleMethod = xy_class_getInstanceMethod(object_getClass(self), @selector(xy_protocol_hook_forwardInvocation:));
    
    IMP forwardInvocationIMP = NULL;
    IMP swizzelIMP = xy_method_getImplementation(swizzleMethod);
    if (self.containForwardInvocation) {
        forwardInvocationIMP = xy_method_getImplementation(srcMethod);
        xy_method_setImplementation(srcMethod, swizzelIMP);
        NSLog(@"[xyprotocolhook]--[swizzleForwardInvocation]----%@----containForwardInvocation", self.hookClass);
    } else {
        xy_class_addMethod(self.hookClass,
                           method_getName(srcMethod),
                           swizzelIMP,
                           method_getTypeEncoding(srcMethod));
        // 最后要还原指向给父类，所以需要保存父类的IMP
        Method superMethod = xy_class_getInstanceMethod(class_getSuperclass(self.hookClass), @selector(forwardInvocation:));
        forwardInvocationIMP = xy_method_getImplementation(superMethod);
        NSLog(@"[xyprotocolhook]--[swizzleForwardInvocation]----%@----not containForwardInvocation", self.hookClass);
    }
    
    if (![XYProtocolHookMap.shareHookMap isProtocolHookClassNeedRecover:self.hookClass] &&
        ![XYProtocolHookMap.shareHookMap isForwardInvocationIMPRecorded:self.hookClass]) {
        [XYProtocolHookMap.shareHookMap recordHookClass:self.hookClass forwardInvocationIMP:forwardInvocationIMP];
        NSLog(@"[xyprotocolhook]--[recordHookClass]----%@", self.hookClass);
    }
}

#pragma mark -- Runtime: Recover
// 恢复原来的方法，对于动态添加过的方法就不再删除，避免下次使用时又要重复添加
- (void)recoverMethodInNeedHook {
    [[[self.originMethodMap keyEnumerator] allObjects] enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSet <NSString *> *methodSet = [self.originMethodMap objectForKey:obj];
        [XYProtocolHookMap.shareHookMap releaseHookClass:self.hookClass protocol:obj];
        if ([XYProtocolHookMap.shareHookMap isProtocolNeedDealloc:self.hookClass protocol:obj]) {
            [methodSet enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                [self _recoverMethodWithOriginSelector:obj];
            }];
            NSLog(@"[xyprotocolhook]--[recover]----%@----%@----%@", self.hookClass, xy_prototocol_name(obj), methodSet);
        }
    }];
}

- (void)_recoverMethodWithOriginSelector:(NSString *)selStr {
    SEL srcSel     = xy_selector_from_string(selStr);
    SEL swizzleSel = xy_swizzle_selector_from_string(selStr);
    // 1. 获取原始方法
    Method srcMethod = xy_class_getInstanceMethod(self.hookClass, srcSel);
    // 2. 构造swizzle方法
    Method swizzleMethod = xy_method_get_swizzleMethod(swizzleSel, srcSel, self.hookClass);
    // 3. 交换两个方法实现
    xy_method_exchangeImplementations(srcMethod, swizzleMethod);
}

- (void)recoverForwardInvocation {
    if ([XYProtocolHookMap.shareHookMap isProtocolHookClassNeedRecover:self.hookClass]) {
        if (![XYProtocolHookMap.shareHookMap isForwardInvocationIMPRecorded:self.hookClass]) {
            NSLog(@"[xyprotocolhook]--[error]----%@----isForwardInvocationIMPRecorded", self.hookClass);
        }
        
        IMP forwardInvocationIMP = [XYProtocolHookMap.shareHookMap forwardInvocationIMPForHookClass:self.hookClass];
        Method srcMethod = xy_class_getInstanceMethod(self.hookClass, @selector(forwardInvocation:));
        xy_method_setImplementation(srcMethod, forwardInvocationIMP);
        [XYProtocolHookMap.shareHookMap discardHookClass:self.hookClass];
        NSLog(@"[xyprotocolhook]--[recoverForwardInvocation]----%@", self.hookClass);
    }
}


#pragma mark - xy_runtime

Method xy_method_get_swizzleMethod(SEL swizzleSel, SEL originSel, Class aClass) {
    Method method = class_getInstanceMethod(aClass, swizzleSel);
    if (method) {
        return method;
    }
    return xy_method_add_swizzleMethod(swizzleSel, originSel, aClass);
}

Method xy_method_add_swizzleMethod(SEL swizzleSel, SEL originSel, Class aClass) {
    // 1. 获取swizzledSel的IMP：libobjc.A.dylib`_objc_msgForward
    IMP swizzleIMP = class_getMethodImplementation(aClass, swizzleSel);
    // 2. 获取原始方法的签名
    Method srcMethod = class_getClassMethod(aClass, originSel);
    const char * types = method_getTypeEncoding(srcMethod);
    // 3. 添加新方法
    class_addMethod(aClass, swizzleSel, swizzleIMP, types);
    // 4. 返回刚添加的方法
    return class_getInstanceMethod(aClass, swizzleSel);
}

Method xy_class_getInstanceMethod(Class aClass, SEL aSelector) {
    return class_getInstanceMethod(aClass, aSelector);
}

BOOL xy_class_addMethod(Class cls, SEL name, IMP imp, const char * types) {
    return class_addMethod(cls, name, imp, types);
}

IMP xy_method_getImplementation(Method aMethod) {
    return method_getImplementation(aMethod);
}

IMP xy_method_setImplementation(Method aMethod, IMP aImp) {
    return method_setImplementation(aMethod, aImp);
}

void xy_method_exchangeImplementations(Method m1, Method m2) {
    IMP imp1 = method_getImplementation(m1);
    IMP imp2 = method_getImplementation(m2);
    method_exchangeImplementations(m1, m2);
    IMP imp3 = method_getImplementation(m1);
    IMP imp4 = method_getImplementation(m2);
//    NSLog(@"xy_method_exchangeImplementations");
}

NSString *xy_prototocol_name(Protocol *protocol){
    const char * cName = protocol_getName(protocol);
    return [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
}


#pragma mark -- Runtime: Getter

// 原始方法列表（对象方法列表+协议方法列表 => 交集）
- (NSMapTable<Protocol *,NSSet<NSString *> *> *)originMethodMap {
    if (!_originMethodMap) {
        NSMapTable<Protocol *,NSSet<NSString *> *>  *originMethodMap = [NSMapTable strongToStrongObjectsMapTable];
        
        // 对象已实现的方法
        NSArray *methodArrInObj = [XYMethodUtil getMethodList:self.hookClass];
        NSSet *methodSetInObj = [NSSet setWithArray:methodArrInObj];
        
        self.containForwardInvocation = [methodSetInObj containsObject:NSStringFromSelector(@selector(forwardInvocation:))];
        NSLog(@"[xyprotocolhook]--[containForwardInvocation]----%@----%d", self.hookClass, self.containForwardInvocation);
        
        // 遍历协议列表中定义的方法
        [self.protocols enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *methodArrInProtocol = [XYMethodUtil getMethodListWithProtocol:obj];
            // 对协议中的方法与对象实现过得方法求交集
            NSMutableSet *methodSetInProtocol = [NSMutableSet setWithArray:methodArrInProtocol];
            [methodSetInProtocol intersectSet:methodSetInObj];
            if (methodSetInProtocol.count) {
                [originMethodMap setObject:methodSetInProtocol.copy forKey:obj];
                NSLog(@"[xyprotocolhook]--[setObject]----%@----%@----%@", self.hookClass, xy_prototocol_name(obj), methodSetInProtocol);
            }
        }];
        
        _originMethodMap = originMethodMap;
    }
    return _originMethodMap;
}

@end
