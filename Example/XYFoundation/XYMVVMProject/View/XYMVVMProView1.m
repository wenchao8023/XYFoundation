//
//  XYMVVMProView1.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/23.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProView1.h"

@implementation XYMVVMProView1
- (void)setActionResponder:(id<XYMVVMProActionRespondable1>)actionResponder {
    _actionResponder = actionResponder;
    
    __weak typeof(self) weakSelf = self;
    _actionResponder.updateColorBlock = ^(UIColor * _Nonnull color) {
        weakSelf.backgroundColor = color;
    };
    
    _actionResponder.getColorBlock = ^UIColor * _Nonnull{
        return self.backgroundColor;
    };
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
