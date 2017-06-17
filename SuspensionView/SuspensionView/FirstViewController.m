//
//  FirstViewController.m
//  SuspensionView
//
//  Created by Ossey on 2017/5/21.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "FirstViewController.h"
#import "SuspensionControl.h"
#import "SuspensionView.h"
#import "SuspensionMenuView.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:3];
    int i = 0;
    
    while (i <= 5) {
        
        MenuBarHypotenuseItem *item = [MenuBarHypotenuseItem new];
        [item.hypotenuseButton setImage:[UIImage imageNamed:@"aws-icon"]];
        [a addObject:item];
        i++;
    }
    
    SuspensionMenuWindow *menuView = [[SuspensionMenuWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    menuView.isOnce = YES;
    menuView.shouldShowWhenViewWillAppear = NO;
    [menuView setMenuBarItems:a itemSize:CGSizeMake(64, 64)];
    
    UIImage *image = [UIImage imageNamed:@"mm.jpg"];
    menuView.backgroundImageView.image = image;
    [menuView.centerButton setImage:[UIImage imageNamed:@"aws-icon"]];
    
    __block __weak typeof(menuView) weakMenuView = menuView;
    menuView.menuBarClickBlock = ^(NSInteger index) {
        
        if (index < 3) {
            
            UIViewController *vc = [UIViewController new];
            vc.view.backgroundColor = [UIColor whiteColor];
            [weakMenuView pushViewController:vc];
        }
    };
    


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
