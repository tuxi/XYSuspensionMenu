//
//  ViewController.m
//  SuspensionView
//
//  Created by mofeini on 17/2/25.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "ViewController.h"
#import "SuspensionControl.h"


@interface ViewController ()

@end

@implementation ViewController {
    SuspensionView *v1;
    SuspensionView *v2;
    SuspensionView *v3;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSus];
}

- (void)createSus {
    
    
    __weak typeof(self) wf = self;
    
    v1 = [SuspensionControl suspensionViewOnce:NO frame:CGRectMake(0, 300, 60, 60) block:nil];
    [[SuspensionControl shareInstance].suspensionView clickCallback:^{
        NSLog(@"&&&&&&");
        [wf showMessage:[NSString stringWithFormat:@"第一个:%p", v1]];
    }];
    [v1 setImage:[UIImage imageNamed:@"message_keyboard"] forState:UIControlStateNormal];
    
    v2 = [SuspensionControl suspensionViewOnce:NO frame:CGRectMake(0, 400, 60, 60) block:nil];
    [[SuspensionControl shareInstance].suspensionView clickCallback:^{
        NSLog(@"222222");
        [wf showMessage:[NSString stringWithFormat:@"第二个:%p", v2]];
        
    }];
    v2.backgroundColor = [UIColor greenColor];
    
    v3 = [SuspensionControl suspensionViewOnce:NO frame:CGRectMake(0, 100, 60, 60) block:nil];
    [[SuspensionControl shareInstance].suspensionView clickCallback:^{
        NSLog(@"&&&&&&");
        [wf showMessage:[NSString stringWithFormat:@"第三个:%p", v3]];
    }];
    v3.backgroundColor = [UIColor blueColor];
    
    NSLog(@"%p-%p-%p", v1, v2, v3);
}

- (void)showMessage:(NSString *)m {
    [[[UIAlertView alloc] initWithTitle:@"提示" message:m delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [SuspensionControl releaseSuspensionView:v1 block:^{
        NSLog(@"vc1---");
    }];
    
    [SuspensionControl releaseSuspensionView:v2 block:^{
        NSLog(@"vc2---");
    }];
    
    [SuspensionControl releaseSuspensionView:v3 block:^{
        NSLog(@"v3---");
    }];
}

- (void)dealloc {
    

    
    NSLog(@"%s", __func__);
}


@end
