//
//  XYSelectorUtil.m
//  XYFoundation
//
//  Created by 郭文超 on 2021/8/20.
//

#import "XYSelectorUtil.h"

static const NSString * xyProtocolHookPrefix = @"xy_xxxxxx_protocol_hook_";

SEL xy_selector_from_string(NSString *selName){
    return NSSelectorFromString(selName);
}

NSString * xy_string_from_selector(SEL selector){
    return NSStringFromSelector(selector);
}


SEL xy_swizzle_selector_from_string(NSString *selName){
    NSString *swizzleSelName = [xyProtocolHookPrefix stringByAppendingString:selName];
    return xy_selector_from_string(swizzleSelName);
}

SEL xy_swizzle_selector_from_selector(SEL originSel){
    NSString *selName = NSStringFromSelector(originSel);
    NSString *swizzleSelName = [xyProtocolHookPrefix stringByAppendingString:selName];
    return xy_selector_from_string(swizzleSelName);
}

SEL xy_protocol_swizzle_selector(SEL originSel) {
    return xy_swizzle_selector_from_selector(originSel);
}
