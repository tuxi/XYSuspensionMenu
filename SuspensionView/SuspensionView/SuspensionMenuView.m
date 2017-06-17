//
//  SuspensionMenuView.m
//  SuspensionView
//
//  Created by Ossey on 2017/6/16.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "SuspensionMenuView.h"
#import "SuspensionControl.h"
#import <objc/runtime.h>

@implementation SuspensionWindow

#pragma mark - public methods


+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame {
    
    SuspensionWindow *s = [[self alloc] initWithFrame:frame];
    s.leanEdgeType = SuspensionViewLeanEdgeTypeEachSide;
    s.isOnce = isOnce;
    [s _moveToSuperview];
    
    return s;
}

- (void)dismiss:(void (^)(void))block {
    
    if (block) {
        block();
    }
    self.clickCallBack = nil;
    self.leanFinishCallBack = nil;
    [SuspensionControl removeWindowForKey:self.key];
    [self removeFromSuperview];
    
}

+ (void)releaseAll {
    
    NSDictionary *temp = [[SuspensionControl windows] mutableCopy];
    [temp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIWindow * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.suspensionView && !obj.suspensionMenuView) {
            [SuspensionControl removeWindow:obj];
        }
    }];
    temp = nil;
}

#pragma mark - Private methods

- (void)_moveToSuperview {
    
    UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    UIWindow *suspensionWindow = [[UIWindow alloc] initWithFrame:self.frame];
    
#ifdef DEBUG
    suspensionWindow.windowLevel = CGFLOAT_MAX+10;
#else
    suspensionWindow.windowLevel = UIWindowLevelAlert * 3;
#endif
    [suspensionWindow makeKeyAndVisible];
    // 给window设置rootViewController是为了当屏幕旋转时，winwow跟随旋转并更新坐标
    UIViewController *vc = [UIViewController new];
    suspensionWindow.rootViewController = vc;
    // 不设置此属性，window在选择时，会出现四周黑屏现象
    [suspensionWindow.layer setMasksToBounds:YES];
    
    [SuspensionControl setWindow:suspensionWindow forKey:self.key];
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.clipsToBounds = YES;
    
    [vc.view addSubview:self];
    
    suspensionWindow.suspensionView = self;
    
    // 保持原先的keyWindow，避免一些不必要的问题
    [currentKeyWindow makeKeyWindow];
    
}

@end

static const CGFloat menuBarBaseTag = 100;

@interface SuspensionMenuView () {
@private
    CGFloat _defaultTriangleHypotenuse;     // 默认关闭时的三角斜边
    CGFloat _minBounceOfTriangleHypotenuse; // 当第一次显示完成后的三角斜边
    CGFloat _maxBounceOfTriangleHypotenuse; // 当显示时要展开的三角斜边
    CGFloat _maxTriangleHypotenuse;         // 最大三角斜边，当第一次刚出现时三角斜边
    CGRect _memuBarButtonOriginFrame;       // 每一个菜单上按钮的原始frame 除中心的按钮 关闭时也可使用,重叠
    
    BOOL _isInProcessing;    // 是否正在执行显示或消失
    BOOL _isShow;            // 是否已经显示
    BOOL _isDismiss;         // 是否已经消失
    BOOL _isFiristShow;      // 是否第一次显示
    BOOL _isFiristDismiss;   // 是否第一次消失
    CGSize _itemSize;
    CGSize _menuWindowSize;
    CGSize _centerWindowSize;
}

@property (nonatomic, assign) BOOL isOnce;
@property (nonatomic, weak) SuspensionView *centerButton;
@property (nonatomic, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) UIVisualEffectView *visualEffectView;

@end

@implementation SuspensionMenuView

@synthesize centerButton = _centerButton;

#pragma mark - Public Methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setMenuSize:(CGSize)menuSize itemSize:(CGSize)itemSize {
    // 设置默认值
    if (menuSize.width == 0 || menuSize.height == 0) {
        menuSize = CGSizeMake(280.0, 280.0);
    }
    if (itemSize.width == 0 || itemSize.height == 0) {
        itemSize = CGSizeMake(64.0, 64.0);
    }
    _menuWindowSize = menuSize;
    _itemSize = itemSize;
    _centerWindowSize = itemSize;
    
    [self setupLayout];
}


