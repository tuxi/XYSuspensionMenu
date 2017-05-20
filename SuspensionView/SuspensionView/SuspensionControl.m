//
//  SuspensionView.m
//  SuspensionView
//
//  Created by Ossey on 17/2/25.
//  Copyright © 2017年 Ossey All rights reserved.
//

#import "SuspensionControl.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/message.h>
#import "UIImage+Blur.h"


#define kSCREENT_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kSCREENT_WIDTH [UIScreen mainScreen].bounds.size.width

@interface UIResponder ()
@property (nonatomic) SuspensionView *suspensionView;

@end

@implementation UIResponder (SuspensionView)

- (SuspensionView *)showSuspensionViewWithFrame:(CGRect)frame {
    BOOL result = [self isKindOfClass:[UIViewController class]] || [self isKindOfClass:[UIView class]];
    NSAssert(result, @"当前类应为UIViewController或UIView或他们的子类");
    if (!self.suspensionView && !self.suspensionView.superview) {
        SuspensionView *sv = [[SuspensionView alloc] initWithFrame:frame];
        sv.clipsToBounds = YES;
        if ([self isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)self;
            [vc.view addSubview:sv];
        }
        if ([self isKindOfClass:[UIView class]]) {
            UIView *v = (UIView *)self;
            [v addSubview:sv];
        }
        self.suspensionView = sv;
    }
    if ([self isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)self;
        [vc.view bringSubviewToFront:self.suspensionView];
    } else if ([self isKindOfClass:[UIView class]]) {
        UIView *v = (UIView *)self;
        [v bringSubviewToFront:self.suspensionView];
    }
    
    return self.suspensionView;
}


- (void)dismissSuspensionView:(void (^)())block {
    
    [self.suspensionView removeFromSuperview];
    self.suspensionView = nil;
    if (block) {
        block();
    }
}

- (void)setHiddenSuspension:(BOOL)flag {
    self.suspensionView.hidden = flag;
}
- (BOOL)isHiddenSuspension {
    return self.suspensionView.isHidden;
}
- (void)setSuspensionTitle:(NSString *)title forState:(UIControlState)state {
    [self.suspensionView setTitle:title forState:state];
}
- (void)setSuspensionImage:(UIImage *)image forState:(UIControlState)state {
    [self.suspensionView setImage:image forState:state];
}
- (void)setSuspensionImageWithImageNamed:(NSString *)name forState:(UIControlState)state {
    if ([name isEqualToString:@"partner_expedia"]) {
//        [self setHiddenSuspension:YES];
//        self.suspensionView.invalidHidden = YES;
//        name = @"scallcentergroup2.png";
    }
    [self setSuspensionImage:[UIImage imageNamed:name] forState:state];
}

- (SuspensionView *)suspensionView {
    return objc_getAssociatedObject(self, @selector(suspensionView));
}

- (void)setSuspensionView:(SuspensionView *)suspensionView {
    objc_setAssociatedObject(self, @selector(suspensionView), suspensionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end


@interface SuspensionView ()

@property (nonatomic, copy) void (^moveFinishCallBack)();
@property (nonatomic, copy) void (^movingCallBack)();
@property (nonatomic, copy) void (^clickCallBack)();
@property (nonatomic, copy) void (^beginMoveCallBack)();
@property (nonatomic, assign) CGPoint previousCenter;
@property (nonatomic, copy) NSString *currentKey;
@property (nonatomic, assign) BOOL isOnce;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation SuspensionView

- (NSString *)currentKey {
    return _isOnce ? [[SuspensionControl shareInstance] keyWithIdentifier:NSStringFromClass([self class])] : self.key;
}


#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        [self addActions];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
        [self addActions];
    }
    return self;
}

- (void)setup {

    self.moveToLean = YES;
    self.verticalLeanMargin = 20.0;
    self.horizontalLeanMargin = 0.0;
    self.invalidHidden = NO;
    self.isMoving = NO;
    self.usingSpringWithDamping = 0.8;
    self.initialSpringVelocity = 3.0;
}



