//
//  XYView1.h
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import <UIKit/UIKit.h>
#import "XYView2.h"
#import "XYProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface XYView1 : UIView<XYProtocol>
@property (nonatomic, strong) XYView2 *view2;
@end

NS_ASSUME_NONNULL_END
