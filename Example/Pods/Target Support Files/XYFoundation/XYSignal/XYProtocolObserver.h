//
//  XYProtocolObserver.h
//  Masonry
//
//  Created by 郭文超 on 2021/9/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYProtocolObserver : NSObject
- (instancetype)initWithObserver:(NSObject *)observer selector:(SEL)selector;
@property (nonatomic, readonly) SEL selector;
@property (nonatomic, weak, readonly) NSObject *observer;
@property (nonatomic, strong, nullable) XYProtocolObserver *next;
@end

NS_ASSUME_NONNULL_END
