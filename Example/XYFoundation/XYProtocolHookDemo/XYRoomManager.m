//
//  XYRoomManager.m
//  ProtocolHook
//
//  Created by 郭文超 on 2021/7/5.
//

#import "XYRoomManager.h"

@implementation XYRoomManager

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)methodInManager {
//    NSLog(@"%s", __func__);
}

- (void)onCreateRoom {
//    NSLog(@"%s", __func__);
}

- (void)onUserIdle:(NSString *)idle {
//    NSLog(@"%s : %@", __func__, idle);
}

- (void)onUserIdle:(NSString *)idle arg:(int)age name:(nonnull NSString *)name {
//    NSLog(@"%s : %@, age : %d, name : %@", __func__, idle, age, name);
}

//- (void)forwardInvocation:(NSInvocation *)anInvocation {
//    NSLog(@"%s", __func__);
//}

static int num = 0;

- (BOOL)isXYProtocolNeedHookMethodCall {
    return NO;
    return num++ % 2;
}


@end
