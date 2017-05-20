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
    
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    static const CGFloat menuView_wh = 280.0;
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect centerMenuFrame =
    CGRectMake((self.view.frame.size.width - menuView_wh) * 0.5, (self.view.frame.size.height - menuView_wh) * 0.5, menuView_wh, menuView_wh);
    
    SuspensionMenuWindow *menuView = [SuspensionMenuWindow showOnce:YES frame:centerMenuFrame];
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:1];
    int i = 0;
    while (i <= 3) {
        UIImage *im = [UIImage imageNamed:@"partner_boobuz"];
        [a addObject:im];
        i++;
    }
    
    
    [menuView setMenuBarImages:a];
    [menuView setCenterBarBackgroundImage:[UIImage imageNamed:@"message_keyboard"]];
    __block __weak typeof(menuView) weakMenuView = menuView;
    menuView.menuBarClickBlock = ^(NSInteger index) {
        
        if (index < 3) {
            
            UIViewController *vc = [UIViewController new];
            vc.view.backgroundColor = [UIColor whiteColor];
            [weakMenuView pushViewController:vc];
            weakMenuView = nil;
        }
    };

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
