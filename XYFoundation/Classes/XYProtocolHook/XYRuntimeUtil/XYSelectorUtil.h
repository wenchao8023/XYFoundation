//
//  XYSelectorUtil.h
//  XYFoundation
//
//  Created by 郭文超 on 2021/8/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * xy_string_from_selector(SEL selector);

extern SEL xy_selector_from_string(NSString *selName);

extern SEL xy_swizzle_selector_from_string(NSString *selName);

extern SEL xy_swizzle_selector_from_selector(SEL originSel);

extern SEL xy_protocol_swizzle_selector(SEL originSel);

NS_ASSUME_NONNULL_END
