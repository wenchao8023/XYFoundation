//
//  XYMethodUtil.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/29.
//

#import "XYMethodUtil.h"
#import <objc/runtime.h>

@implementation XYMethodUtil
// 获取类的方法列表
+ (NSArray *)getMethodList:(Class)aClass {
    unsigned int count;
    Method *methodList = class_copyMethodList(aClass, &count);
    
    NSMutableArray *methodArr = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        if (!methodName || !methodName.length) {
            continue;
        }
        [methodArr addObject:methodName];
    }
    
    free(methodList);
    
    return methodArr.copy;
}
// 获取协议的方法列表
+ (NSArray *)getMethodListInProtocols:(NSArray<Protocol *>*)protocols {
    NSMutableArray *methodArr = [NSMutableArray array];
    [protocols enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *tempArr = [self getMethodListWithProtocol:obj];
        [methodArr addObjectsFromArray:tempArr];
    }];
    return methodArr.copy;
}

// 获取指定协议的方法列表
+ (NSArray *)getMethodListWithProtocol:(Protocol *)protocol {
    NSArray *tempArr1 = [self getMethodListWithProtocol:protocol isRequiredMethod:YES];
    NSArray *tempArr2 = [self getMethodListWithProtocol:protocol isRequiredMethod:NO];
    return [tempArr1 arrayByAddingObjectsFromArray:tempArr2];
}

// 获取指定协议的方法列表 - 是否是 required
+ (NSArray *)getMethodListWithProtocol:(Protocol *)protocol isRequiredMethod:(BOOL)isRequiredMethod {
    unsigned int methodCount = 0;

    struct objc_method_description *methodList = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, YES, &methodCount);
    NSMutableArray *methods = [NSMutableArray arrayWithCapacity:methodCount];

    for (int i = 0; i < methodCount; i ++) {
        struct objc_method_description md = methodList[i];
        [methods addObject:NSStringFromSelector(md.name)];
    }
    free(methodList);

    return methods.copy;
}

@end
