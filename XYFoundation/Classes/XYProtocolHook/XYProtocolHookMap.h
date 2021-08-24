//
//  XYProtocolHookMap.h
//  XYFoundation
//
//  Created by 郭文超 on 2021/8/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 用来记录hook次数
@interface XYProtocolHookMap : NSObject
+ (instancetype)shareHookMap;

// MARK: class: protocols
- (void)retainHookClass:(Class)hookClass protocol:(Protocol *)protocol;
- (void)releaseHookClass:(Class)hookClass protocol:(Protocol *)protocol;
- (BOOL)isProtocolHooked:(Class)hookClass protocol:(Protocol *)protocol;
- (BOOL)isProtocolNeedDealloc:(Class)hookClass protocol:(Protocol *)protocol;
- (BOOL)isProtocolHookClassNeedRecover:(Class)hookClass;

// MARK: class: forwardInvocationIMP
- (void)recordHookClass:(Class)hookClass forwardInvocationIMP:(IMP)originIMP;
- (void)discardHookClass:(Class)hookClass;
- (BOOL)isForwardInvocationIMPRecorded:(Class)hookClass;
- (IMP)forwardInvocationIMPForHookClass:(Class)hookClass;
@end

NS_ASSUME_NONNULL_END
