//
//  XYProtocolHookMap.m
//  XYFoundation
//
//  Created by 郭文超 on 2021/8/20.
//

#import "XYProtocolHookMap.h"
#import <objc/runtime.h>
#import "XYSelectorUtil.h"

NSString* xy_map_protocol_name(Protocol *protocol) {
    const char * cName = protocol_getName(protocol);
    return [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
}

@interface XYProtocolHookCount : NSObject
@property (nonatomic, assign, readonly) NSUInteger hookCount;
@property (nonatomic, strong, readonly) Protocol *protocol;
@end

@implementation XYProtocolHookCount
@synthesize hookCount=_hookCount;
@synthesize protocol=_protocol;

- (instancetype)initWithProtocol:(Protocol *)protocol {
    if (self) {
        _protocol = protocol;
        _hookCount = 0;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    XYProtocolHookCount *hookCount = (XYProtocolHookCount *)object;
    return (self.protocol == hookCount.protocol);
}

- (void)retainCount:(Protocol *)protocol {
    if (self.protocol != protocol) {
        return;
    }
    _hookCount += 1;
}

- (void)releaseCount:(Protocol *)protocol {
    if (self.protocol != protocol) {
        return;
    }
    _hookCount -= 1;
}

@end


@interface XYProtocolHookEntry : NSObject
@property (nonatomic, strong) Class hookClass;
@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, strong) NSMapTable<Protocol *, XYProtocolHookCount *> *protocolMap;
@end


@implementation XYProtocolHookEntry
- (instancetype)initWithHookClass:(Class)hookClass {
    self = [super init];
    if (self) {
        _hookClass = hookClass;
        _lock = dispatch_semaphore_create(1);
        _protocolMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)retainHookCount:(Protocol *)protocol {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    XYProtocolHookCount *hookCount = [self.protocolMap objectForKey:protocol];
    if (!hookCount) {
        hookCount = [[XYProtocolHookCount alloc] initWithProtocol:protocol];
        [self.protocolMap setObject:hookCount forKey:protocol];
    }
    [hookCount retainCount:protocol];
    dispatch_semaphore_signal(self.lock);
    NSLog(@"[XYProtocolHookEntry]----%@----%@----retainHookCount:%ld", self.hookClass, xy_map_protocol_name(protocol), hookCount.hookCount);
}

- (void)releaseHookCount:(Protocol *)protocol {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    XYProtocolHookCount *hookCount = [self.protocolMap objectForKey:protocol];
    if (!hookCount) {
        dispatch_semaphore_signal(self.lock);
        return;
    }
    [hookCount releaseCount:protocol];
    if (hookCount.hookCount == 0) {
        [self.protocolMap removeObjectForKey:protocol];
    }
    dispatch_semaphore_signal(self.lock);
    NSLog(@"[XYProtocolHookEntry]----%@----%@----releaseHookCount:%ld", self.hookClass, xy_map_protocol_name(protocol), hookCount.hookCount);
}

- (NSUInteger)hookProtocolCount:(Protocol *)protocol {
    XYProtocolHookCount *hookCount = [self.protocolMap objectForKey:protocol];
    if (!hookCount) {
        return 0;
    }
    return hookCount.hookCount;
}

- (BOOL)isProtocolHookEntryNeedDealloc {
    return self.protocolMap.count == 0;
}

@end

// 记录 class 的 forwardInvocation 的实现
@interface XYProtocolHookForwardInvocationEntry : NSObject
@property (nonatomic, strong, readonly) Class hookClass;
@property (nonatomic, readonly) IMP forwardInvocationIMP;
@end

@implementation XYProtocolHookForwardInvocationEntry
- (instancetype)initWithHookClass:(Class)hookClass forwardInvocationIMP:(IMP)forwardInvocationIMP {
    self = [super init];
    if (self) {
        _hookClass = hookClass;
        _forwardInvocationIMP = forwardInvocationIMP;
    }
    return self;
}

@end


static XYProtocolHookMap *protocolHookMap = nil;

@interface XYProtocolHookMap()
///< 记录全局类的协议
@property (nonatomic, strong) NSMapTable<Class, XYProtocolHookEntry *> *globalHookClassProtocolMap;
///< 记录全局类的IMP
@property (nonatomic, strong) NSMapTable<Class, XYProtocolHookForwardInvocationEntry *> *globalHookClassIMPMap;
@property (nonatomic, strong) dispatch_semaphore_t protocolLock;
@property (nonatomic, strong) dispatch_semaphore_t impLock;
@end


@implementation XYProtocolHookMap
+ (instancetype)shareHookMap {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protocolHookMap = [[XYProtocolHookMap alloc] init];
        protocolHookMap.globalHookClassProtocolMap  = [NSMapTable strongToStrongObjectsMapTable];
        protocolHookMap.globalHookClassIMPMap       = [NSMapTable strongToStrongObjectsMapTable];
        protocolHookMap.protocolLock                = dispatch_semaphore_create(1);
        protocolHookMap.impLock                     = dispatch_semaphore_create(1);
    });
    return protocolHookMap;
}