- (void)addActions {
    
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(_locationChange:)];
    pan.delaysTouchesBegan = YES;
    [self addGestureRecognizer:pan];
    _panGestureRecognizer = pan;
    
    [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - Public

- (void)defaultAnimation {
    self.usingSpringWithDamping = 0.3;
    self.initialSpringVelocity = 5.0;
    self.alpha = 0.5;
    [self beginMoveCallBack:^{
        self.alpha = 0.8;
    }];
    [self moveCallBack:^{
        self.alpha = 0.6;
    }];
    UIColor *oColor = self.backgroundColor;
    [self moveFinishCallBack:^{
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.alpha = 1.0;
            self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
        } completion:^(BOOL finished) {
            if (!self.isMoving) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
                        self.alpha = 0.1;
                        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
                            self.backgroundColor = oColor;
                        } completion:^(BOOL finished) {
                            
                        }];
                        
                    }];
                    
                });
            }
        }];
        
    }];
    
}

- (void)moveFinishCallBack:(void (^)())callback {
    self.moveFinishCallBack = callback;
}

- (void)moveCallBack:(void (^)())callBcak {
    self.movingCallBack = callBcak;
}

- (void)beginMoveCallBack:(void (^)())callBcak {
    self.beginMoveCallBack = callBcak;
}

- (void)clickCallback:(void (^)())callback {
    self.clickCallBack = callback;
}

- (void)setHidden:(BOOL)hidden {
    if (self.invalidHidden) {
        return;
    }
    [super setHidden:hidden];
}

- (void)dismiss:(void (^)(void))block {
    
    if (block) {
        block();
    }
    self.clickCallBack = nil;
    self.moveFinishCallBack = nil;
    [self removeFromSuperview];
    
}

#pragma mark - Private
- (void)_locationChange:(UIPanGestureRecognizer *)p {

    CGPoint panPoint = [p locationInView:[UIApplication sharedApplication].delegate.window];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        if (self.beginMoveCallBack) {
            self.beginMoveCallBack();
        }
    }else if(p.state == UIGestureRecognizerStateChanged) {
        [self movingWithPoint:panPoint];
        
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        
        if (!self.isMoveToLean) {
            return;
        }
        [self checkTargetPosition:panPoint];
    }
    
    if (self.locationChange) {
        self.locationChange(panPoint);
    }
}

- (void)locationChange:(UIPanGestureRecognizer *)p {}

/// 手指移动时，移动视图
- (void)movingWithPoint:(CGPoint)point {
    [SuspensionControl windowForKey:self.currentKey].center = CGPointMake(point.x, point.y);
    UIWindow *w = [SuspensionControl windowForKey:self.currentKey];
    if (w) {
        w.center = CGPointMake(point.x, point.y);
    } else {
        self.center = CGPointMake(point.x, point.y);
    }
    _isMoving = YES;
}

/// 处理最终停靠边缘的位置
- (void)checkTargetPosition:(CGPoint)panPoint {
    CGFloat touchWidth = self.frame.size.width;
    CGFloat touchHeight = self.frame.size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat left = fabs(panPoint.x);
    CGFloat right = fabs(screenWidth - left);
    CGFloat top = fabs(panPoint.y);
    CGFloat bottom = fabs(screenHeight - top);
    
    CGFloat minSpace = 0;
    if (self.leanType == SuspensionViewLeanTypeHorizontal) {
        minSpace = MIN(left, right);
    }else{
        minSpace = MIN(MIN(MIN(top, left), bottom), right);
    }
    CGPoint newTargetPoint = CGPointZero;
    CGFloat targetY = 0;
    

    if (panPoint.y < self.verticalLeanMargin + touchHeight / 2.0 + self.verticalLeanMargin) {
        targetY = self.verticalLeanMargin + touchHeight / 2.0 + self.verticalLeanMargin;
    }else if (panPoint.y > (screenHeight - touchHeight / 2.0 - self.verticalLeanMargin)) {
        targetY = screenHeight - touchHeight / 2.0 - self.verticalLeanMargin;
    }else{
        targetY = panPoint.y;
    }
    
    if (minSpace == left) {
        newTargetPoint = CGPointMake(touchWidth / 2 + self.horizontalLeanMargin, targetY);
    }
    if (minSpace == right) {
        newTargetPoint = CGPointMake(screenWidth - touchWidth / 2 - self.horizontalLeanMargin, targetY);
    }
    if (minSpace == top) {
        newTargetPoint = CGPointMake(panPoint.x, touchHeight / 2 + self.verticalLeanMargin);
    }
    if (minSpace == bottom) {
        newTargetPoint = CGPointMake(panPoint.x, screenHeight - touchHeight / 2 - self.verticalLeanMargin);
    }
    
    [self autoMoveToTargetPosition:newTargetPoint];
    
}

