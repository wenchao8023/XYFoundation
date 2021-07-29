//
//  XYProtocolHook.m
//  ProtocolHook
//
//  Created by 郭文超 on 2021/7/5.
//

#import "XYProtocolHook.h"
#import <objc/runtime.h>
#import "XYMethodUtil.h"

NSString * xyProtocolHookPrefix = @"xy_xxxxxx_protocol_hook_";

@interface XYProtocolHook()
@property (nonatomic, weak) NSObject *hookObj;                  ///< 记录对象类型，用于方法交互和还原
@property (nonatomic, strong) Class hookClass;                  ///< 记录对象类型，用于方法交互和还原
@property (nonatomic, copy) NSArray<Protocol *> *protocols;     ///< 记录协议列表
@property (nonatomic, strong) NSSet<NSString *> *originMethods; ///< 记录最终需要hook的方法列表

///< 记录是否成功给hookClass添加该方法，如果添加了，还原方法之后需要将该方法从hookClass中移除
@property (nonatomic, assign) BOOL addForwardInvocation;
@end

@implementation XYProtocolHook

#pragma mark - ForwardInvocation
// 这个方法中的 self 不再是 XYProtocolHook
// 而是 self.hookObj
const void * kXYProtocolInvocator = &kXYProtocolInvocator;

- (void)setInvocator:(id<xyProtocolHookInvocation>)invocator {
    if (!self.hookObj) {
        return;
    }
    __weak typeof(invocator) weakInvocator = invocator;
    objc_setAssociatedObject(self.hookObj, kXYProtocolInvocator,
                             weakInvocator, OBJC_ASSOCIATION_ASSIGN);
}

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
    SEL swizzleSel = NSSelectorFromString([xyProtocolHookPrefix stringByAppendingString:NSStringFromSelector(aSelector)]);
    xy_protocol_hook_invoke(anInvocation, self, aSelector, swizzleSel);
}

#pragma mark -
- (NSString *)description {
    return [NSString stringWithFormat:@"\n>>>>hookClass : %@\n>>>>hookProtocols : %@\n>>>>hookMethods : %@",
            self.hookClass, self.protocols, self.originMethods];
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
    NSLog(@"%s", __func__);
    
    [self swizzleMethodInNeedHook];
    
    [self swizzleForwardInvocation];
}

- (void)recoverHookProtocols {
    if (![self checkIsNeedRecover]) {
        return;
    }
    NSLog(@"%s", __func__);
    [self recoverMethodInNeedHook];
    
    [self recoverForwardInvocation];
}


- (BOOL)checkIsNeedSwizzle {
    if (!self.hookClass) {
        return NO;
    }
    
    if (!self.protocols || !self.protocols.count) {
        return NO;
    }
    
    if (!self.originMethods.count) {
        return NO;
    }
    return YES;
}

- (BOOL)checkIsNeedRecover {
    return [self checkIsNeedSwizzle];
}

#pragma mark - Runtime

#pragma mark -- Runtime: Recover
// 恢复原来的方法，对于动态添加过的方法就不再删除，避免下次使用时又要重复添加
- (void)recoverMethodInNeedHook {
    Class srcClass = self.hookClass;
    [self.originMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        SEL srcSel      = NSSelectorFromString([xyProtocolHookPrefix stringByAppendingString:obj]);
        SEL swizzleSel  = NSSelectorFromString(obj);
        Method srcMethod = class_getInstanceMethod(srcClass, srcSel);
        Method swizzleMethod = [self addSwizzledMethod:swizzleSel withSrcSel:srcSel toClass:srcClass];
        [self swizzleInstanceMethodWithSrcClass:srcClass srcMethod:srcMethod swizzledMethod:swizzleMethod];
    }];
}

- (void)recoverForwardInvocation {
    Class  srcClass      = self.hookClass;
    Method swizzleMethod = class_getInstanceMethod(srcClass, @selector(forwardInvocation:));
    Method srcMethod     = class_getInstanceMethod(object_getClass(self), @selector(xy_protocol_hook_forwardInvocation:));
    if (self.addForwardInvocation) {
        Method superMethod = class_getInstanceMethod(class_getSuperclass(srcClass), @selector(forwardInvocation:));
        // 将 xy_protocol_hook_forwardInvocation 的实现指回给父类的 forwardInvocation
        class_replaceMethod(srcClass,
                            method_getName(swizzleMethod),
                            method_getImplementation(superMethod),
                            method_getTypeEncoding(superMethod));
    } else {
        [self swizzleInstanceMethodWithSrcClass:srcClass srcMethod:srcMethod swizzledMethod:swizzleMethod];
    }
}


