//
//  XYMVVMTextFieldView.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/11.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMTextFieldView.h"

@interface XYMVVMTextFieldView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *vericodeTF;
@property (weak, nonatomic) IBOutlet UIButton *vericodeButton;

@end

@implementation XYMVVMTextFieldView

- (IBAction)onVericodeAction:(id)sender {
    if (self.viewModel && [self.viewModel respondsToSelector:@selector(textFieldViewDidGetVericode)]) {
        [self.viewModel textFieldViewDidGetVericode];
    }
}

- (void)onValueChangedEvent:(NSNotification *)noticifation {
    UITextField *tf = (UITextField *)noticifation.object;
    if ([tf isEqual:self.accountTF]) {
        if (self.viewModel && [self.viewModel respondsToSelector:@selector(textFieldViewAccountChanged:)]) {
            [self.viewModel textFieldViewAccountChanged:tf.text];
        }
    }
    if ([tf isEqual:self.passwordTF]) {
        if (self.viewModel && [self.viewModel respondsToSelector:@selector(textFieldViewPasswordChanged:)]) {
            [self.viewModel textFieldViewPasswordChanged:tf.text];
        }
    }
    if ([tf isEqual:self.vericodeTF]) {
        if (self.viewModel && [self.viewModel respondsToSelector:@selector(textFieldViewVericodeChanged:)]) {
            [self.viewModel textFieldViewVericodeChanged:tf.text];
        }
    }
}

- (void)setViewModel:(id<XYMVVMTextFieldViewDelegate>)viewModel {
    _viewModel = viewModel;
    __weak typeof(self) weakSelf = self;
    _viewModel.vericodeButtonTitleBlock = ^(NSString *title, BOOL enabled) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.vericodeButton setTitle:title forState:UIControlStateNormal];
        if (self.vericodeButton.enabled != enabled) {
            self.vericodeButton.enabled = enabled;
        }
    };
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onValueChangedEvent:) name:UITextFieldTextDidChangeNotification object:self.accountTF];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onValueChangedEvent:) name:UITextFieldTextDidChangeNotification object:self.passwordTF];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onValueChangedEvent:) name:UITextFieldTextDidChangeNotification object:self.vericodeTF];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:UITextFieldTextDidChangeNotification object:self.accountTF];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordTF];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UITextFieldTextDidChangeNotification object:self.vericodeTF];
}

@end
