//
//  XYProtocolResponder.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import "XYProtocolResponder.h"
#import "XYProtocolHook.h"

@interface XYProtocolResponder ()
@property (nonatomic, weak) NSObject *responder;
@end

@implementation XYProtocolResponder
- (instancetype)initResponder:(NSObject *)responder {
    self = [super init];
    if (self) {
        _responder = responder;
    }
    return self;
}
- (NSString *)description {
    NSString *desc = @"\n\t\t\t";
    XYProtocolResponder *responder = self;
    while (responder) {
        desc = [desc stringByAppendingFormat:@"-> %@\n\t\t\t", responder.responder.class];
        responder = responder.nextResponder;
    }
    return desc;
}
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end



@interface XYProtocolResponderChain ()

/// 第一响应者
@property (nonatomic, weak, ) NSObject *firstResponder;

/// 协议hook类
@property (nonatomic, strong) XYProtocolHook *protocolHook;

/// 响应者map
@property (nonatomic, strong) NSMapTable<NSString *, XYProtocolResponder *> *responderMap;

@end

@implementation XYProtocolResponderChain
- (instancetype)initResponderChainWithProtocol:(Protocol *)protocol firstResponder:(NSObject *)firstResponder invocator:(__weak id<xyProtocolHookInvocation>)invocator {
    self = [super init];
    if (self) {
        _firstResponder = firstResponder;
        _protocolHook = [[XYProtocolHook alloc] initWithHookObj:firstResponder andProtocolList:@[protocol]];
        _protocolHook.invocator = invocator;
        _responderMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)linkResponder:(NSObject *)responder selector:(SEL)selector {
    if (!responder || selector == NULL) {
        return;
    }
    
    NSString *selKey = NSStringFromSelector(selector);
    XYProtocolResponder *oldResponder = [self.responderMap objectForKey:selKey];
    XYProtocolResponder *newResponder = [[XYProtocolResponder alloc] initResponder:responder];
    if (oldResponder) {
        XYProtocolResponder *tailResponder = oldResponder;
        while (tailResponder.nextResponder) {
            tailResponder = tailResponder.nextResponder;
        }
        tailResponder.nextResponder = newResponder;
    } else {
        [self.responderMap setObject:newResponder forKey:selKey];
    }
}

- (XYProtocolResponder *)responderForSelector:(SEL)selector {
    if (self.responderMap.count == 0 || selector == NULL) {
        return nil;
    }
    NSString *selKey = NSStringFromSelector(selector);
    return [self.responderMap objectForKey:selKey];
}

- (NSString *)description {
    __block NSString *desc = @"";
    [[[self.responderMap keyEnumerator] allObjects] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XYProtocolResponder *responder = [self.responderMap objectForKey:obj];
        desc = [desc stringByAppendingFormat:@"\t\t[%ld][ResponderChain][%@]\t%@\n", idx, obj, responder];
    }];
    return desc;
}
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
