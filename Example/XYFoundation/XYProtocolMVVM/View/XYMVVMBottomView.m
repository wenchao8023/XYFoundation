//
//  XYMVVMBottomView.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/11.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMBottomView.h"


@implementation XYMVVMBottomView

- (IBAction)onUserProtocolAction:(id)sender {
    if (self.viewModel && [self.viewModel respondsToSelector:@selector(bottomViewDidUserProtocol)]) {
        [self.viewModel bottomViewDidUserProtocol];
    }
}


@end
