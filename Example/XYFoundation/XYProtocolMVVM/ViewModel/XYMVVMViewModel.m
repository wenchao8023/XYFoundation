//
//  XYMVVMViewModel.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/9.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMViewModel.h"

@interface XYMVVMViewModel ()
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *vericode;
@property (nonatomic, strong) XYMVVMTextFieldViewModel *TFViewModel;
@property (nonatomic, strong) XYMVVMBottomViewModel *BTViewModel;
@end


@implementation XYMVVMViewModel
@synthesize tipBlock, loginSuccessBlock;

#pragma mark - XYMVVMViewDelegate

- (void)loginViewDidLogin {
    NSLog(@"XYMVVMViewModel : 处理登录相关的业务");
    [self responseToTip:@"正在登录..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.loginSuccessBlock) {
            self.loginSuccessBlock();
        }
    });
}

#pragma mark - XYMVVMTextFieldViewDelegate

- (void)textFieldViewAccountChanged:(nonnull NSString *)account {
    self.account = account;
    [self responseToTip:[NSString stringWithFormat:@"account : %@", account]];
}

- (void)textFieldViewPasswordChanged:(nonnull NSString *)password {
    self.password = password;
    [self responseToTip:[NSString stringWithFormat:@"password : %@", password]];
}

- (void)textFieldViewVericodeChanged:(nonnull NSString *)vericode {
    self.vericode = vericode;
    [self responseToTip:[NSString stringWithFormat:@"vericode : %@", vericode]];
}

- (void)responseToTip:(NSString *)tip {
    if (self.tipBlock) {
        self.tipBlock(tip);
    }
}

#pragma mark - XYMVVMBottomViewDelegate
- (void)bottomViewDidUserProtocol {
    NSLog(@"XYMVVMViewModel : 处理埋点相关的业务");
}

#pragma mark - Lazy Load

- (XYMVVMTextFieldViewModel *)TFViewModel {
    if (!_TFViewModel) {
        _TFViewModel = [XYMVVMTextFieldViewModel new];
    }
    return _TFViewModel;
}

- (XYMVVMBottomViewModel *)BTViewModel {
    if (!_BTViewModel) {
        _BTViewModel = [XYMVVMBottomViewModel new];
    }
    return _BTViewModel;
}

@end
