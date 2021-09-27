//
//  XYMVVMProViewController.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProViewController.h"
#import "XYMVVMProView.h"
#import "XYMVVMProViewModel.h"
#import "UIViewController+XYProtocolChain.h"
#import "XYMVVMProTraceServer.h"

@interface XYMVVMProViewController ()<XYMVVMProActionRespondable, XYMVVMProActionRespondable1, XYMVVMProActionRespondable2>
@property (nonatomic, strong) XYMVVMProView *proView;
@property (nonatomic, strong) XYMVVMProViewModel *proViewModel;
@property (nonatomic, strong) XYMVVMProTraceServer *traceServer;
@end

@implementation XYMVVMProViewController

- (instancetype)initWithViewModel:(XYMVVMProViewModel *)viewModel {
    self = [super init];
    if (self) {
        _proViewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubview];
    [self setupViewModel];
}

- (void)setupSubview {
    self.proView = [[XYMVVMProView alloc] initWithFrame:self.view.bounds];
    self.view    = self.proView;
}

- (void)setupViewModel {
    // 各司其职，互相帮衬
    self.proView.actionResponder = self.proViewModel;
    self.proView.proView1.actionResponder = self.proViewModel.proViewModel1;
    self.proView.proView2.actionResponder = self.proViewModel.proViewModel2;
    
    self.bind(@protocol(XYMVVMProActionRespondable), self.proViewModel)
        .link(self, @selector(mvvmViewActionCallback))
        .link(self.traceServer, @selector(mvvmViewActionCallback))
        .close();
    
    self.bind(@protocol(XYMVVMProActionRespondable1), self.proViewModel.proViewModel1)
        .link(self, @selector(mvvmView1ActionCallback))
        .link(self.traceServer, @selector(mvvmView1ActionCallback))
        .close();
    
    self.bind(@protocol(XYMVVMProActionRespondable2), self.proViewModel.proViewModel2)
        .link(self, @selector(mvvmView2ActionCallback))
        .link(self.traceServer, @selector(mvvmView2ActionCallback))
        .close();
    
    [self traverseProtocolChain];
}

#pragma mark -
/// 定义事件流转的协议
- (void)mvvmViewActionCallback {
    
}

- (void)mvvmView1ActionCallback {
    
}

- (void)mvvmView2ActionCallback {
    
}

#pragma mark - Lazy Load

- (XYMVVMProTraceServer *)traceServer {
    if (!_traceServer) {
        _traceServer = [[XYMVVMProTraceServer alloc] initWithDataStore:self.proViewModel.dataStore];
    }
    return _traceServer;
}

@end