// 自动移动到边缘，此方法在手指松开后会自动移动到目标位置
- (void)autoMoveToTargetPosition:(CGPoint)point {
    
    [UIView animateWithDuration:0.2 delay:0.1 usingSpringWithDamping:self.usingSpringWithDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
        UIWindow *w = [SuspensionControl windowForKey:self.currentKey];
        if (w) {
            w.center = point;
        } else {
            self.center = point;
        }
        if (self.movingCallBack) {
            self.movingCallBack();
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            // 记录当前的center
            self.previousCenter = point;
            if (self.moveFinishCallBack) {
                self.moveFinishCallBack();
            }
            _isMoving = NO;
        }
    }];
}

#pragma mark - Actions
- (void)btnClick:(UIButton *)btn {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}



#pragma mark - setter \ getter
- (SuspensionViewLeanType)leanType {
    return _leanType ?: SuspensionViewLeanTypeEachSide;
}



- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end

@interface SuspensionControl ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIWindow *> *windows;

@end

@implementation SuspensionControl


+ (UIWindow *)windowForKey:(NSString *)key {
    return [[SuspensionControl shareInstance].windows objectForKey:key];
}

+ (void)setWindow:(UIWindow *)window forKey:(NSString *)key {
    [[SuspensionControl shareInstance].windows setObject:window forKey:key];
}

