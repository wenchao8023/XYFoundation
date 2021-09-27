//
//  XYMVVMProtocol.h
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/8/11.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol XYMVVMViewDelegate <NSObject>
@optional
- (void)loginViewDidLogin;
@property (nonatomic, copy) void (^tipBlock)(NSString *str);
@property (nonatomic, copy) void (^loginSuccessBlock)(void);
@end

@protocol XYMVVMTextFieldViewDelegate <NSObject>
@optional
- (void)textFieldViewAccountChanged:(NSString *)account;
- (void)textFieldViewPasswordChanged:(NSString *)password;
- (void)textFieldViewVericodeChanged:(NSString *)vericode;
- (void)textFieldViewDidGetVericode;
@property (nonatomic, copy) void (^vericodeButtonTitleBlock)(NSString *title, BOOL enabled) ;
@end

@protocol XYMVVMBottomViewDelegate <NSObject>
@optional
- (void)bottomViewDidUserProtocol;
@end


NS_ASSUME_NONNULL_END
