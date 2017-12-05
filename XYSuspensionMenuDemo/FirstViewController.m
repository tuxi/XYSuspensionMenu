//
//  FirstViewController.m
//  SuspensionView
//
//  Created by Ossey on 2017/5/21.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "FirstViewController.h"
#import "XYSuspensionMenu.h"
#import "XYLog.h"
#import "XYConsoleView.h"

#pragma mark *** Sample ***

@interface FirstViewController () <SuspensionMenuViewDelegate>

@end

@implementation FirstViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    XYLog(@"111");
    
    [self sample];
    
    [self testLog];
    
}

- (void)testRepeatInit {
    /// 测试重复创建
    [self oneLevelMenuSample];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sample];
        XYLog(@"666");
    });
}

- (void)testLog {
    [[UIApplication sharedApplication] xy_showConsole];
    if (@available(iOS 10.0, *)) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:5.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            static NSInteger i = 0;
            XYLog(@"%i", i++);
        }];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    } else {
        // Fallback on earlier versions
    }
}

/// 一级菜单使用
- (void)oneLevelMenuSample {
    XYLog(@"111");
    SuspensionMenuWindow *menuView = [SuspensionMenuWindow menuWindowWithFrame:CGRectMake(0, 0, 300, 300) itemSize:CGSizeMake(50, 50)];
    [menuView.centerButton setImage:[UIImage imageNamed:@"aws-icon"] forState:UIControlStateNormal];
    menuView.shouldOpenWhenViewWillAppear = NO;
    menuView.shouldHiddenCenterButtonWhenOpen = YES;
    menuView.shouldCloseWhenDeviceOrientationDidChange = YES;
    UIImage *image = [UIImage imageNamed:@"mm.jpg"];
    menuView.backgroundImageView.image = image;
    menuView.delegate = self;
    HypotenuseAction *item = nil;
    {
        item = [HypotenuseAction actionWithType:UIButtonTypeCustom handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            XYLog(@"222");
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:@"apple-icon"] forState:UIControlStateNormal];
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
    }
    
    {
        item = [HypotenuseAction actionWithType:UIButtonTypeCustom handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setTitle:@"Google" forState:UIControlStateNormal];
        item.hypotenuseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    }

    
    
    [menuView showWithCompetion:NULL];
    
}



/// 多级菜单使用
- (void)sample {
    
    SuspensionMenuWindow *menuView = [SuspensionMenuWindow menuWindowWithFrame:CGRectMake(0, 0, 300, 300) itemSize:CGSizeMake(50, 50)];
    [menuView.centerButton setImage:[UIImage imageNamed:@"aws-icon"] forState:UIControlStateNormal];
    [self addDoubleClickOnButton:menuView.centerButton];
    
    menuView.shouldOpenWhenViewWillAppear = NO;
    menuView.shouldHiddenCenterButtonWhenOpen = YES;
    menuView.shouldCloseWhenDeviceOrientationDidChange = YES;
    UIImage *image = [UIImage imageNamed:@"mm.jpg"];
    menuView.backgroundImageView.image = image;
    
    NSMutableArray *types = [NSMutableArray array];
    NSMutableArray *images = [NSMutableArray array];
    int i = 0;
    while (i <= 7) {
        UIButtonType type = UIButtonTypeCustom;
        NSString *imageNamed = @"aws-icon";
        if (i == 1) {
            type = UIButtonTypeCustom;
            imageNamed = @"apple-icon";
        }
        if (i == 2) {
            type = UIButtonTypeSystem;
            imageNamed = @"blip-icon";
        }
        if (i == 4) {
            type = UIButtonTypeSystem;
            imageNamed = @"dropbox-icon";
        }
        [types addObject:@(type)];
        [images addObject:imageNamed];
        i++;
    }
    i--;
    HypotenuseAction *item = nil;
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            [menuView showViewController:getViewController() animated:YES];
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == UIButtonTypeSystem) {
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:UIButtonTypeSystem handler:NULL];
        [menuView addAction:item];
        [item.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
        {
            HypotenuseAction *itemM = nil;
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
        }
        i--;
    }
    
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            [menuView showViewController:getViewController() animated:YES];
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == UIButtonTypeSystem) {
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:UIButtonTypeSystem handler:NULL];
        [menuView addAction:item];
        [item.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
        
        {
            HypotenuseAction *itemM = nil;
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            [menuView showViewController:getViewController() animated:YES];
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == UIButtonTypeSystem) {
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            [menuView showViewController:getViewController() animated:YES];
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == UIButtonTypeSystem) {
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
        }
        
        {
            HypotenuseAction *itemM = nil;
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    [menuView showViewController:getViewController() animated:YES];
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
        }
        
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            [menuView showViewController:getViewController() animated:YES];
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == UIButtonTypeSystem) {
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            [menuView showViewController:getViewController() animated:YES];
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == UIButtonTypeCustom) {
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    
    [menuView showWithCompetion:NULL];

}

NS_INLINE UIViewController *getViewController() {
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
    return vc;
}

/// 给按钮添加双击事件
- (void)addDoubleClickOnButton:(UIButton *)btn {
    [btn addTarget:self action:@selector(btnTouchDownAction:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(btnRepeatTouchDownAction:) forControlEvents:UIControlEventTouchDownRepeat];
}

- (void)btnTouchDownAction:(UIButton *)btn {
    [self performSelector:@selector(btnDoubleClick:) withObject:btn afterDelay:0.2];
}

- (void)btnRepeatTouchDownAction:(UIButton *)btn {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(btnDoubleClick:) object:btn];
    [self btnDoubleClick:btn];
}

- (void)btnDoubleClick:(UIButton *)btn {
    [[UIApplication sharedApplication] xy_showConsole];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - SuspensionMenuViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedCenterButton:(SuspensionView *)centerButton {
    
}

- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedHypotenuseButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 3) {
        
        UIViewController *vc = [UIViewController new];
        [suspensionMenuView showViewController:vc animated:YES];
    }
    if (buttonIndex == 4) {
        
        UITableViewController *vc = [UITableViewController new];
        [suspensionMenuView showViewController:vc animated:YES];
    }
}


- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedMoreButtonAtIndex:(NSInteger)buttonIndex fromHypotenuseItem:(HypotenuseAction *)hypotenuseItem {
    if (buttonIndex < 2) {
        UIViewController *vc = [UIViewController new];
        [suspensionMenuView showViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