/// 通过key移除一个展示悬浮图标控件所在的window,并保持keyWindow显示
+ (void)removeWindowForKey:(NSString *)key {
    UIWindow *window = [[SuspensionControl shareInstance].windows objectForKey:key];
    window.hidden = YES;
    if (window.rootViewController.presentedViewController) {
        [window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    window.hidden = YES;
    window.rootViewController = nil;
    [[SuspensionControl shareInstance].windows removeObjectForKey:key];
}


+ (void)removeAllWindows {
    for (UIWindow *window in [SuspensionControl shareInstance].windows.allValues) {
        window.hidden = YES;
        window.rootViewController = nil;
    }
    [[SuspensionControl shareInstance].windows removeAllObjects];
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
}

+ (void)removeWindow:(UIWindow *)aWindow {
    
    if (!aWindow) {
        return;
    }
    NSDictionary *temp = [[SuspensionControl shareInstance].windows mutableCopy];
    [temp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIWindow * _Nonnull obj, BOOL * _Nonnull stop) {
        if (aWindow == obj) {
            [SuspensionControl removeWindowForKey:key];
        }
        *stop = YES;
    }];
    temp = nil;
    
}

#pragma mark - setter \ getter
- (NSMutableDictionary<NSString *, UIWindow *> *)windows {
    if (!_windows) {
        _windows = [NSMutableDictionary dictionary];
    }
    return _windows;
}


#pragma mark - 初始化
+ (instancetype)shareInstance {
    
    static SuspensionControl *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


@end

@implementation SuspensionWindow

#pragma mark - public methods


+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame {
    
    SuspensionWindow *s = [[self alloc] initWithFrame:frame];
    s.leanType = SuspensionViewLeanTypeEachSide;
    s.isOnce = isOnce;
    [s _moveToSuperview];
    
    return s;
}

- (void)dismiss:(void (^)(void))block {
    
    if (block) {
        block();
    }
    self.clickCallBack = nil;
    self.moveFinishCallBack = nil;
    [SuspensionControl removeWindowForKey:self.currentKey];
    [self removeFromSuperview];
    
}

+ (void)releaseAll {
    
    NSDictionary *temp = [[SuspensionControl shareInstance].windows mutableCopy];
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
    suspensionWindow.windowLevel = UIWindowLevelAlert * 3;
    [suspensionWindow makeKeyAndVisible];
    // 给window设置rootViewController是为了当屏幕旋转时，winwow跟随旋转并更新坐标
    UIViewController *vc = [UIViewController new];
    suspensionWindow.rootViewController = vc;
    // 不设置此属性，window在选择时，会出现四周黑屏现象
    [suspensionWindow.layer setMasksToBounds:YES];
    
    [SuspensionControl setWindow:suspensionWindow forKey:self.currentKey];
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.clipsToBounds = YES;
    
    [vc.view addSubview:self];
    
    suspensionWindow.suspensionView = self;
    
    // 保持原先的keyWindow，避免一些不必要的问题
    [currentKeyWindow makeKeyWindow];
    
}


@end

static const CGFloat menuView_wh = 280.0;
static const CGFloat barButton_wh = 64.0;
static const CGFloat centerBarButton_size = barButton_wh;
static const CGFloat menuBarBaseTag = 100;

@interface SuspensionMenuView () {
    @private
    CGFloat _defaultTriangleHypotenuse;     // 默认关闭时的三角斜边
    CGFloat _minBounceOfTriangleHypotenuse; // 当第一次显示完成后的三角斜边
    CGFloat _maxBounceOfTriangleHypotenuse; // 当显示时要展开的三角斜边
    CGFloat _maxTriangleHypotenuse;         // 最大三角斜边，当第一次刚出现时三角斜边
    CGRect _memuBarButtonOriginFrame;       // 每一个菜单上按钮的原始frame 除中心的按钮 关闭时也可使用,重叠
    
    NSMutableArray<UIButton *> *_menuBarButtons;
    
    BOOL _isInProcessing; // 是否正在执行显示或消失
    BOOL _isShow;         // 是否已经显示
    BOOL _isDismiss;      // 是否已经消失
    BOOL _isFiristShow;   // 是否第一次显示
}

@property (nonatomic, copy) NSString *currentKey;
@property (nonatomic, assign) BOOL isOnce;
@property (nonatomic, weak) SuspensionView *centerButton;
@property (nonatomic, weak) UIImageView *backgroundImView;
/// 根据menuBarImages创建对应menuBar，最多只能有6个
@property (nonatomic, strong) NSArray<UIImage *> *menuBarImages;
@property (nonatomic, strong) NSArray<NSString *> *titles;

@end

@implementation SuspensionMenuView

#pragma mark - Public Methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setMenuBarImages:(NSArray<UIImage *> *)menuBarImages titles:(NSArray<NSString *> *)titles {
    _menuBarImages = menuBarImages;
    _titles = titles;
    
    if (!menuBarImages.count && !titles.count) {
        return;
    }
    
    NSMutableArray *tempImages = [NSMutableArray arrayWithCapacity:6];
    NSMutableArray *tempTitles = [NSMutableArray arrayWithCapacity:6];
    if (_menuBarButtons.count && titles.count <= _menuBarImages.count) {
        if (_menuBarImages.count > 6 || titles.count > 6) {
            [_menuBarImages enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx > 6) {
                    *stop = YES;
                }
                [tempImages addObject:obj];
                if (titles.count && idx <= titles.count) {
                    [tempTitles addObject:titles[idx]];
                }
            }];
        }
        [_menuBarButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_menuBarButtons removeAllObjects];
    }
    
    if (!tempImages.count) {
        tempImages = [menuBarImages mutableCopy];
    }
    if (!tempTitles.count) {
        tempTitles = [titles mutableCopy];
    }
    
    [self createMenuBarButton:tempImages titles:tempTitles];
}

