//
//  XYProtocolHookMap.m
//  XYFoundation
//
//  Created by 郭文超 on 2021/8/20.
//

#import "XYProtocolHookMap.h"
#import <objc/runtime.h>
#import "XYSelectorUtil.h"

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
@property (nonatomic, strong) NSMapTable<Class, XYProtocolHookEntry *> *globalHookProtocolMap;
@property (nonatomic, strong) NSMapTable<Class, XYProtocolHookForwardInvocationEntry *> *globalHookIMPMap;
@property (nonatomic, strong) dispatch_semaphore_t lock;
@end


@implementation XYProtocolHookMap
+ (instancetype)shareHookMap {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protocolHookMap = [[XYProtocolHookMap alloc] init];
        protocolHookMap.lock = dispatch_semaphore_create(1);
        protocolHookMap.globalHookProtocolMap = [NSMapTable strongToStrongObjectsMapTable];
        protocolHookMap.globalHookIMPMap = [NSMapTable strongToStrongObjectsMapTable];
    });
    return protocolHookMap;
}

#pragma mark - class: protocols

- (void)retainHookClass:(Class)hookClass protocol:(Protocol *)protocol {
    XYProtocolHookEntry *entry = [self.globalHookProtocolMap objectForKey:hookClass];
    if (!entry) {
        entry = [[XYProtocolHookEntry alloc] initWithHookClass:hookClass];
        [self.globalHookProtocolMap setObject:entry forKey:hookClass];
    }
    [entry retainHookCount:protocol];
}

- (void)releaseHookClass:(Class)hookClass protocol:(Protocol *)protocol {
    XYProtocolHookEntry *entry = [self.globalHookProtocolMap objectForKey:hookClass];
    if (!entry) {
        return;
    }
    [entry releaseHookCount:protocol];

    if ([entry isProtocolHookEntryNeedDealloc]) {
        [self.globalHookProtocolMap removeObjectForKey:hookClass];
    }
}

- (BOOL)isProtocolHooked:(Class)hookClass protocol:(Protocol *)protocol {
    // lock
    XYProtocolHookEntry *entry = [self.globalHookProtocolMap objectForKey:hookClass];
    if (!entry) {
        return NO;
    }
    return [entry hookProtocolCount:protocol] > 0;
}

- (BOOL)isProtocolNeedDealloc:(Class)hookClass protocol:(Protocol *)protocol {
    XYProtocolHookEntry *entry = [self.globalHookProtocolMap objectForKey:hookClass];
    if (!entry) {
        return YES;
    }
    return [entry hookProtocolCount:protocol] == 0;
}

- (BOOL)isProtocolHookClassNeedRecover:(Class)hookClass {
    return ![[[self.globalHookProtocolMap keyEnumerator] allObjects] containsObject:hookClass];
}

#pragma mark - class: forwardInvocationIMP

- (void)recordHookClass:(Class)hookClass forwardInvocationIMP:(IMP)originIMP {
    XYProtocolHookForwardInvocationEntry *entry = [[XYProtocolHookForwardInvocationEntry alloc] initWithHookClass:hookClass forwardInvocationIMP:originIMP];
    [self.globalHookIMPMap setObject:entry forKey:hookClass];
    NSLog(@"[XYProtocolHookMap]----[recordHookClass]----");
}

- (void)discardHookClass:(Class)hookClass {
    [self.globalHookIMPMap removeObjectForKey:hookClass];
}

- (BOOL)isForwardInvocationIMPRecorded:(Class)hookClass {
    return [[[self.globalHookIMPMap keyEnumerator] allObjects] containsObject:hookClass];
}

- (IMP)forwardInvocationIMPForHookClass:(Class)hookClass {
    if (![self isForwardInvocationIMPRecorded:hookClass]) {
        return NULL;
    }
    XYProtocolHookForwardInvocationEntry *entry = [self.globalHookIMPMap objectForKey:hookClass];
    return entry.forwardInvocationIMP;
}

@end