- (void)setMenuBarItems:(NSArray<MenuBarHypotenuseItem *> *)menuBarItems {
    
    _menuBarItems = menuBarItems;
    
    NSInteger idx = 0;
    for (MenuBarHypotenuseItem *item in menuBarItems) {
        [item.hypotenuseButton setOpaque:NO];
        [item.hypotenuseButton setTag:menuBarBaseTag+idx+1];
        [item.hypotenuseButton addTarget:self action:@selector(menuBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [item.hypotenuseButton setAlpha:0.0];
        [self addSubview:item.hypotenuseButton];
        [item.hypotenuseButton setFrame:_memuBarButtonOriginFrame];
        idx++;
    }
}

//// Push View Controller
- (void)pushViewController:(UIViewController *)viewController {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         // 在中心视图中滑动按钮并隐藏
                         [self updateMenuBarButtonLayoutWithTriangleHypotenuse:_maxTriangleHypotenuse];
                         [self setAlpha:0.0];
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"MenuBarHypotenuseButton")]) {
                                 [btn setAlpha:0.0];
                             }
                         }
                         [self.centerButton moveToPreviousLeanPosition];
                         
                     } completion:^(BOOL finished) {
                         [[self topViewController].navigationController pushViewController:viewController animated:YES];
                         UIWindow *menuWindow = [SuspensionControl windowForKey:self.key];
                         CGRect menuFrame =  menuWindow.frame;
                         menuFrame.size = CGSizeZero;
                         menuWindow.frame = menuFrame;
                         _isDismiss = YES;
                         _isShow = NO;
                     }];
}


- (void)show {
    if (_isShow) return;
    
    if (_isFiristShow) {
        [self updateMenuBarButtonLayoutWithTriangleHypotenuse:_maxTriangleHypotenuse];
    }
    
    if (_shouldLeanToScreenCenterWhenShow) {
        [self.centerButton moveToScreentCenter];
    }
    
    UIWindow *menuWindow = [SuspensionControl windowForKey:self.key];
    
    [self centerButton];
    [self _updateMenuViewCenterWithIsShow:YES];
    
    _isInProcessing = YES;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         [menuWindow setAlpha:1.0];
                         [self setAlpha:1.0];
                         
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"MenuBarHypotenuseButton")]) {
                                 [btn setAlpha:1.0];
                             }
                         }
                         
                         // 更新menu bar 的 布局
                         CGFloat triangleHypotenuse = 0.0;
                         if (_isFiristShow) {
                             triangleHypotenuse = _minBounceOfTriangleHypotenuse;
                         } else {
                             triangleHypotenuse = _maxBounceOfTriangleHypotenuse;
                         }
                         [self updateMenuBarButtonLayoutWithTriangleHypotenuse:triangleHypotenuse];
                     }
                     completion:^(BOOL finished) {
                         // 此处动画结束时,menuWindow的bounds为CGRectZero了,原因是动画时间相错
                         //                         NSLog(@"%@", NSStringFromCGRect(menuWindow.frame));
                         //                         if (menuWindow.frame.size.width == 0 || menuWindow.frame.size.height == 0) {
                         //                             NSLog(@"为0了");
                         //                             [self _updateMenuViewCenterWithIsShow:YES];
                         //                         }
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              [self updateMenuBarButtonLayoutWithTriangleHypotenuse:_defaultTriangleHypotenuse];
                                          }
                                          completion:^(BOOL finished) {
                                              _isShow = YES;
                                              _isDismiss = NO;
                                              _isInProcessing = NO;
                                              _isFiristShow = NO;
                                              if (self.showCompletion) {
                                                  self.showCompletion();
                                              }
                                              
                                          }];
                     }];
}

- (void)dismiss {
    [self _dismissWithTriggerPanGesture:NO];
}