- (void)setCenterBarBackgroundImage:(UIImage *)centerBarBackgroundImage {
    _centerBarBackgroundImage = centerBarBackgroundImage;
    
    if (!centerBarBackgroundImage) {
        return;
    }
    [self.centerButton setBackgroundImage:self.centerBarBackgroundImage
                            forState:UIControlStateNormal];
}


//// Push View Controller
- (void)pushViewController:(UIViewController *)viewController {
    [UIView animateWithDuration:.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         // 在中心视图中滑动按钮并隐藏
                         [self updateMenuBarButtonLayoutWithTriangleHypotenuse:_maxTriangleHypotenuse];
                         [self setAlpha:0.0];
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"_MenuBarHypotenuseButton")]) {
                                 [btn setAlpha:0.0];
                             }
                         }

                     }
                     completion:^(BOOL finished) {
                         [[self topViewController].navigationController pushViewController:viewController animated:YES];
                         [self.centerButton dismiss:nil];
                         self.menuBarClickBlock = nil;
                         [SuspensionControl removeWindowForKey:self.currentKey];
                         [self removeFromSuperview];
                     }];
}


- (void)show {
    if (_isShow) return;
    
    if (_isFiristShow) {
        [self updateMenuBarButtonLayoutWithTriangleHypotenuse:_maxTriangleHypotenuse];
    }
    
    [self centerButton];
    [self _updateMenuViewCenter];
    UIWindow *window = [SuspensionControl windowForKey:self.currentKey];
    [window setHidden:NO];
    
    _isInProcessing = YES;
    
    [[UIApplication sharedApplication].delegate.window bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         [self setAlpha:1.0];
                         
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"_MenuBarHypotenuseButton")]) {
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
                                          }];
                     }];
}



- (void)dismiss {
    
    if (_isDismiss)
        return;
    
    _isInProcessing = YES;
    
    // 隐藏menu bar button
    [UIView animateWithDuration:.3f
                          delay:0.f
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         for (UIButton * button in [self subviews])
                             [button setFrame:_memuBarButtonOriginFrame];
                         [self setAlpha:0.0];
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"_MenuBarHypotenuseButton")]) {
                                 [btn setAlpha:0.0];
                             }
                         }
                         
                     }
     
                     completion:^(BOOL finished) {
                         _isDismiss = YES;
                         _isShow  = NO;
                         _isInProcessing = NO;
                         UIWindow *window = [SuspensionControl windowForKey:self.currentKey];
                         [window setHidden:YES];
                     }];
}

#pragma mark - 初始化

