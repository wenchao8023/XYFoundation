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
@end

@implementation XYProtocolResponderChain
- (instancetype)initResponderChainWithProtocol:(Protocol *)protocol observable:(NSObject *)observable {
    self = [super init];
    if (self) {
        _protocol  = protocol;
        _protocolHook = [[XYProtocolHook alloc] initWithHookObj:observable andProtocolList:@[protocol]];
    }
    return self;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"XYProtocolChain : <%s>", protocol_getName(self.protocol)];
}
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
