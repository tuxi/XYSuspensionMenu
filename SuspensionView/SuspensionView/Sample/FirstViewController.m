//
//  FirstViewController.m
//  SuspensionView
//
//  Created by Ossey on 2017/5/21.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "FirstViewController.h"
#import "SuspensionControl.h"
#import "OSTestViewController.h"
#import "ViewController.h"
#import "SecondViewController.h"

#pragma mark *** Sample ***

@interface FirstViewController () <SuspensionMenuViewDelegate>

@end

@implementation FirstViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self sample1ForDelegate];
//    [self sample2ForBlock];
    
}


/// 第二种创建方法，按钮的点击事件由block处理
- (void)sample2ForBlock {
    
    SuspensionMenuWindow *menuView = [[SuspensionMenuWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    menuView.isOnce = YES;
    menuView.shouldShowWhenViewWillAppear = NO;
    menuView.shouldHiddenCenterButtonWhenShow = YES;
    menuView.shouldDismissWhenDeviceOrientationDidChange = YES;
    
    NSMutableArray *types = [NSMutableArray array];
    NSMutableArray *images = [NSMutableArray array];
    int i = 0;
    while (i <= 7) {
        OSButtonType type = OSButtonType3;
        NSString *imageNamed = @"aws-icon";
        if (i == 1) {
            type = OSButtonType1;
            imageNamed = @"apple-icon";
        }
        if (i == 2) {
            type = OSButtonType2;
            imageNamed = @"blip-icon";
        }
        if (i == 4) {
            type = OSButtonType4;
            imageNamed = @"dropbox-icon";
        }
        [types addObject:@(type)];
        [images addObject:imageNamed];
        i++;
    }
    i--;
    HypotenuseAction *item = nil;
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == OSButtonType1) {
            [item.hypotenuseButton setSubtitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:OSButtonType1 handler:^(HypotenuseAction * _Nonnull action) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
        
        {
            HypotenuseAction *itemM = nil;
            {
              itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
        }
        i--;
    }
    
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == OSButtonType1) {
            [item.hypotenuseButton setSubtitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:OSButtonType1 handler:^(HypotenuseAction * _Nonnull action) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
        
        {
            HypotenuseAction *itemM = nil;
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == OSButtonType1) {
            [item.hypotenuseButton setSubtitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == OSButtonType1) {
            [item.hypotenuseButton setSubtitle:@"Apple" forState:UIControlStateNormal];
        }
        
        {
            HypotenuseAction *itemM = nil;
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
            }
        }
        
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == OSButtonType1) {
            [item.hypotenuseButton setSubtitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == OSButtonType1) {
            [item.hypotenuseButton setSubtitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    
    [menuView prepareForAppearWithActionSize:CGSizeMake(50, 50)];
    
    UIImage *image = [UIImage imageNamed:@"mm.jpg"];
    menuView.backgroundImageView.image = image;
    [menuView.centerButton setImage:[UIImage imageNamed:@"partner_boobuz"] forState:UIControlStateNormal];
    

}


/// 第一种创建方式，按钮的点击事件由代理回调处理
- (void)sample1ForDelegate {
    
    SuspensionMenuWindow *menuView = [[SuspensionMenuWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    menuView.isOnce = YES;
    menuView.shouldShowWhenViewWillAppear = NO;
    menuView.shouldHiddenCenterButtonWhenShow = YES;
    menuView.shouldDismissWhenDeviceOrientationDidChange = YES;
    menuView.delegate = self;


    int i = 0;
    
    while (i <= 7) {
        OSButtonType type = OSButtonType3;
        NSString *imageNamed = @"aws-icon";
        if (i == 1) {
            type = OSButtonType1;
            imageNamed = @"apple-icon";
        }
        if (i == 2) {
            type = OSButtonType2;
            imageNamed = @"blip-icon";
        }
        if (i == 4) {
            type = OSButtonType4;
            imageNamed = @"dropbox-icon";
        }
        HypotenuseAction *item = [[HypotenuseAction alloc] initWithButtonType:type];
        if (i == 1) {
            NSInteger j = 0;
            while (j <= 4) {
                HypotenuseAction *itemM = [[HypotenuseAction alloc] initWithButtonType:type];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
                [item.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                if (j == 1) {
                    NSInteger k = 0;
                    while (k <= 5) {
                        HypotenuseAction *itemMM = [[HypotenuseAction alloc] initWithButtonType:type];
                        [itemMM.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                        [itemM.moreHypotenusItems addObject:itemMM];
                        [itemM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                        if (k == 1) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                HypotenuseAction *iteml = [[HypotenuseAction alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                
                                
                                if (l == 1) {
                                    NSInteger s = 0;
                                    while (s <= 7) {
                                        HypotenuseAction *items = [[HypotenuseAction alloc] initWithButtonType:type];
                                        [items.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                        [iteml.moreHypotenusItems addObject:items];
                                        [iteml.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                        s++;
                                    }
                                    
                                }
                                
                                l++;
                            }
                            
                        }
                        if (k == 2) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                HypotenuseAction *iteml = [[HypotenuseAction alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                l++;
                            }
                            
                        }
                        if (k == 4) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                HypotenuseAction *iteml = [[HypotenuseAction alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                l++;
                            }
                            
                        }
                        
                        k++;
                    }
                }
                
                if (j == 3) {
                    NSInteger k = 0;
                    while (k <= 5) {
                        HypotenuseAction *itemMM = [[HypotenuseAction alloc] initWithButtonType:type];
                        [itemMM.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                        [itemM.moreHypotenusItems addObject:itemMM];
                        [itemM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                        if (k == 1) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                HypotenuseAction *iteml = [[HypotenuseAction alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                l++;
                            }
                            
                        }
                        if (k == 3) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                HypotenuseAction *iteml = [[HypotenuseAction alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                l++;
                            }
                            
                        }
                        if (k == 5) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                HypotenuseAction *iteml = [[HypotenuseAction alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                l++;
                            }
                            
                        }
                        
                        k++;
                    }
                }
                
                j++;
            }
            
        }
        [item.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
        if (type == OSButtonType1) {
            [item.hypotenuseButton setSubtitle:@"Apple" forState:UIControlStateNormal];
        }

        [menuView addAction:item];
        i++;
    }
    
    [menuView prepareForAppearWithActionSize:CGSizeMake(50, 50)];
    
    UIImage *image = [UIImage imageNamed:@"mm.jpg"];
    menuView.backgroundImageView.image = image;
    [menuView.centerButton setImage:[UIImage imageNamed:@"partner_boobuz"] forState:UIControlStateNormal];
    
    /*
     __block __weak typeof(menuView) weakMenuView = menuView;
     menuView.menuBarClickBlock = ^(NSInteger index) {
     
     if (index < 3) {
     
     UIViewController *vc = [UIViewController new];
     vc.view.backgroundColor = [UIColor whiteColor];
     [weakMenuView testPushViewController:vc];
     }
     };
     
     */
}


////////////////////////////////////////////////////////////////////////
#pragma mark - SuspensionMenuViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedCenterButton:(SuspensionView *)centerButton {

}

- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedHypotenuseButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 3) {
        
        OSTestViewController *vc = [OSTestViewController new];
        [suspensionMenuView testPushViewController:vc animated:YES];
    }
    if (buttonIndex == 4) {
        
        ViewController *vc = [ViewController new];
        [suspensionMenuView testPushViewController:vc animated:YES];
    }
}


- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedMoreButtonAtIndex:(NSInteger)buttonIndex fromHypotenuseItem:(HypotenuseAction *)hypotenuseItem {
    if (buttonIndex < 2) {
        SecondViewController *vc = [SecondViewController new];
        [suspensionMenuView testPushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
