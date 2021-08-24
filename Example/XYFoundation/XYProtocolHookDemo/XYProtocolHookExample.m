//
//  XYProtocolHookExample.m
//  ProtocolHook
//
//  Created by 郭文超 on 2021/7/5.
//

#import "XYProtocolHookExample.h"
#import "XYRoomManager.h"
#import "XYRoomProtocol.h"
#import <objc/runtime.h>
#import "XYProtocolHook.h"

@interface XYProtocolHookExample ()
@property (nonatomic, strong) XYRoomManager *manager;
@property (nonatomic, strong) XYProtocolHook *protocolHook;
@property (nonatomic, strong) NSMutableArray *hookArr;
@end

@implementation XYProtocolHookExample

- (NSMutableArray *)hookArr {
    if (!_hookArr) {
        _hookArr = [NSMutableArray array];
    }
    return _hookArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.protocolHook = [[XYProtocolHook alloc] initWithHookObj:self.manager
                                                 andProtocolList:@[
                                                     @protocol(XYRoomDelegate),
                                                     @protocol(XYRoomUnUsedDelegate)
                                                 ]];
}


- (IBAction)onCreateRoom:(id)sender {
    [self.manager onCreateRoom];
    
    [self.manager onUserIdle:@"3s"];
    
    [self.manager onUserIdle:@"5s" arg:20 name:@"zhangsan"];
    
    [self.manager weishixiandefangfa];
}

- (IBAction)onCreateNewObj:(id)sender {
    XYRoomManager *manager = [XYRoomManager new];
    [manager onCreateRoom];
    
    [manager onUserIdle:@"222222"];
    
    [manager onUserIdle:@"444444" arg:50 name:@"lisi"];
    
    [manager weishixiandefangfa];
}

- (IBAction)onDestoryRoom:(id)sender {
    //    self.manager = nil;
    XYRoomManager *manager = [XYRoomManager new];
    XYProtocolHook *protocolHook = [[XYProtocolHook alloc] initWithHookObj:manager
                                                           andProtocolList:@[
                                                               @protocol(XYRoomDelegate),
                                                               @protocol(XYRoomUnUsedDelegate)
                                                           ]];
    
    [manager onCreateRoom];
    
    [manager onUserIdle:@"333333"];
    
    [manager onUserIdle:@"666666" arg:50 name:@"zhangsan"];
    
    [manager weishixiandefangfa];
    
    [self.hookArr addObject:protocolHook];
    [self.hookArr addObject:manager];
}
- (IBAction)onReleaseHook:(id)sender {
    self.protocolHook = nil;
}

- (XYRoomManager *)manager {
    if (!_manager) {
        _manager = [XYRoomManager new];
    }
    return _manager;
}

@end
