//
//  XYMethodUtil.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYMethodUtil : NSObject
// 获取类的方法列表
+ (NSArray<NSString *>  *)getMethodList:(Class)aClass;

// 获取协议的方法列表
+ (NSArray<NSString *> *)getMethodListInProtocols:(NSArray<Protocol *>*)protocols;

// 获取指定协议的方法列表
+ (NSArray<NSString *> *)getMethodListWithProtocol:(Protocol *)protocol;

// 获取指定协议的方法列表 - 是否是 required
+ (NSArray<NSString *> *)getMethodListWithProtocol:(Protocol *)protocol isRequiredMethod:(BOOL)isRequiredMethod;
@end

NS_ASSUME_NONNULL_END