- (SuspensionView *)centerButton {
    if (_centerButton == nil) {
        // 创建中心按钮
        CGRect centerButtonFrame =
        CGRectMake((CGRectGetWidth(self.frame) - centerBarButton_size) * 0.5,
                   (CGRectGetHeight(self.frame) - centerBarButton_size) * 0.5,
                   centerBarButton_size, centerBarButton_size);
        
        CGRect centerRec = [self convertRect:centerButtonFrame toView:[UIApplication sharedApplication].delegate.window];
        
        SuspensionView *centerButton = (SuspensionWindow *)[NSClassFromString(@"_MenuBarCenterButton") showOnce:YES frame:centerRec];
        
        centerButton.moveToLean = NO;
        
        [centerButton setBackgroundImage:self.centerBarBackgroundImage forState:UIControlStateNormal];
        
        [centerButton addTarget:self action:@selector(centerBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        __weak typeof(self) weakSelf = self;
        centerButton.locationChange = ^(CGPoint currentPoint) {
            [SuspensionControl windowForKey:self.currentKey].center = currentPoint;
            [weakSelf dismiss];
        };
        
        _centerButton = centerButton;
        
    }
    return _centerButton;
}

- (UIImageView *)backgroundImView {
    if (_backgroundImView == nil) {
        UIImageView *imageView = [NSClassFromString(@"_MenuViewBackgroundImageView") new];
        _backgroundImView = imageView;
        imageView.userInteractionEnabled = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        imageView.frame = self.bounds;
    }
    return _backgroundImView;
}

- (void)setup {
    
    _menuBarButtons = [NSMutableArray array];
    
    // 设置三角斜边
    _defaultTriangleHypotenuse = (menuView_wh - barButton_wh) * 0.5;
    _minBounceOfTriangleHypotenuse = _defaultTriangleHypotenuse - 12.0;
    _maxBounceOfTriangleHypotenuse = _defaultTriangleHypotenuse + 12.0;
    _maxTriangleHypotenuse = kSCREENT_HEIGHT * 0.5;
    
    // 计算menu 上 按钮的 原始 frame 当dismiss 时 回到原始位置
    CGFloat originX = (menuView_wh - centerBarButton_size) * 0.5;
    _memuBarButtonOriginFrame = CGRectMake(originX, originX, centerBarButton_size, centerBarButton_size);
    
    
    _isInProcessing = NO;
    _isShow  = NO;
    _isDismiss = YES;
    _isFiristShow = YES;

    UIImage *backgroundImage = [UIImage imageFromColor:[UIColor colorWithWhite:0.3 alpha:0.6]];
    self.backgroundImView.image = [backgroundImage imageBluredwithBlurNumber:0.8 WithRadius:3 tintColor:nil saturationDeltaFactor:9 maskImage:nil];
    self.autoresizingMask = UIViewAutoresizingNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
}
// 创建斜边的bar button
- (void)createMenuBarButton:(NSArray *)menuBarImages titles:(NSArray *)titles {
    
    NSArray *temp = menuBarImages.count > titles.count ? menuBarImages : titles;
    
    [temp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton * button = [NSClassFromString(@"_MenuBarHypotenuseButton") buttonWithType:UIButtonTypeCustom];
        [button setOpaque:NO];
        [button setTag:menuBarBaseTag+idx+1];
        if (menuBarImages.count && idx < menuBarImages.count) {
            UIImage *image = menuBarImages[idx];
            [button setImage:image forState:UIControlStateNormal];
        }
        if (titles.count && idx < titles.count) {
            [button setTitle:titles[idx] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(menuBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setAlpha:0.0];
        [self addSubview:button];
        [button setFrame:_memuBarButtonOriginFrame];
        [_menuBarButtons addObject:button];
        
    }];

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
        _menuBarClickBlock([sender tag] - menuBarBaseTag);
    }
}

- (void)orientationDidChange:(NSNotification *)note {
    
    [self _updateMenuViewCenter];
}


#pragma mark - Private Methods

- (void)_updateMenuViewCenter {

//    CGPoint centerPoint = CGPointMake((kSCREENT_WIDTH-menuView_wh)*0.5, (kSCREENT_HEIGHT-menuView_wh)*0.5)
    UIWindow *suspensionWindow = [SuspensionControl windowForKey:self.centerButton.currentKey];
    
    CGPoint newCenter = [suspensionWindow convertPoint:self.centerButton.center toView:[UIApplication sharedApplication].delegate.window];
    [SuspensionControl windowForKey:self.currentKey].center = newCenter;
    self.backgroundImView.frame = self.bounds;
}

/// 设置按钮的 位置
- (void)_setButtonWithTag:(NSInteger)buttonTag origin:(CGPoint)origin {
    
    if (buttonTag < menuBarBaseTag) {
        buttonTag = menuBarBaseTag + buttonTag;
    }
    
    UIButton * button = (UIButton *)[self viewWithTag:buttonTag];
    if (button) {
        [button setFrame:CGRectMake(origin.x, origin.y, centerBarButton_size, centerBarButton_size)];
        button = nil;
    }
}


- (void)updateMenuBarButtonLayoutWithTriangleHypotenuse:(CGFloat)triangleHypotenuse {
    //
    //  Triangle Values for Buttons' Position
    //
    //      /|      a: triangleA = c * cos(x)
    //   c / | b    b: triangleB = c * sin(x)
    //    /)x|      c: triangleHypotenuse // 三角斜边
    //   -----      x: degree   // 度数
    //     a
    //
    CGFloat centerBallMenuHalfSize = menuView_wh * 0.5;
    CGFloat buttonRadius           = centerBarButton_size * 0.5;
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
    if (_menuBarImages.count == 1) {
        
        [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                     centerBallMenuHalfSize - triangleHypotenuse - buttonRadius)];
    }
    
    if (_menuBarImages.count == 2) {
        
        CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180 角度
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        CGFloat negativeValue = centerBallMenuHalfSize - triangleB - buttonRadius;
        CGFloat positiveValue = centerBallMenuHalfSize + triangleB - buttonRadius;
        [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
        [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
        
    }
    
    if (_menuBarImages.count == 3) {
        // = 360.0f / self.buttonCount * M_PI / 180.0f;
        // E.g: if |buttonCount_ = 6|, then |degree = 60.0f * M_PI / 180.0f|;
        // CGFloat degree = 2 * M_PI / self.buttonCount;
        //
        CGFloat degree    = M_PI / 3.0f; // = 60 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree);
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                     centerBallMenuHalfSize - triangleA - buttonRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                     centerBallMenuHalfSize - triangleA - buttonRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                     centerBallMenuHalfSize + triangleHypotenuse - buttonRadius)];
    }
    if (_menuBarImages.count == 4) {
        CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        CGFloat negativeValue = centerBallMenuHalfSize - triangleB - buttonRadius;
        CGFloat positiveValue = centerBallMenuHalfSize + triangleB - buttonRadius;
        [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
        [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
        [self _setButtonWithTag:3 origin:CGPointMake(negativeValue, positiveValue)];
        [self _setButtonWithTag:4 origin:CGPointMake(positiveValue, positiveValue)];
    }
    
    if (_menuBarImages.count == 5) {
        CGFloat degree    = M_PI / 20.5; // = 72 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree);
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                     centerBallMenuHalfSize - triangleA - buttonRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                     centerBallMenuHalfSize - triangleHypotenuse - buttonRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                     centerBallMenuHalfSize - triangleA - buttonRadius)];
        
        degree    = M_PI / 5.0f;  // = 36 * M_PI / 180
        triangleA = triangleHypotenuse * cosf(degree);
        triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:4 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                     centerBallMenuHalfSize + triangleA - buttonRadius)];
        [self _setButtonWithTag:5 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                     centerBallMenuHalfSize + triangleA - buttonRadius)];
    }
    
    if (_menuBarImages.count == 6) {
        CGFloat degree    = M_PI / 3.0f; // = 60 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree); // 斜边的余弦值
        CGFloat triangleB = triangleHypotenuse * sinf(degree); // 斜边正弦值
        [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                     centerBallMenuHalfSize - triangleA - buttonRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                     centerBallMenuHalfSize - triangleHypotenuse - buttonRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                     centerBallMenuHalfSize - triangleA - buttonRadius)];
        [self _setButtonWithTag:4 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                     centerBallMenuHalfSize + triangleA - buttonRadius)];
        [self _setButtonWithTag:5 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                     centerBallMenuHalfSize + triangleHypotenuse - buttonRadius)];
        [self _setButtonWithTag:6 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                     centerBallMenuHalfSize + triangleA - buttonRadius)];
        
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (UIViewController *)topViewController {

    UINavigationController * navigationController = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if ([navigationController isKindOfClass:[UINavigationController class]]) {
        UIViewController * currentViewController = [navigationController topViewController];
        return currentViewController;
    }
    return nil;
}

