//
//  XYRoomManager.h
//  ProtocolHook
//
//  Created by 郭文超 on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import "XYRoomProtocol.h"
#import "XYProtocolHookCondition.h"
NS_ASSUME_NONNULL_BEGIN

@interface XYRoomManager : NSObject<XYRoomDelegate, XYProtocolHookCondition>

@end

NS_ASSUME_NONNULL_END
