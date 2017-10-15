# iOS 屏幕滑动控件, 类似 AssistiveTouch 悬浮窗

![image](https://github.com/Ossey/SuspensionControl/blob/master/SuspensionView/SuspensionView/2017-07-16%2022_03_44.gif)

# 使用方式
1. 通过cocoaPods导入，在你的profile中添加
```
pod 'XYSuspensionMenu', '~> 1.0'
```
 或者直接将'SuspensionControl' 添加到您的项目中
 
 2. 代码示例:
 
 - 一级菜单使用: 如果只需要在SuspensionMenuView上展示一级菜单，添加以下代码即可:
 ```
 /// 一级菜单使用:添加主菜单上的按钮
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
        item.hypotenuseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
 

    [menuView showWithCompetion:NULL];
 
 }
 ```
 
 - 多级菜单: 给对应的Action添加MoreAction，如下示例:
 
 ```
 - (void)sample {
 
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
 ```