/// 执行dismiss，并根据当前是否触发了拖动手势，确定是否在让SuapensionWindow执行移动边缘的操作，防止移除时乱窜
- (void)_dismissWithTriggerPanGesture:(BOOL)isTriggerPanGesture {
    
    if (_isDismiss)
        return;
    
//    if (_isFiristDismiss) {
//        // 检测边缘
//        [self.centerButton checkTargetPosition];
//    }
//    
    _isInProcessing = YES;
    
    // 隐藏menu bar button
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         for (UIButton * button in [self subviews])
                             [button setFrame:_memuBarButtonOriginFrame];
                         [self setAlpha:0.0];
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"MenuBarHypotenuseButton")]) {
                                 [btn setAlpha:0.0];
                             }
                         }
                         
                         if (!isTriggerPanGesture) {
                             [self.centerButton moveToPreviousLeanPosition];
                         }
                         
                     } completion:^(BOOL finished) {
                         UIWindow *menuWindow = [SuspensionControl windowForKey:self.key];
                         
                         [UIView animateWithDuration:0.1 animations:^{
                             [menuWindow setAlpha:0.0];
                             // 让其frame为zero，为了防止其隐藏后所在的位置无法响应事件
                         } completion:^(BOOL finished) {
                             CGRect menuFrame =  menuWindow.frame;
                             menuFrame.size = CGSizeZero;
                             menuWindow.frame = menuFrame;
                             if (self.dismissCompletion) {
                                 self.dismissCompletion();
                             }
                             _isDismiss = YES;
                             _isShow  = NO;
                             _isInProcessing = NO;
                             _isFiristDismiss = NO;
                         } ];
                         
                     }];
}


#pragma mark - 初始化

- (SuspensionView *)centerButton {
    if (_centerButton == nil) {
        // 创建中心按钮
        CGRect centerButtonFrame = CGRectMake((CGRectGetWidth(self.frame) - _centerWindowSize.width) * 0.5, (CGRectGetHeight(self.frame) - _centerWindowSize.height) * 0.5, _centerWindowSize.width, _centerWindowSize.height);
        
        CGRect centerRec = [self convertRect:centerButtonFrame toView:[UIApplication sharedApplication].delegate.window];
        
        SuspensionView *centerButton = (SuspensionWindow *)[NSClassFromString(@"_MenuBarCenterButton") showOnce:YES frame:centerRec];
        
        centerButton.autoLeanEdge = YES;
        
        [centerButton addTarget:self action:@selector(centerBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(centerButton) weakCenterButton = centerButton;
        centerButton.locationChange = ^(CGPoint currentPoint) {
            weakSelf.center = currentPoint;
            if (weakCenterButton.panGestureRecognizer.state == UIGestureRecognizerStateEnded || weakCenterButton.panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [weakCenterButton moveToPreviousLeanPosition];
            }
            if (weakCenterButton.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
                [weakSelf _dismissWithTriggerPanGesture:YES];
            }
        };
        
        _centerButton = centerButton;
        
    }
    return _centerButton;
}


- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        UIImageView *imageView = [NSClassFromString(@"_MenuViewBackgroundImageView") new];
        _backgroundImageView = imageView;
        imageView.userInteractionEnabled = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        [self insertSubview:imageView atIndex:0];
        imageView.frame = self.bounds;
        [self visualEffectView];
    }
    return _backgroundImageView;
}

- (UIVisualEffectView *)visualEffectView {
    if (_visualEffectView == nil) {
        UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct];
        visualEffectView.frame = self.bounds;
        visualEffectView.alpha = 1.0;
        [self addSubview:visualEffectView];
        _visualEffectView = visualEffectView;
    }
    if (_backgroundImageView) {
        [self insertSubview:_visualEffectView aboveSubview:_backgroundImageView];
    } else {
        [self insertSubview:_visualEffectView atIndex:0];
    }
    return _visualEffectView;
}

