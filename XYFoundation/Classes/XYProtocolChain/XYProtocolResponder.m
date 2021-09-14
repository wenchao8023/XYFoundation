//
//  XYProtocolResponder.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import "XYProtocolResponder.h"
#import <objc/runtime.h>

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
    return [NSString stringWithFormat:@"Responder <%@>", self.responder.class];
}
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end



@interface XYProtocolResponderChain ()
@property (nonatomic, strong) XYProtocolHook *protocolHook;
@property (nonatomic, weak  ) NSObject *observable;
@property (nonatomic, strong) NSMapTable<NSString *, XYProtocolResponder *> *responderMap;

@end

@implementation XYProtocolResponderChain
- (instancetype)initResponderChainWithProtocol:(Protocol *)protocol observable:(NSObject *)observable {
    self = [super init];
    if (self) {
        _protocol     = protocol;
        _observable   = observable;
        _protocolHook = [[XYProtocolHook alloc] initWithHookObj:observable
                                                andProtocolList:@[protocol]];
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

- (XYProtocolResponder *)resonderForSelector:(SEL)selector {
    if (self.responderMap.count == 0 || selector == NULL) {
        return nil;
    }
    NSString *selKey = NSStringFromSelector(selector);
    return [self.responderMap objectForKey:selKey];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"XYProtocolChain : <%s>", protocol_getName(self.protocol)];
}
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
