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
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:3];
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
        MenuBarHypotenuseItem *item = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
        if (i == 1) {
            NSInteger j = 0;
            while (j <= 4) {
                MenuBarHypotenuseItem *itemM = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
                [itemM.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                [item.moreHypotenusItems addObject:itemM];
                [item.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                if (j == 1) {
                    NSInteger k = 0;
                    while (k <= 5) {
                        MenuBarHypotenuseItem *itemMM = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
                        [itemMM.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                        [itemM.moreHypotenusItems addObject:itemMM];
                        [itemM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                        if (k == 1) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                MenuBarHypotenuseItem *iteml = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                
                                
                                if (l == 1) {
                                    NSInteger s = 0;
                                    while (s <= 7) {
                                        MenuBarHypotenuseItem *items = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
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
                                MenuBarHypotenuseItem *iteml = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                l++;
                            }
                            
                        }
                        if (k == 4) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                MenuBarHypotenuseItem *iteml = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
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
                        MenuBarHypotenuseItem *itemMM = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
                        [itemMM.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                        [itemM.moreHypotenusItems addObject:itemMM];
                        [itemM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                        if (k == 1) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                MenuBarHypotenuseItem *iteml = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                l++;
                            }
                            
                        }
                        if (k == 3) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                MenuBarHypotenuseItem *iteml = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
                                [iteml.hypotenuseButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
                                [itemMM.moreHypotenusItems addObject:iteml];
                                [itemMM.hypotenuseButton setTitle:@"more" forState:UIControlStateNormal];
                                l++;
                            }
                            
                        }
                        if (k == 5) {
                            NSInteger l = 0;
                            while (l <= 7) {
                                MenuBarHypotenuseItem *iteml = [[MenuBarHypotenuseItem alloc] initWithButtonType:type];
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
        [a addObject:item];
        i++;
    }
    
    SuspensionMenuWindow *menuView = [[SuspensionMenuWindow alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    menuView.isOnce = YES;
    menuView.shouldShowWhenViewWillAppear = NO;
    menuView.shouldHiddenCenterButtonWhenShow = YES;
    menuView.shouldDismissWhenDeviceOrientationDidChange = YES;
    [menuView setMenuBarItems:a itemSize:CGSizeMake(50, 50)];
    menuView.delegate = self;
    
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
        [suspensionMenuView testPushViewController:vc];
    }
    if (buttonIndex == 4) {
        
        ViewController *vc = [ViewController new];
        [suspensionMenuView testPushViewController:vc];
    }
}


- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedMoreButtonAtIndex:(NSInteger)buttonIndex fromHypotenuseItem:(MenuBarHypotenuseItem *)hypotenuseItem {
    if (buttonIndex < 2) {
        SecondViewController *vc = [SecondViewController new];
        [suspensionMenuView testPushViewController:vc];
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
