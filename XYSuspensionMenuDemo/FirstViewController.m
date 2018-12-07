//
//  FirstViewController.m
//  SuspensionView
//
//  Created by xiaoyuan on 2017/5/21.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import "FirstViewController.h"
#import "XYSuspensionMenu.h"
#import "XYConsoleView.h"

#pragma mark *** Sample ***

@interface NSString (CountString)
- (NSInteger)countOccurencesOfString:(NSString *)searchString;
@end

@implementation NSString (CountString)
- (NSInteger)countOccurencesOfString:(NSString*)searchString {
    NSInteger strCount = [self length] - [[self stringByReplacingOccurrencesOfString:searchString withString:@""] length];
    return strCount / [searchString length];
}

- (void)searchWithWDArray:(NSArray<NSString *> *)wdArray countBlock:(void (^)(NSString *coutStr))block {
    if (!self.length || !wdArray.count) {
        block(nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableString *sm = @"".mutableCopy;
        [wdArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull wd, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!wd.length) {
                return;
            }
            NSUInteger count = [self countOccurencesOfString:wd];
            [sm appendFormat:@"%@: 出现%ld次数\n", wd, count];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(sm);
            }
        });
    });
    
}
@end

@interface FirstViewController () <SuspensionMenuViewDelegate>

@end

@implementation FirstViewController

static NSString * const WDKEY = @"lg1+lg2=多少";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DLog(@"111");
    
    // 显示多级菜单的suspensionMenu
    [self sample];
    // 打印log测试
    [self testLog];

}


- (void)testRepeatInit {
    /// 测试重复创建
    [self oneLevelMenuSample];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sample];
        DLog(@"666");
    });
}

- (void)testLog {
    if (@available(iOS 10.0, *)) {
        [[NSThread currentThread] setName:@"main"];
        // 主线程执行
        NSTimer *timer = [NSTimer timerWithTimeInterval:3.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            static NSInteger i = 0;
            DLog(@"%li, current thread:%@", (long)i++, [NSThread currentThread].name);
            NSLog(@"Hello NSLog");
        }];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        // 子线程执行, 开启多条线程打印log 测试并发
        for (NSInteger i = 1; i<4; i++) {
            dispatch_async(dispatch_queue_create("testLog", DISPATCH_QUEUE_CONCURRENT), ^{
                NSString *seleString = [NSString stringWithFormat:@"myLog%ld", (long)i];
                [self.class addTask:NSSelectorFromString(seleString) identifier:seleString];
            });
            
        }
    }
}

+ (void)addTask:(SEL)selector identifier:(NSString *)identifier { @autoreleasepool {
        [[NSThread currentThread] setName:identifier];
        [NSTimer scheduledTimerWithTimeInterval:2
                                         target:self
                                       selector:selector
                                       userInfo:nil
                                        repeats:YES];
        
        NSThread *currentThread = [NSThread currentThread];
        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        
        BOOL isCancelled = [currentThread isCancelled];
        while (!isCancelled && [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
            isCancelled = [currentThread isCancelled];
        }
        
        NSAssert(NO, @"thread is die");
    }}

+ (void)myLog1 {
    static NSInteger i = 0;
    // 模拟耗时
    [NSThread sleepForTimeInterval:arc4random_uniform(8)];
    i++;
    DLog(@"i:%ld current thread:%@", i, [NSThread currentThread].name);
}

+ (void)myLog2 {
    static NSInteger i = 0;
    [NSThread sleepForTimeInterval:arc4random_uniform(5)];
    i++;
    DLog(@"i:%ld current thread:%@", i, [NSThread currentThread].name);
}


+ (void)myLog3 {
    static NSInteger i = 0;
    [NSThread sleepForTimeInterval:arc4random_uniform(3)];
    i++;
    DLog(@"i:%ld current thread:%@", i, [NSThread currentThread].name);
}

/// 一级菜单使用
- (void)oneLevelMenuSample {
    DLog(@"111");
    XYSuspensionMenu *menuView = [XYSuspensionMenu menuWindowWithFrame:CGRectMake(0, 0, 280, 300) itemSize:CGSizeMake(50, 50)];
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
            DLog(@"222");
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
    
   XYSuspensionMenu *menuView = [XYSuspensionMenu menuWindowWithFrame:CGRectMake(0, 0, 280, 300) itemSize:CGSizeMake(50, 50)];
    [menuView.centerButton setImage:[UIImage imageNamed:@"aws-icon"] forState:UIControlStateNormal];
    
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
            [[UIApplication sharedApplication] xy_toggleConsoleWithCompletion:^(BOOL finished) {
                [menuView close];
            }];
        }];
        [menuView addAction:item];
        item.hypotenuseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [item.hypotenuseButton setBackgroundColor:[UIColor blackColor]];
        [item.hypotenuseButton setTitle:@"Console" forState:UIControlStateNormal];
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
