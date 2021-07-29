//
//  XYView1.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import "XYView1.h"

@implementation XYView1

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.systemRedColor;
        self.view2.frame = CGRectMake(0, 0, 80, 80);
        self.view2.backgroundColor = UIColor.systemTealColor;
        [self addSubview:self.view2];
    }
    return self;
}

- (XYView2 *)view2 {
    if (!_view2) {
        _view2 = [[XYView2 alloc] init];
    }
    return _view2;
}

- (void)xyProtocolChain {
    NSLog(@"%@ ---- %s", self.class, __func__);
}

@end