- (void)setup {
    
    _isInProcessing = NO;
    _isShow  = NO;
    _isDismiss = YES;
    _isFiristShow = YES;
    _isFiristDismiss = YES;
    _shouldLeanToScreenCenterWhenShow = YES;
    
    self.autoresizingMask = UIViewAutoresizingNone;
    self.layer.cornerRadius = 12.8;
    [self.layer setMasksToBounds:YES];
    [self setClipsToBounds:YES];
    [self visualEffectView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
}

- (void)setupLayout {
    
    // 设置三角斜边
    _defaultTriangleHypotenuse = (_menuWindowSize.width - _itemSize.width) * 0.5;
    _minBounceOfTriangleHypotenuse = _defaultTriangleHypotenuse - 12.0;
    _maxBounceOfTriangleHypotenuse = _defaultTriangleHypotenuse + 12.0;
    _maxTriangleHypotenuse = kSCREENT_HEIGHT * 0.5;
    
    // 计算menu 上 按钮的 原始 frame 当dismiss 时 回到原始位置
    CGFloat originX = (_menuWindowSize.width - _centerWindowSize.width) * 0.5;
    _memuBarButtonOriginFrame = CGRectMake(originX,
                                           originX,
                                           _centerWindowSize.width,
                                           _centerWindowSize.height);
}



#pragma mark - Events

// 中心 button 点击事件
- (void)centerBarButtonClick:(UIButton *)btn {
    _isDismiss ? [self show] : [self dismiss];
}

// 斜边的 button 点击事件 button tag 如下图:
//
// TAG:        1       1   2      1   2     1   2     1 2 3     1 2 3
//            \|/       \|/        \|/       \|/       \|/       \|/
// COUNT: 1) --|--  2) --|--   3) --|--  4) --|--  5) --|--  6) --|--
//            /|\       /|\        /|\       /|\       /|\       /|\
// TAG:                             3       3   4     4   5     4 5 6
//
- (void)menuBarButtonClick:(id)sender {
    if (_menuBarClickBlock) {
        _menuBarClickBlock([(UIButton *)sender tag] - menuBarBaseTag - 1);
    }
}

- (void)orientationDidChange:(NSNotification *)note {
    
    [self _updateMenuViewCenterWithIsShow:_isShow];
}


#pragma mark - Private methods

- (void)_updateMenuViewCenterWithIsShow:(BOOL)isShow {
    if (isShow) {
        UIWindow *menuWindow = [SuspensionControl windowForKey:self.key];
        menuWindow.frame = [UIScreen mainScreen].bounds;
        NSLog(@"%@", NSStringFromCGRect(menuWindow.frame));
        menuWindow.rootViewController.view.frame =  menuWindow.bounds;
        UIWindow *centerWindow = [SuspensionControl windowForKey:self.centerButton.key];
        CGRect centerFrame =  centerWindow.frame;
        centerFrame.size = CGSizeMake(_centerWindowSize.width, _centerWindowSize.height);
        centerWindow.frame = centerFrame;
        
        CGPoint newCenter = [centerWindow convertPoint:self.centerButton.center toView:[UIApplication sharedApplication].delegate.window];
        self.center = newCenter;
        
        if (_backgroundImageView) {
            self.backgroundImageView.frame = self.bounds;
            if (_visualEffectView) {
                [self insertSubview:_visualEffectView aboveSubview:_backgroundImageView];
            }
        }
        if (_visualEffectView) {
            self.visualEffectView.frame = self.bounds;
            if (!_backgroundImageView) {
                [self insertSubview:_visualEffectView atIndex:0];
            }
        }
    }
}

/// 设置按钮的 位置
- (void)_setButtonWithTag:(NSInteger)buttonTag origin:(CGPoint)origin {
    
    if (buttonTag < menuBarBaseTag) {
        buttonTag = menuBarBaseTag + buttonTag;
    }
    
    UIButton * button = (UIButton *)[self viewWithTag:buttonTag];
    if (button) {
        [button setFrame:CGRectMake(origin.x, origin.y, self.centerButton.frame.size.width, self.centerButton.frame.size.height)];
        button = nil;
    }
}


- (void)updateMenuBarButtonLayoutWithTriangleHypotenuse:(CGFloat)triangleHypotenuse {
    //
    //  Triangle Values for Buttons' Position
    //
    //      /|      a: triangleA = c * cos(x)
    //   c / | b    b: triangleB = c * sin(x)
    //    /)x|      c: triangleHypotenuse  三角斜边
    //   -----      x: degree    度数
    //     a
    //
    // menuView的半径
    CGFloat menuWindowRadius = _menuWindowSize.width * 0.5;
    // centerButton的半径
    CGFloat centerWindowRadius = _centerWindowSize.width * 0.5;
    if (! triangleHypotenuse) {
        // 距离中心
        triangleHypotenuse = _defaultTriangleHypotenuse;
    }
    //
    //      o       o   o      o   o     o   o     o o o     o o o
    //     \|/       \|/        \|/       \|/       \|/       \|/
    //  1 --|--   2 --|--    3 --|--   4 --|--   5 --|--   6 --|--
    //     /|\       /|\        /|\       /|\       /|\       /|\
    //                           o       o   o     o   o     o o o
    //
    if (_menuBarItems.count == 1) {
        
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius - triangleHypotenuse - centerWindowRadius)];
    }
    
    if (_menuBarItems.count == 2) {
        
        CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180 角度
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        CGFloat negativeValue = menuWindowRadius - triangleB - centerWindowRadius;
        CGFloat positiveValue = menuWindowRadius + triangleB - centerWindowRadius;
        [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
        [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
        
    }
    
    if (_menuBarItems.count == 3) {
        // = 360.0f / self.buttonCount * M_PI / 180.0f;
        // E.g: if |buttonCount_ = 6|, then |degree = 60.0f * M_PI / 180.0f|;
        // CGFloat degree = 2 * M_PI / self.buttonCount;
        //
        CGFloat degree    = M_PI / 3.0f; // = 60 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree);
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius + triangleHypotenuse - centerWindowRadius)];
    }
    if (_menuBarItems.count == 4) {
        CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        CGFloat negativeValue = menuWindowRadius - triangleB - centerWindowRadius;
        CGFloat positiveValue = menuWindowRadius + triangleB - centerWindowRadius;
        [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
        [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
        [self _setButtonWithTag:3 origin:CGPointMake(negativeValue, positiveValue)];
        [self _setButtonWithTag:4 origin:CGPointMake(positiveValue, positiveValue)];
    }
    
    if (_menuBarItems.count == 5) {
        CGFloat degree      = 2 * M_PI / _menuBarItems.count ; //= M_PI / 3.0;// = M_PI / 20.5; // = 72 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree);
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius - triangleHypotenuse - centerWindowRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        
        degree    = M_PI / 5.0f;  // = 36 * M_PI / 180
        triangleA = triangleHypotenuse * cosf(degree);
        triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:4 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
        [self _setButtonWithTag:5 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
    }
    
    if (_menuBarItems.count == 6) {
        CGFloat degree    = M_PI / 3.0f; // = 60 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree); // 斜边的余弦值
        CGFloat triangleB = triangleHypotenuse * sinf(degree); // 斜边正弦值
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius - triangleHypotenuse - centerWindowRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:4 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
        [self _setButtonWithTag:5 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius + triangleHypotenuse - centerWindowRadius)];
        [self _setButtonWithTag:6 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_menuBarItems.count) {
        [_menuBarItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _menuBarItems = nil;
    }
    self.showCompletion = nil;
    self.dismissCompletion = nil;
}

- (UIViewController *)topViewController {
    
    UINavigationController * navigationController = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if ([navigationController isKindOfClass:[UINavigationController class]]) {
        UIViewController * currentViewController = [navigationController topViewController];
        return currentViewController;
    }
    return nil;
}


- (NSString *)key {
    return _isOnce ? [[SuspensionControl shareInstance] keyWithIdentifier:NSStringFromClass([self class])] : [super key];
}

@end


@implementation SuspensionMenuWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

+ (instancetype)showWithMenuBarItems:(NSArray<MenuBarHypotenuseItem *> *)menuBarItems menuSize:(CGSize)menuSize itemSize:(CGSize)itemSize{
    
    SuspensionMenuWindow *windwow = [self showOnce:YES shouldShow:NO menuBarItems:menuBarItems];
    
    [windwow setMenuSize:menuSize itemSize:itemSize];
    
    return windwow;
}

/// 初始化SuspensionMenuWindow
/// @param isOnce     是否是全局唯一的
/// @param shouldShow 根据此参数确定在初始化完成后，是否立即显示
/// @return SuspensionMenuWindow
+ (instancetype)showOnce:(BOOL)isOnce shouldShow:(BOOL)shouldShow menuBarItems:(NSArray<MenuBarHypotenuseItem *> *)menuBarItems {
    CGRect centerMenuFrame = CGRectMake(0, 0, 320.0, 320.0);
    SuspensionMenuWindow *menuView = [self showOnce:isOnce frame:centerMenuFrame];
    menuView.menuBarItems = menuBarItems;
    menuView.shouldShowWhenViewWillAppear = shouldShow;
    
    return menuView;
}

- (void)setMenuSize:(CGSize)menuSize itemSize:(CGSize)itemSize {
    [super setMenuSize:menuSize itemSize:itemSize];
    [self _moveToSuperview];
    
    if (!self.shouldShowWhenViewWillAppear) {
        [self.centerButton checkTargetPosition];
    }
}

+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame {
    
    SuspensionMenuWindow *menuView = [[self alloc] initWithFrame:frame];
    [menuView setAlpha:1.0];
    menuView.isOnce = isOnce;
    return menuView;
}


- (void)dismiss:(void (^)(void))block {
    
    if (block) {
        block();
    }
    
    self.menuBarClickBlock = nil;
    [SuspensionControl removeWindowForKey:self.key];
    [self removeFromSuperview];
    
}

+ (void)releaseAll {
    
    NSDictionary *temp = [[SuspensionControl windows] mutableCopy];
    [temp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIWindow * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.suspensionMenuView && obj.suspensionView) {
            [SuspensionControl removeWindow:obj];
            [SuspensionControl removeWindowForKey:obj.suspensionView.key];
        }
    }];
    temp = nil;
}

#pragma mark - Private methods

- (void)_moveToSuperview {
    
    UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect menuWindowBounds = [UIScreen mainScreen].bounds;
    if (!_shouldShowWhenViewWillAppear) {
        menuWindowBounds = CGRectZero;
    }
    
    UIWindow *suspensionWindow = [[UIWindow alloc] initWithFrame:menuWindowBounds];
#ifdef DEBUG
    suspensionWindow.windowLevel = CGFLOAT_MAX;
    //    suspensionWindow.windowLevel = CGFLOAT_MAX+10;
    // iOS9前自定义的window设置下面，不会被键盘遮罩，iOS10不行了
    //    NSArray<UIWindow *> *widnows = [UIApplication sharedApplication].windows;
#else
    suspensionWindow.windowLevel = UIWindowLevelAlert * 2;
#endif
    [suspensionWindow makeKeyAndVisible];
    
    // 给window设置rootViewController是为了当屏幕旋转时，winwow跟随旋转并更新坐标
    
    UIViewController *vc = [[NSClassFromString(@"SuspensionMenuController") alloc] performSelector:@selector(initWithMenuView:) withObject:self];
    
    suspensionWindow.rootViewController = vc;
    // 不设置此属性，window在选择时，会出现四周黑屏现象
    [suspensionWindow.layer setMasksToBounds:YES];
    
    [SuspensionControl setWindow:suspensionWindow forKey:self.key];
    self.frame = CGRectMake((kSCREENT_WIDTH - self.frame.size.width) * 0.5, (kSCREENT_HEIGHT - self.frame.size.height) * 0.5, self.frame.size.width, self.frame.size.height);
    self.clipsToBounds = YES;
    
    [vc.view addSubview:self];
    
    suspensionWindow.suspensionMenuView = self;
    
    // 保持原先的keyWindow，避免一些不必要的问题
    [currentKeyWindow makeKeyWindow];
}

@end


@interface MenuBarHypotenuseItem ()
@property (nonatomic, strong) MenuBarHypotenuseButton *hypotenuseButton;
@end
@implementation MenuBarHypotenuseItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hypotenuseButton = [MenuBarHypotenuseButton new];
        
    }
    return self;
}

