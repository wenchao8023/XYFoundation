//
//  XYMVVMProDependencyViewController.m
//  XYFoundation_Example
//
//  Created by 郭文超 on 2021/9/26.
//  Copyright © 2021 wenchao8023. All rights reserved.
//

#import "XYMVVMProDependencyViewController.h"
#import "XYMVVMProDependencyFactory.h"


@interface TestModel : NSObject<XYMVVMProDataModel>

@end

@implementation TestModel
- (NSString *)name {
    return @"李四";
}
- (NSString *)address {
    return @"天堂";
}
@end


@interface XYMVVMProDependencyViewController ()

@end

@implementation XYMVVMProDependencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)testJump:(id)sender {
    id<XYMVVMProDataModel> model = [TestModel new];
    UIViewController *vc = [XYMVVMProDependencyFactory createMVVMProViewController:@"张三"
                                                                             model:model
                                                                             block:^(NSString * _Nonnull desc) {
        NSLog(@"%@", desc);
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