- (NSString *)currentKey {
    return _isOnce ? [[SuspensionControl shareInstance] keyWithIdentifier:NSStringFromClass([self class])] : self.key;
}

@end


@implementation SuspensionMenuWindow

+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame {
    
    // 显示 到 中心 menu View
//    CGRect centerMenuFrame =
//    CGRectMake((kSCREENT_WIDTH - menuView_wh) * 0.5, (kSCREENT_HEIGHT - menuView_wh) * 0.5, menuView_wh, menuView_wh);
    
    SuspensionMenuWindow *menuView = [[self alloc] initWithFrame:frame];
    [menuView setAlpha:1.f];
    
    menuView.isOnce = isOnce;
    [menuView _moveToSuperview];
    
    return menuView;
}

- (void)dismiss:(void (^)(void))block {
    
    if (block) {
        block();
    }
    
    self.menuBarClickBlock = nil;
    [SuspensionControl removeWindowForKey:self.currentKey];
    [self removeFromSuperview];
    
}

+ (void)releaseAll {
    
    NSDictionary *temp = [[SuspensionControl shareInstance].windows mutableCopy];
    [temp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIWindow * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.suspensionMenuView && obj.suspensionView) {
            [SuspensionControl removeWindow:obj];
        }
    }];
    temp = nil;
}

