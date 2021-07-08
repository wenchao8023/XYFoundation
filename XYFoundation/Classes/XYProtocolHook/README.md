## 一、XYProtocolHook使用说明
XYProtocolHook可以拦截一个类给定协议的方法实现。

### 1.1 构造方法：
```
/// 初始化hook
/// @param hookObj 需要拦截的对象
/// @param protocols 需要拦截对象的指定协议列表 内部是copy
- (instancetype)initWithHookObj:(NSObject *)hookObj andProtocolList:(NSArray <Protocol *>*)protocols;
```
如何使用：在需要的地方，将类和需要hook的协议列表传过去就可以了
```
self.protocolHook = [[XYProtocolHook alloc] initWithHookObj:self.manager
                                                 andProtocolList:@[
                                                     @protocol(XYRoomDelegate),
                                                     @protocol(XYRoomUnUsedDelegate)
                                                 ]];
```

### 1.2 条件过滤
在业务代码，一般是hookObj类中，遵循协议
```
@protocol XYProtocolHookCondition <NSObject>

/// 判断是否需要拦截Protocol中的方法的调用 - 默认不拦截 - 如果需要，可扩展对指定方法的拦截
- (BOOL)isAISProtocolNeedHookMethodCall;

@end
```
根据具体的业务场景决定是否对给定协议列表中的方法进行拦截
```
- (BOOL)isXYProtocolNeedHookMethodCall {
    return num++ % 2;
}
```

## 二、XYProtocolHook方法交换原理
### 2.1 读取方法列表
1. 获取hookObj类的方法列表
```
- (NSArray *)getMethodList:(Class)aClass {
    unsigned int count;
    Method *methodList = class_copyMethodList(aClass, &count);
    
    NSMutableArray *methodArr = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        if (!methodName || !methodName.length) {
            continue;
        }
        [methodArr addObject:methodName];
    }
    
    free(methodList);
    
    return methodArr.copy;
}
```

2. 获取给定协议列表中的方法
```
// 获取协议的方法列表
- (NSArray *)getMethodListInProtocols:(NSArray<Protocol *>*)protocols {
    NSMutableArray *methodArr = [NSMutableArray array];
    [protocols enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *tempArr1 = [self getMethodListWithProtocol:obj isRequiredMethod:YES];
        NSArray *tempArr2 = [self getMethodListWithProtocol:obj isRequiredMethod:NO];
        [methodArr addObjectsFromArray:tempArr1];
        [methodArr addObjectsFromArray:tempArr2];
    }];
    return methodArr.copy;
}

// 获取指定协议的方法列表 - 是否是 required
- (NSArray *)getMethodListWithProtocol:(Protocol *)protocol isRequiredMethod:(BOOL)isRequiredMethod {
    unsigned int methodCount = 0;

    struct objc_method_description *methodList = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, YES, &methodCount);
    NSMutableArray *methods = [NSMutableArray arrayWithCapacity:methodCount];

    for (int i = 0; i < methodCount; i ++) {
        struct objc_method_description md = methodList[i];
        [methods addObject:NSStringFromSelector(md.name)];
    }
    free(methodList);

    return methods.copy;
}
```

3. 对于上面两个结果求`交集`，并将最后的结果保存在`originMethods`，这里存的方法就是需要hook的方法
```
NSArray *methodArrInObj = [self getMethodList:self.hookClass];
NSSet *methodSetInObj = [NSSet setWithArray:methodArrInObj];
NSLog(@"methodSetInObj -- %@", methodSetInObj);

NSArray *methodArrInProtocols = [self getMethodListInProtocols:self.protocols];
NSSet *methodSetInProtocols = [NSSet setWithArray:methodArrInProtocols];
NSLog(@"methodSetInProtocols -- %@", methodSetInProtocols);

NSMutableSet *methodSet = methodSetInObj.mutableCopy;
[methodSet intersectSet:methodSetInProtocols];
NSLog(@"methodSet -- %@", methodSet);
```

## 2.2 交换hook方法：swizzleMethodInNeedHook

```
[self.originMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
    SEL srcSel     = NSSelectorFromString(obj);
    SEL swizzleSel = NSSelectorFromString([xyProtocolHookPrefix stringByAppendingString:obj]);
    Method srcMethod = class_getInstanceMethod(srcClass, srcSel);
    Method swizzleMethod = [self addSwizzledMethod:swizzleSel withSrcSel:srcSel toClass:srcClass];
    [self swizzleInstanceMethodWithSrcClass:srcClass srcMethod:srcMethod swizzledMethod:swizzleMethod];
}];
```

1. 给hookObj的类，添加一个相同签名的方法，
  - 新方法前缀为：`xyProtocolHookPrefix`；
  - 新方法实现伪：`NULL`；
2. 使用新方法交换旧方法；
3. 新方法的实现设置为 `NULL` 的原因，确保在调用旧方法的时候，最后会走到`转发流程`。

