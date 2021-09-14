//
//  UIViewController+XYProtocolSignal.m
//  Masonry
//
//  Created by 郭文超 on 2021/9/10.
//

#import "UIViewController+XYProtocolSignal.h"
#import "XYProtocolObserver.h"
#import <objc/runtime.h>


@implementation UIViewController (XYProtocolSignal)


- (XYProtocolSignalCreate)create  {
    __weak typeof(self) weakSelf = self;
    return ^(NSObject * observable, Protocol *aProtocol) {
        
        return weakSelf;
    };
}

- (XYProtocolSignalSubscribe)subscribe {
    __weak typeof(self) weakSelf = self;
    return ^(NSObject *observer, SEL aSel) {
        
        return weakSelf;
    };
}

- (XYProtocolSignalSubscribeAll)subscribeAll {
    __weak typeof(self) weakSelf = self;
    return ^(NSObject *observer) {
        
        return weakSelf;
    };
}

- (XYProtocolSignalClose)close {
    return ^(){
        return;
    };
}


@end
