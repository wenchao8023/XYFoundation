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
@end

@implementation XYProtocolHookExample

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

- (IBAction)onDestoryRoom:(id)sender {
    self.manager = nil;
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
