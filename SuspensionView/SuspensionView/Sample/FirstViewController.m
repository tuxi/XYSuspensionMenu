//
//  FirstViewController.m
//  SuspensionView
//
//  Created by Ossey on 2017/5/21.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "FirstViewController.h"
#import "XYSuspensionMenu.h"
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
    
    [self sample2Block];
    
}

/// 一级菜单使用
- (void)oneLevelMenuSample {
    
    SuspensionMenuWindow *menuView = [[SuspensionMenuWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 300) itemSize:CGSizeMake(50, 50)];
    [menuView.centerButton setImage:[UIImage imageNamed:@"partner_boobuz"] forState:UIControlStateNormal];
    menuView.shouldOpenWhenViewWillAppear = NO;
    menuView.shouldHiddenCenterButtonWhenOpen = YES;
    menuView.shouldCloseWhenDeviceOrientationDidChange = YES;
    UIImage *image = [UIImage imageNamed:@"mm.jpg"];
    menuView.backgroundImageView.image = image;
    menuView.delegate = self;
    HypotenuseAction *item = nil;
    {
        item = [HypotenuseAction actionWithType:UIButtonTypeCustom handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            
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
    }

    
    
    [menuView showWithCompetion:NULL];
    
}



/// 多级菜单使用
- (void)sample2Block {
    
    SuspensionMenuWindow *menuView = [[SuspensionMenuWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 300) itemSize:CGSizeMake(50, 50)];
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
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == UIButtonTypeSystem) {
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:UIButtonTypeSystem handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
        
        {
            HypotenuseAction *itemM = nil;
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
        }
        i--;
    }
    
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if ([types[i] integerValue] == UIButtonTypeSystem) {
            [item.hypotenuseButton setTitle:@"Apple" forState:UIControlStateNormal];
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:UIButtonTypeSystem handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            
        }];
        [menuView addAction:item];
        [item.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
        
        {
            HypotenuseAction *itemM = nil;
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
        }
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            
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
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
            
            {
                itemM  = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
                    
                }];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
                [item addMoreAction:itemM];
            }
        }
        
        i--;
    }
    
    {
        item = [HypotenuseAction actionWithType:[types[i] integerValue] handler:^(HypotenuseAction * _Nonnull action, SuspensionMenuView * _Nonnull menuView) {
            
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