#pragma mark -- Runtime: Swizzle
// 交换需要hook的方法
- (void)swizzleMethodInNeedHook {
    Class srcClass = self.hookClass;
    [self.originMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        SEL srcSel     = NSSelectorFromString(obj);
        SEL swizzleSel = NSSelectorFromString([xyProtocolHookPrefix stringByAppendingString:obj]);
        Method srcMethod = class_getInstanceMethod(srcClass, srcSel);
        Method swizzleMethod = [self addSwizzledMethod:swizzleSel withSrcSel:srcSel toClass:srcClass];
        [self swizzleInstanceMethodWithSrcClass:srcClass srcMethod:srcMethod swizzledMethod:swizzleMethod];
    }];
}

// 交换慢速转发流程方法
- (void)swizzleForwardInvocation {
    Class srcClass = self.hookClass;
    Method srcMethod = class_getInstanceMethod(srcClass, @selector(forwardInvocation:));
    Method swizzleMethod = class_getInstanceMethod(object_getClass(self), @selector(xy_protocol_hook_forwardInvocation:));
    self.addForwardInvocation = [self swizzleInstanceMethodWithSrcClass:srcClass srcMethod:srcMethod swizzledMethod:swizzleMethod];
    NSLog(@"addForwardInvocation ：%d", self.addForwardInvocation);
}

#pragma mark --

// 将需要拦截的方法实现 转发到一个未实现方法 以触发慢速转发流程
- (Method)addSwizzledMethod:(SEL)swizzledSel withSrcSel:(SEL)srcSel toClass:(Class)aClass {
    IMP srcIMP = class_getMethodImplementation(aClass, swizzledSel);
    Method srcMethod = class_getClassMethod(aClass, srcSel);
    const char * types = method_getTypeEncoding(srcMethod);
    class_addMethod(aClass, swizzledSel, srcIMP, types);
    return class_getInstanceMethod(aClass, swizzledSel);
}

// 方法交换
- (BOOL)swizzleInstanceMethodWithSrcClass:(Class)srcClass
                                srcMethod:(Method)srcMethod
                           swizzledMethod:(Method)swizzledMethod{
    
    if (!srcClass || !srcMethod || !swizzledMethod) {
        return NO;
    }
    
    //加一层保护措施，如果添加成功，则表示该方法不存在于本类，而是存在于父类中，不能交换父类的方法,否则父类的对象调用该方法会crash；添加失败则表示本类存在该方法
    BOOL addMethod = class_addMethod(srcClass,
                                     method_getName(srcMethod),
                                     method_getImplementation(swizzledMethod),
                                     method_getTypeEncoding(swizzledMethod));
    if (addMethod){
        //添加方法实现IMP成功后，再将原有的实现替换到swizzledMethod方法上，从而实现方法的交换，并且未影响到父类方法的实现
        class_replaceMethod(srcClass,
                            method_getName(swizzledMethod),
                            method_getImplementation(srcMethod),
                            method_getTypeEncoding(srcMethod));
    } else {
        //添加失败，调用交互两个方法的实现
        method_exchangeImplementations(srcMethod, swizzledMethod);
    }
    
    return addMethod;
}


#pragma mark -- Runtime: Getter

// 原始方法列表（对象方法列表+协议方法列表 => 交集）
- (NSSet<NSString *> *)originMethods {
    if (!_originMethods) {
        NSArray *methodArrInObj = [XYMethodUtil getMethodList:self.hookClass];
        NSSet *methodSetInObj = [NSSet setWithArray:methodArrInObj];
        NSLog(@"methodSetInObj -- %@", methodSetInObj);
        
        NSArray *methodArrInProtocols = [XYMethodUtil getMethodListInProtocols:self.protocols];
        NSSet *methodSetInProtocols = [NSSet setWithArray:methodArrInProtocols];
        NSLog(@"methodSetInProtocols -- %@", methodSetInProtocols);
        
        NSMutableSet *methodSet = methodSetInObj.mutableCopy;
        [methodSet intersectSet:methodSetInProtocols];
        NSLog(@"methodSet -- %@", methodSet);
        
        _originMethods = methodSet.copy;
    }
    return _originMethods;
}

@end
