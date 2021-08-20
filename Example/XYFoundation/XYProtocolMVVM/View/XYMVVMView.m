//
//  XYMVVMView.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/9.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMView.h"
#import "Masonry.h"

@interface XYMVVMView ()
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) XYMVVMTextFieldView *TFView;
@property (nonatomic, strong) XYMVVMBottomView *BTView;
@end

@implementation XYMVVMView

- (IBAction)onLoginAction:(id)sender {
    if (self.viewModel && [self.viewModel respondsToSelector:@selector(loginViewDidLogin)]) {
        [self.viewModel loginViewDidLogin];
    }
}


- (void)setViewModel:(id<XYMVVMViewDelegate>)viewModel {
    _viewModel = viewModel;
    __weak typeof(self) weakSelf = self;
    _viewModel.tipBlock = ^(NSString * _Nonnull str) {
        __strong typeof(weakSelf) self = weakSelf;
        self.tipLabel.text = str;
    };
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self addSubview:self.TFView];
    [self addSubview:self.BTView];
    
    [self.BTView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self);
        }
    }];
    [self.TFView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.tipLabel);
        make.bottom.equalTo(self.tipLabel.mas_top).offset(-40);
    }];
}

- (XYMVVMTextFieldView *)TFView {
    if (!_TFView) {
        _TFView = [[NSBundle mainBundle] loadNibNamed:@"XYMVVMTextFieldView" owner:nil options:nil].firstObject;
    }
    return _TFView;
}

- (XYMVVMBottomView *)BTView {
    if (!_BTView) {
        _BTView = [[NSBundle mainBundle] loadNibNamed:@"XYMVVMBottomView" owner:nil options:nil].firstObject;
    }
    return _BTView;
}

@end
