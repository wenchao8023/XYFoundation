//
//  XYRoomProtocol.h
//  ProtocolHook
//
//  Created by 郭文超 on 2021/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XYRoomDelegate <NSObject>

- (void)onCreateRoom;

- (void)onUserIdle:(NSString *)idle;

- (void)onUserIdle:(NSString *)idle arg:(int)age name:(NSString *)name;

- (void)weishixiandefangfa;

@end

@protocol XYRoomUnUsedDelegate <NSObject>
- (void)onUnUsedMethod;
@end

@interface XYRoomProtocol : NSObject

@end

NS_ASSUME_NONNULL_END
