//
//  XYMVVMTextFieldViewModel.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/9.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMTextFieldViewModel.h"


@interface XYMVVMTextFieldViewModel ()
@property (nonatomic, strong) NSTimer *timer;
@end


@implementation XYMVVMTextFieldViewModel
@synthesize vericodeButtonTitleBlock;


- (void)textFieldViewAccountChanged:(nonnull NSString *)account {
    
}

- (void)textFieldViewPasswordChanged:(nonnull NSString *)password {
    
}

- (void)textFieldViewVericodeChanged:(nonnull NSString *)vericode {
    
}

- (void)textFieldViewDidGetVericode {
    NSLog(@"XYMVVMTextFieldViewModel : 处理网络请求相关业务");
    __weak typeof(self) weakSelf = self;
    __block int count = 6;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) self = weakSelf;
        
        count--;
        if (self.vericodeButtonTitleBlock) {
            self.vericodeButtonTitleBlock([NSString stringWithFormat:@"%2d(S)", count], NO);
        }
        if (count <= 0) {
            if (self.vericodeButtonTitleBlock) {
                self.vericodeButtonTitleBlock(@"验证码", YES);
            }
            [self.timer invalidate];
            self.timer = nil;
        }
    }];
}

@end
