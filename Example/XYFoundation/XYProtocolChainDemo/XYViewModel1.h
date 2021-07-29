//
//  XYViewModel1.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <Foundation/Foundation.h>
#import "XYViewModel2.h"
NS_ASSUME_NONNULL_BEGIN

@interface XYViewModel1 : NSObject<XYProtocol>
@property (nonatomic, strong) XYViewModel2 *viewModel2;
@end

NS_ASSUME_NONNULL_END
