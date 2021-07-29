//
//  XYView2.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import "XYView2.h"

@implementation XYView2

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(xyProtocolChain)]) {
        [self.delegate xyProtocolChain];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(xyProtocolChain222222)]) {
        [self.delegate xyProtocolChain222222];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(xyProtocolChain666666)]) {
        [self.delegate xyProtocolChain666666];
    }
}

@end