### 2.3 交换forwardInvocation方法：swizzleForwardInvocation
```
- (void)swizzleForwardInvocation {
    Class srcClass = self.hookClass;
    Method srcMethod = class_getInstanceMethod(srcClass, @selector(forwardInvocation:));
    Method swizzleMethod = class_getInstanceMethod(object_getClass(self), @selector(xy_protocol_hook_forwardInvocation:));
    self.addForwardInvocation = [self swizzleInstanceMethodWithSrcClass:srcClass srcMethod:srcMethod swizzledMethod:swizzleMethod];
    NSLog(@"addForwardInvocation ：%d", self.addForwardInvocation);
}
```
1. `forwardInvocation:`：方法是弗雷德方法，是不能直接被交换的，否则会影响其他地方的逻辑；
2. `forwardInvocation:`：方法可能在 hookObj 里面就实现了，也有可能未实现；

**hookObj里面实现了`forwardInvocation:`方法**

使用`xy_protocol_hook_forwardInvocation:`犯法替换 hookObj 里面的`forwardInvocation:`方法

**hookObj里面未实现`forwardInvocation:`方法**

1. 动态给 hookObj 添加`forwardInvocation:`方法，并用`addForwardInvocation`记录是否添加成功；
2. 使用`xy_protocol_hook_forwardInvocation:`方法替换hookObj里面的`forwardInvocation:`方法

**`xy_protocol_hook_forwardInvocation:`**实现逻辑
> 在这个类里面 `po self`，结果是 `hookObj`

1. 交换后的旧方法实现为 NULL，所以会走到消息转发流程里面；
2. 根据方法名找到动态生产的新方法；
3. 根据`<XYProtocolHookCondition>`协议决定是否对方法调用拦截；
4. 拦截：直接return，不做任何处理；
5. 不拦截：调用交换后的方法（方法实现是旧方法的实现），以调回原来的方法；

```
- (void)xy_protocol_hook_forwardInvocation:(NSInvocation *)anInvocation {
    SEL aSelector = [anInvocation selector];
    SEL swizzleSel = NSSelectorFromString([xyProtocolHookPrefix stringByAppendingString:NSStringFromSelector(aSelector)]);
    
    if ([self respondsToSelector:swizzleSel]) {
        if ([self respondsToSelector:@selector(isXYProtocolNeedHookMethodCall)]) {
            BOOL isNeedHook = [(id<XYProtocolHookCondition>)self isXYProtocolNeedHookMethodCall];
            if (isNeedHook) {
                return;
            }
        }
        // 执行交互方法，调回原方法
        anInvocation.selector = swizzleSel;
        [anInvocation invokeWithTarget:self];
    } else if ([self respondsToSelector:aSelector]) {
        [anInvocation invokeWithTarget:self];
    } else {
        NSString *desc = [NSString stringWithFormat:@"！！！！！！方法未实现%@ -- %@", self, NSStringFromSelector(aSelector)];
        NSLog(@"%@", desc);
//        NSAssert(0, desc);
    }
}
```

## 三、XYProtocolHook方法恢复原理

### 3.1 恢复 hook 方法：recoverMethodInNeedHook
动态添加方法是比较耗费资源的操作，所以在新方法添加成功之后，就不从类的方法列表中移除，如果下次还需要交换的时候，可以直接交换，不需要再添加方法。
这一步只做了一件事：`将新方法和旧方法再次交换，还原方法本身`
```
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
```

### 3.2 恢复forwardInvocation 方法：recoverForwardInvocation

对于`forwardInvocation:`方法的恢复，同样需要遵循上面交换时的两个状态，`forwardInvocation:`方法可能在 hookObj 里面就实现了，也有可能未实现；根据变量`addForwardInvocation`来判断：
- YES：表示添加成功，说明未实现`forwardInvocation:`方法，需要将实现指回给父类；
- NO ：表示添加失败，说明已实现`forwardInvocation:`方法，直接交换新旧方法即可；

```
if (self.addForwardInvocation) {
    Method superMethod = class_getInstanceMethod(class_getSuperclass(srcClass), @selector(forwardInvocation:));
    // 将 xy_protocol_hook_forwardInvocation 的实现指回给父类的 forwardInvocation
    class_replaceMethod(srcClass,
                        method_getName(swizzleMethod),
                        method_getImplementation(superMethod),
                        method_getTypeEncoding(superMethod));
} else {
    [self swizzleInstanceMethodWithSrcClass:srcClass srcMethod:srcMethod swizzledMethod:swizzleMethod];
```

## 四、注意事项
### 4.1 XYProtocolHookCondition 协议
1. 在需要添加条件控制的类中，遵循`XYProtocolHookCondition`协议；
2. 实现`isXYProtocolNeedHookMethodCall`方法，方法接受 `BOOL` 类型的返回值。
3. 业务侧可以在这个方法中自行控制需要对哪些方法进行拦截；
4. 如果不实现这个方法，hook 是不会起作用的。

### 4.2 XYProtocolHook 对象的声明周期
1. 方法hook的有效期与`XYProtocolHook`对象的声明周期是强关联的，一旦`XYProtocolHook`对象被销毁，hook的方法会立即被还原。
2. 业务侧需要根据具体场景来管理`XYProtocolHook`对象的生命周期。
3. `XYProtocolHook`对象内部不会持有任何实例对象，不用考虑循环引用的问题。

---
[XYProtocolHook源码](https://github.com/wenchao8023/XYFoundation)