#pragma mark - class: protocols

- (void)retainHookClass:(Class)hookClass protocol:(Protocol *)protocol {
    dispatch_semaphore_wait(self.protocolLock, DISPATCH_TIME_FOREVER);
    XYProtocolHookEntry *entry = [self.globalHookClassProtocolMap objectForKey:hookClass];
    if (!entry) {
        entry = [[XYProtocolHookEntry alloc] initWithHookClass:hookClass];
        [self.globalHookClassProtocolMap setObject:entry forKey:hookClass];
    }
    [entry retainHookCount:protocol];
    dispatch_semaphore_signal(self.protocolLock);
}

- (void)releaseHookClass:(Class)hookClass protocol:(Protocol *)protocol {
    dispatch_semaphore_wait(self.protocolLock, DISPATCH_TIME_FOREVER);
    XYProtocolHookEntry *entry = [self.globalHookClassProtocolMap objectForKey:hookClass];
    if (!entry) {
        dispatch_semaphore_signal(self.protocolLock);
        return;
    }
    [entry releaseHookCount:protocol];
    // 如果 entry 中的记录的所有协议都被移除了，则表示该类需要被还原，将其从全局map中移除
    if ([entry isProtocolHookEntryNeedDealloc]) {
        [self.globalHookClassProtocolMap removeObjectForKey:hookClass];
    }
    dispatch_semaphore_signal(self.protocolLock);
}

- (BOOL)isProtocolHooked:(Class)hookClass protocol:(Protocol *)protocol {
    dispatch_semaphore_wait(self.protocolLock, DISPATCH_TIME_FOREVER);
    XYProtocolHookEntry *entry = [self.globalHookClassProtocolMap objectForKey:hookClass];
    if (!entry) {
        dispatch_semaphore_signal(self.protocolLock);
        return NO;
    }
    NSUInteger hookCount = [entry hookProtocolCount:protocol];
    dispatch_semaphore_signal(self.protocolLock);
    return hookCount > 0;
}

- (BOOL)isProtocolNeedDealloc:(Class)hookClass protocol:(Protocol *)protocol {
    dispatch_semaphore_wait(self.protocolLock, DISPATCH_TIME_FOREVER);
    XYProtocolHookEntry *entry = [self.globalHookClassProtocolMap objectForKey:hookClass];
    if (!entry) {
        dispatch_semaphore_signal(self.protocolLock);
        return YES;
    }
    NSUInteger hookCount = [entry hookProtocolCount:protocol];
    dispatch_semaphore_signal(self.protocolLock);
    return hookCount == 0;
}

- (BOOL)isProtocolHookClassNeedRecover:(Class)hookClass {
    return ![[[self.globalHookClassProtocolMap keyEnumerator] allObjects] containsObject:hookClass];
}

#pragma mark - class: forwardInvocationIMP

- (void)recordHookClass:(Class)hookClass forwardInvocationIMP:(IMP)originIMP {
    dispatch_semaphore_wait(self.impLock, DISPATCH_TIME_FOREVER);
    XYProtocolHookForwardInvocationEntry *entry = [self.globalHookClassIMPMap objectForKey:hookClass];
    if (!entry) {
        entry = [[XYProtocolHookForwardInvocationEntry alloc] initWithHookClass:hookClass forwardInvocationIMP:originIMP];
    }
    [self.globalHookClassIMPMap setObject:entry forKey:hookClass];
    dispatch_semaphore_signal(self.impLock);
    NSLog(@"[XYProtocolHookMap]----[recordHookClass]----%@", hookClass);
}

- (void)discardHookClass:(Class)hookClass {
    dispatch_semaphore_wait(self.impLock, DISPATCH_TIME_FOREVER);
    if ([[[self.globalHookClassIMPMap keyEnumerator] allObjects] containsObject:hookClass]) {
        [self.globalHookClassIMPMap removeObjectForKey:hookClass];
    }
    dispatch_semaphore_signal(self.impLock);
    NSLog(@"[XYProtocolHookMap]----[discardHookClass]----%@", hookClass);
}

- (BOOL)isForwardInvocationIMPRecorded:(Class)hookClass {
    return [[[self.globalHookClassIMPMap keyEnumerator] allObjects] containsObject:hookClass];
}

- (IMP)forwardInvocationIMPForHookClass:(Class)hookClass {
    dispatch_semaphore_wait(self.impLock, DISPATCH_TIME_FOREVER);
    if (![self isForwardInvocationIMPRecorded:hookClass]) {
        dispatch_semaphore_signal(self.impLock);
        return NULL;
    }
    XYProtocolHookForwardInvocationEntry *entry = [self.globalHookClassIMPMap objectForKey:hookClass];
    dispatch_semaphore_signal(self.impLock);
    return entry.forwardInvocationIMP;
}

@end
