//
//  XYMVVMViewController.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/11.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMViewController.h"
#import "UIViewController+XYProtocolChain.h"
#import "XYMVVMView.h"
#import "XYMVVMViewModel.h"
#import "XYMVVMProtocol.h"

@interface XYMVVMViewController ()<XYMVVMBottomViewDelegate>
@property (nonatomic, strong) XYMVVMView *loginView;
@property (nonatomic, strong) XYMVVMViewModel *viewModel;
@end

@implementation XYMVVMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.loginView];
    self.loginView.frame = self.view.bounds;
    
    self.loginView.viewModel = self.viewModel;
    self.loginView.TFView.viewModel = self.viewModel.TFViewModel;
    self.loginView.BTView.viewModel = self.viewModel.BTViewModel;
    
    self.bind(@protocol(XYMVVMBottomViewDelegate), self.viewModel.BTViewModel)
    .link(self.viewModel, @selector(bottomViewDidUserProtocol))
    .link(self, @selector(bottomViewDidUserProtocol))
    .close();
    
    self.bind(@protocol(XYMVVMTextFieldViewDelegate), self.viewModel.TFViewModel)
    .link(self.viewModel, @selector(textFieldViewAccountChanged:))
    .link(self.viewModel, @selector(textFieldViewPasswordChanged:))
    .link(self.viewModel, @selector(textFieldViewVericodeChanged:))
    .close();
    
    [self traverseProtocolChain];
}

- (void)bottomViewDidUserProtocol {
    NSLog(@"XYMVVMViewController : 处理跳转用户协议流程");
}


#warning 在项目开发中，viewModel一般是通过依赖注入的
- (XYMVVMViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[XYMVVMViewModel alloc] init];
    }
    return _viewModel;
}

- (XYMVVMView *)loginView {
    if (!_loginView) {
        _loginView = [[NSBundle mainBundle] loadNibNamed:@"XYMVVMView" owner:nil options:nil].firstObject;
    }
    return _loginView;
}


@end
