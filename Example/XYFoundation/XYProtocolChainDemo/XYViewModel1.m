//
//  XYViewModel1.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import "XYViewModel1.h"

@implementation XYViewModel1
- (XYViewModel2 *)viewModel2 {
    if (!_viewModel2) {
        _viewModel2 = [[XYViewModel2 alloc] init];
    }
    return _viewModel2;
}
- (void)xyProtocolChain {
    NSLog(@"%@ ---- %s", self.class, __func__);
}

@end
