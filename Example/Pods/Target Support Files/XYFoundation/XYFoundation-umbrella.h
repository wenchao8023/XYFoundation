#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XYMethodUtil.h"
#import "XYProtocolHook.h"
#import "XYProtocolHookCondition.h"
#import "XYTimer.h"

FOUNDATION_EXPORT double XYFoundationVersionNumber;
FOUNDATION_EXPORT const unsigned char XYFoundationVersionString[];

