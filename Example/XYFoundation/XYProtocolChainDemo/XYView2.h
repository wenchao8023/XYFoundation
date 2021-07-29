//
//  XYView2.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <UIKit/UIKit.h>
#import "XYProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface XYView2 : UIView
@property (nonatomic, weak) id<XYProtocol, XYProtocol2, XYProtocol6> delegate;
@end

NS_ASSUME_NONNULL_END
