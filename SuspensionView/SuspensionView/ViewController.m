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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:3];
    int i = 0;
    
    while (i <= 5) {
        
        MenuBarHypotenuseButton *btn = [MenuBarHypotenuseButton new];
        [btn setImage:[UIImage imageNamed:@"partner_boobuz"] forState:UIControlStateNormal];
        [a addObject:btn];
        i++;
    }
    SuspensionMenuWindow *menuView = [SuspensionMenuWindow showOnce:YES menuBarItems:a];

    [menuView.centerButton setBackgroundImage:[UIImage imageNamed:@"message_keyboard"] forState:UIControlStateNormal];
    
    __block __weak typeof(menuView) weakMenuView = menuView;
    menuView.menuBarClickBlock = ^(NSInteger index) {
        
        if (index < 3) {
            
            UIViewController *vc = [UIViewController new];
            vc.view.backgroundColor = [UIColor whiteColor];
            [weakMenuView pushViewController:vc];
        }
    };

   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    
    return cell;
}



@end