#pragma mark - Private methods

- (void)_moveToSuperview {
    
    UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    UIWindow *suspensionWindow = [[UIWindow alloc] initWithFrame:self.frame];
    suspensionWindow.windowLevel = UIWindowLevelAlert * 2;
    [suspensionWindow makeKeyAndVisible];

    // 给window设置rootViewController是为了当屏幕旋转时，winwow跟随旋转并更新坐标
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    UIViewController *vc = [[NSClassFromString(@"SuspensionMenuController") alloc] performSelector:@selector(initWithMenuView:) withObject:self];
#pragma clang diagnostic pop
    
    suspensionWindow.rootViewController = vc;
    // 不设置此属性，window在选择时，会出现四周黑屏现象
    [suspensionWindow.layer setMasksToBounds:YES];
    
    [SuspensionControl setWindow:suspensionWindow forKey:self.currentKey];
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.clipsToBounds = YES;
    
    [vc.view addSubview:self];
    
    suspensionWindow.suspensionMenuView = self;
    
    // 保持原先的keyWindow，避免一些不必要的问题
    [currentKeyWindow makeKeyWindow];
    
}


@end


@implementation NSObject (SuspensionKey)

- (void)setKey:(NSString *)key {
    objc_setAssociatedObject(self, @selector(key), key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)key {
    NSString *key = objc_getAssociatedObject(self, @selector(key));
    if (!key.length) {
        self.key = (key = [self md5:self.description]);
    }
    return key;
}

- (NSString *)keyWithIdentifier:(NSString *)identifier {
    return [self.key stringByAppendingString:identifier];
}

//md5加密
- (NSString *)md5:(NSString *)str {
    const char * cStr = [str UTF8String];
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7], result[8], result[9],
            result[10], result[11], result[12], result[13],
            result[14], result[15]];
}

@end

/// 斜边使用的按钮
@interface _MenuBarHypotenuseButton : UIButton
@end
@implementation _MenuBarHypotenuseButton
@end
/// 中心使用的按钮
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

- (instancetype)initWithMenuView:(SuspensionMenuView *)menuView;

@property (nonatomic, weak) SuspensionMenuView *menuView;

@end

@implementation SuspensionMenuController

- (instancetype)initWithMenuView:(SuspensionMenuView *)menuView {
    if (self = [super init]) {
        _menuView = menuView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.menuView performSelector:@selector(show)
                        withObject:nil
                        afterDelay:0.3];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.menuView dismiss];
    
    [self.nextResponder touchesBegan:touches withEvent:event];
}

@end
