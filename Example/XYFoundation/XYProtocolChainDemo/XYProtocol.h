//
//  XYProtocol.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XYProtocol <NSObject>
- (void)xyProtocolChain;
- (void)xyProtocolChainNoResopnder;
@end

@protocol XYProtocol2 <NSObject>
- (void)xyProtocolChain222222;
- (void)xyProtocolChainNoResopnder222222;
@end

@protocol XYProtocol6 <NSObject>
- (void)xyProtocolChain666666;
- (void)xyProtocolChainNoResopnder666666;
@end

NS_ASSUME_NONNULL_END
