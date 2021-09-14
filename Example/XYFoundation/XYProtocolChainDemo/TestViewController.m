//
//  TestViewController.m
//  ProtocolChain
//
//  Created by 郭文超 on 2021/7/28.
//

#import "TestViewController.h"
#import "XYView1.h"
#import "XYViewModel1.h"
#import "XYProtocol.h"
#import "UIViewController+XYProtocolChain.h"




@interface TestViewController ()<XYProtocol>
@property (nonatomic, strong) XYView1 *view1;
@property (nonatomic, strong) XYViewModel1 *viewModel1;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view1.frame = CGRectMake(100, 100, 150, 150);
    [self.view addSubview:self.view1];
    
    self.view1.view2.delegate = self.viewModel1.viewModel2;
    
    self.bind(@protocol(XYProtocol), self.viewModel1.viewModel2)
    .link(self.viewModel1, @selector(xyProtocolChain))
    .link(self.view1, @selector(xyProtocolChain))
    .link(self, @selector(xyProtocolChain))
    .link(self, @selector(xyProtocolChainNoResopnder))
    .close();
    
    [self traverseProtocolChain];

    self.bind(@protocol(XYProtocol2), self.viewModel1.viewModel2)
    .link(self.viewModel1, @selector(xyProtocolChain222222))
    .link(self, @selector(xyProtocolChain222222))
    .close();
    
    [self traverseProtocolChain];
    
    self.bind(@protocol(XYProtocol6), self.viewModel1.viewModel2)
    .link(self.viewModel1.viewModel2, @selector(xyProtocolChain666666))
    .link(self, @selector(xyProtocolChain666666))
    .close();
    
    [self traverseProtocolChain];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)xyProtocolChain {
    NSLog(@"%@ ---- %s", self.class, __func__);
}
- (void)xyProtocolChain222222 {
    NSLog(@"%@ ---- %s", self.class, __func__);
}
- (void)xyProtocolChain666666 {
    NSLog(@"%@ ---- %s", self.class, __func__);
}
- (void)xyProtocolChainNoResopnder {
    NSLog(@"%@ ---- %s", self.class, __func__);
}

- (XYView1 *)view1 {
    if (!_view1) {
        _view1 = [[XYView1 alloc] init];
    }
    return _view1;
}

- (XYViewModel1 *)viewModel1 {
    if (!_viewModel1) {
        _viewModel1 = [[XYViewModel1 alloc] init];
    }
    return _viewModel1;
}


@end
