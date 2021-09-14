//
//  XYProtocolObserver.m
//  Masonry
//
//  Created by 郭文超 on 2021/9/10.
//

#import "XYProtocolObserver.h"


@interface XYProtocolObserver ()
@property (nonatomic) SEL selector;
@property (nonatomic, weak) NSObject *observer;
@end

@implementation XYProtocolObserver
- (instancetype)initWithObserver:(NSObject *)observer selector:(nonnull SEL)selector {
    self = [super init];
    if (self) {
        _selector = selector;
        _observer = observer;
    }
    return self;
}
@end