- (void)dealloc {
    [self.hypotenuseButton removeFromSuperview];
    self.hypotenuseButton = nil;
}

@end

@implementation MenuBarHypotenuseButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup {
    [self.titleLabel setFont:[UIFont systemFontOfSize:12 weight:1.0]];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}
@end

@interface _MenuBarCenterButton : SuspensionWindow
@end
@implementation _MenuBarCenterButton
@end

@interface _MenuViewBackgroundImageView : UIImageView
@end
@implementation _MenuViewBackgroundImageView
@end

@implementation UIWindow (SuspensionWindow)

- (void)setSuspensionView:(SuspensionView *)suspensionView {
    objc_setAssociatedObject(self, @selector(suspensionView), suspensionView, OBJC_ASSOCIATION_ASSIGN);
}

- (SuspensionView *)suspensionView {
    return objc_getAssociatedObject(self, @selector(suspensionView));
}

- (void)setSuspensionMenuView:(SuspensionMenuView * _Nullable)suspensionMenuView {
    objc_setAssociatedObject(self, @selector(suspensionMenuView), suspensionMenuView, OBJC_ASSOCIATION_ASSIGN);
}

- (SuspensionMenuView *)suspensionMenuView {
    return objc_getAssociatedObject(self, @selector(suspensionMenuView));
}
@end

@interface SuspensionMenuController : UIViewController

- (instancetype)initWithMenuView:(SuspensionMenuView *)menuView ;

@property (nonatomic, weak) SuspensionMenuWindow *menuView;

@end

@implementation SuspensionMenuController

- (instancetype)initWithMenuView:(SuspensionMenuWindow *)menuView {
    if (self = [super init]) {
        _menuView = menuView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_menuView.shouldShowWhenViewWillAppear) {
        [self.menuView performSelector:@selector(show)
                            withObject:nil
                            afterDelay:0.3];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.menuView dismiss];
    [self.nextResponder touchesEnded:touches withEvent:event];
}


@end
