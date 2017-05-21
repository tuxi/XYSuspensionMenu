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
    if (!result) {
        NSAssert(result, @"当前类应为UIViewController或UIView或他们的子类");
        return nil;
    }
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

    self.autoLeanEdge = YES;
    self.leanEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
    self.invalidHidden = NO;
    self.isMoving = NO;
    self.usingSpringWithDamping = 0.8;
    self.initialSpringVelocity = 3.0;
    self.previousCenter = self.center;
}


- (void)addActions {
    
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(_locationChange:)];
    pan.delaysTouchesBegan = YES;
    [self addGestureRecognizer:pan];
    _panGestureRecognizer = pan;
    
    [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
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
    [self leanFinishCallBack:^(CGPoint centerPoint){
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

- (void)leanFinishCallBack:(void (^)(CGPoint centerPoint))callback {
    self.leanFinishCallBack = callback;
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
    self.leanFinishCallBack = nil;
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
        
        if (!self.isAutoLeanEdge) {
            return;
        }
        CGPoint newTargetPoint = [self _checkTargetPosition:panPoint];
        [self autoLeanToTargetPosition:newTargetPoint];
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

- (void)checkTargetPosition {
    
    CGPoint currentPoint = [self convertPoint:self.center toView:[UIApplication sharedApplication].delegate.window];
    
    CGPoint newTargetPoint = [self _checkTargetPosition:currentPoint];
    [self autoLeanToTargetPosition:newTargetPoint];
}

/// 根据传入的位置检查处理最终依靠到边缘的位置
- (CGPoint)_checkTargetPosition:(CGPoint)panPoint {
    CGFloat touchWidth = self.frame.size.width;
    CGFloat touchHeight = self.frame.size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat left = fabs(panPoint.x);
    CGFloat right = fabs(screenWidth - left);
    CGFloat top = fabs(panPoint.y);
    CGFloat bottom = fabs(screenHeight - top);
    
    CGFloat minSpace = 0;
    if (self.leanEdgeType == SuspensionViewLeanEdgeTypeHorizontal) {
        minSpace = MIN(left, right);
    }else if (self.leanEdgeType == SuspensionViewLeanEdgeTypeEachSide) {
        minSpace = MIN(MIN(MIN(top, left), bottom), right);
    }
    CGPoint newTargetPoint = CGPointZero;
    CGFloat targetY = 0;

    if (panPoint.y < self.leanEdgeInsets.top + touchHeight / 2.0 + self.leanEdgeInsets.top) {
        targetY = self.leanEdgeInsets.top + touchHeight / 2.0 + self.leanEdgeInsets.top;
    }else if (panPoint.y > (screenHeight - touchHeight / 2.0 - self.leanEdgeInsets.bottom)) {
        targetY = screenHeight - touchHeight / 2.0 - self.leanEdgeInsets.bottom;
    }else{
        targetY = panPoint.y;
    }
    
    if (minSpace == left) {
        newTargetPoint = CGPointMake(touchWidth / 2 + self.leanEdgeInsets.left, targetY);
    }
    if (minSpace == right) {
        newTargetPoint = CGPointMake(screenWidth - touchWidth / 2 - self.leanEdgeInsets.right, targetY);
    }
    if (minSpace == top) {
        newTargetPoint = CGPointMake(panPoint.x, touchHeight / 2 + self.leanEdgeInsets.top);
    }
    if (minSpace == bottom) {
        newTargetPoint = CGPointMake(panPoint.x, screenHeight - touchHeight / 2 - self.leanEdgeInsets.bottom);
    }
    // 记录当前的center
    self.previousCenter = newTargetPoint;
    return newTargetPoint;
}

- (void)leanToPreviousLeanPosition {
    
    [self autoLeanToTargetPosition:self.previousCenter];
}

/// 移动移动到屏幕中心位置
- (void)leanToScreentCenter {

    CGPoint screenCenter = CGPointMake((kSCREENT_WIDTH - [SuspensionControl windowForKey:self.key].bounds.size.width)*0.5, (kSCREENT_HEIGHT - [SuspensionControl windowForKey:self.key].bounds.size.height)*0.5);
    
    [self autoLeanToTargetPosition:screenCenter];
}

/// 自动移动到边缘，此方法在手指松开后会自动移动到目标位置
- (void)autoLeanToTargetPosition:(CGPoint)point {
    
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:self.usingSpringWithDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
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
            if (self.leanFinishCallBack) {
                self.leanFinishCallBack(point);
            }
            _isMoving = NO;
        }
    }];
}

- (void)orientationDidChange:(NSNotification *)note {
    if (self.isAutoLeanEdge) {
        /// 屏幕旋转时检测下最终依靠的位置，防止出现屏幕旋转记录的previousCenter未更新坐标时，导致按钮不见了
        CGPoint currentPoint = [self convertPoint:self.center toView:[UIApplication sharedApplication].delegate.window];
        
        [self _checkTargetPosition:currentPoint];
    }
}

#pragma mark - Actions
- (void)btnClick:(UIButton *)btn {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}

#pragma mark - setter \ getter
- (SuspensionViewLeanEdgeType)leanEdgeType {
    return _leanEdgeType ?: SuspensionViewLeanEdgeTypeEachSide;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

@end

@interface SuspensionControl ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIWindow *> *windows;

@end

@implementation SuspensionControl

@dynamic shareInstance;

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
static const CGFloat centerBarButton_wh = barButton_wh;
static const CGFloat menuBarBaseTag = 100;

@interface SuspensionMenuView () {
@private
    CGFloat _defaultTriangleHypotenuse;     // 默认关闭时的三角斜边
    CGFloat _minBounceOfTriangleHypotenuse; // 当第一次显示完成后的三角斜边
    CGFloat _maxBounceOfTriangleHypotenuse; // 当显示时要展开的三角斜边
    CGFloat _maxTriangleHypotenuse;         // 最大三角斜边，当第一次刚出现时三角斜边
    CGRect _memuBarButtonOriginFrame;       // 每一个菜单上按钮的原始frame 除中心的按钮 关闭时也可使用,重叠
    
    BOOL _isInProcessing;  // 是否正在执行显示或消失
    BOOL _isShow;          // 是否已经显示
    BOOL _isDismiss;       // 是否已经消失
    BOOL _isFiristShow;    // 是否第一次显示
    BOOL _isFiristDismiss; // 是否第一次消失
}

@property (nonatomic, copy) NSString *currentKey;
@property (nonatomic, assign) BOOL isOnce;
@property (nonatomic, weak) SuspensionView *centerButton;
@property (nonatomic, weak) UIImageView *backgroundImView;

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

- (void)setMenuBarItems:(NSArray<MenuBarHypotenuseButton *> *)menuBarItems {
    
    _menuBarItems = menuBarItems;
    
    NSInteger idx = 0;
    for (MenuBarHypotenuseButton *button in menuBarItems) {
        [button setOpaque:NO];
        [button setTag:menuBarBaseTag+idx+1];
        [button addTarget:self action:@selector(menuBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setAlpha:0.0];
        [self addSubview:button];
        [button setFrame:_memuBarButtonOriginFrame];
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
                         
                        
                     } completion:^(BOOL finished) {
                         [[self topViewController].navigationController pushViewController:viewController animated:YES];
                         UIWindow *menuWindow = [SuspensionControl windowForKey:self.currentKey];
                         CGRect menuFrame =  menuWindow.frame;
                         menuFrame.size = CGSizeZero;
                         menuWindow.frame = menuFrame;
                         [self.centerButton checkTargetPosition];
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
        [self.centerButton leanToScreentCenter];
    }
    
    UIWindow *window = [SuspensionControl windowForKey:self.currentKey];
    
    [self centerButton];
    [self _updateMenuViewCenter];
    
    _isInProcessing = YES;
    
    [[UIApplication sharedApplication].delegate.window bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         [window setAlpha:1.0];
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
    [self _dismissWithTriggerPanGesture:NO];
}

/// 执行dismiss，并根据当前是否触发了拖动手势，确定是否在让SuapensionWindow执行移动边缘的操作，防止移除时乱窜
- (void)_dismissWithTriggerPanGesture:(BOOL)isTriggerPanGesture {
    
    if (_isDismiss)
        return;
    
    if (_isFiristDismiss) {
        // 检测边缘
        [self.centerButton checkTargetPosition];
    }
    
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
                             [self.centerButton leanToPreviousLeanPosition];
                         }
                         
                     } completion:^(BOOL finished) {
                         _isDismiss = YES;
                         _isShow  = NO;
                         _isInProcessing = NO;
                         UIWindow *menuWindow = [SuspensionControl windowForKey:self.currentKey];
//                         [window setHidden:YES];
                         
                         [UIView animateWithDuration:0.3 animations:^{
                             [menuWindow setAlpha:0.0];
                             // 让其frame为zero，为了防止其隐藏后所在的位置无法响应事件
                         }completion:^(BOOL finished) {
                             if (finished) {
                                 CGRect menuFrame =  menuWindow.frame;
                                 menuFrame.size = CGSizeZero;
                                 menuWindow.frame = menuFrame;
                             }
                         } ];
                         
                         _isFiristDismiss = NO;
                     }];
}


#pragma mark - 初始化

- (SuspensionView *)centerButton {
    if (_centerButton == nil) {
        // 创建中心按钮
        CGRect centerButtonFrame = CGRectMake((CGRectGetWidth(self.frame) - centerBarButton_wh) * 0.5, (CGRectGetHeight(self.frame) - centerBarButton_wh) * 0.5, centerBarButton_wh, centerBarButton_wh);
        
        CGRect centerRec = [self convertRect:centerButtonFrame toView:[UIApplication sharedApplication].delegate.window];
        
        SuspensionView *centerButton = (SuspensionWindow *)[NSClassFromString(@"_MenuBarCenterButton") showOnce:YES frame:centerRec];
        
        centerButton.autoLeanEdge = YES;
        
        [centerButton addTarget:self action:@selector(centerBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(centerButton) weakCenterButton = centerButton;
        centerButton.locationChange = ^(CGPoint currentPoint) {
            weakSelf.center = currentPoint;
            if (weakCenterButton.panGestureRecognizer.state == UIGestureRecognizerStateEnded || weakCenterButton.panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [weakCenterButton leanToPreviousLeanPosition];
            }
            if (weakCenterButton.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
                [weakSelf _dismissWithTriggerPanGesture:YES];
            }
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
    
    // 设置三角斜边
    _defaultTriangleHypotenuse = (menuView_wh - barButton_wh) * 0.5;
    _minBounceOfTriangleHypotenuse = _defaultTriangleHypotenuse - 12.0;
    _maxBounceOfTriangleHypotenuse = _defaultTriangleHypotenuse + 12.0;
    _maxTriangleHypotenuse = kSCREENT_HEIGHT * 0.5;
    
    // 计算menu 上 按钮的 原始 frame 当dismiss 时 回到原始位置
    CGFloat originX = (menuView_wh - centerBarButton_wh) * 0.5;
    _memuBarButtonOriginFrame = CGRectMake(originX, originX, centerBarButton_wh, centerBarButton_wh);
    
    _isInProcessing = NO;
    _isShow  = NO;
    _isDismiss = YES;
    _isFiristShow = YES;
    _isFiristDismiss = YES;
    _shouldLeanToScreenCenterWhenShow = YES;
    _shouldShowWhenViewWillAppear = YES;

    UIImage *backgroundImage = [UIImage imageFromColor:[UIColor colorWithWhite:0.3 alpha:0.6]];
    self.backgroundImView.image = [backgroundImage imageBluredwithBlurNumber:0.8 WithRadius:3 tintColor:nil saturationDeltaFactor:9 maskImage:nil];
    self.autoresizingMask = UIViewAutoresizingNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
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

    UIWindow *menuWindow = [SuspensionControl windowForKey:self.currentKey];
    menuWindow.frame = [UIScreen mainScreen].bounds;
    
    UIWindow *centerWindow = [SuspensionControl windowForKey:self.centerButton.currentKey];
    CGRect centerFrame =  centerWindow.frame;
    centerFrame.size = CGSizeMake(centerBarButton_wh, centerBarButton_wh);
    centerWindow.frame = centerFrame;
    
    UIWindow *suspensionWindow = [SuspensionControl windowForKey:self.centerButton.currentKey];
    
    CGPoint newCenter = [suspensionWindow convertPoint:self.centerButton.center toView:[UIApplication sharedApplication].delegate.window];
    self.center = newCenter;
    self.backgroundImView.frame = self.bounds;
}

/// 设置按钮的 位置
- (void)_setButtonWithTag:(NSInteger)buttonTag origin:(CGPoint)origin {
    
    if (buttonTag < menuBarBaseTag) {
        buttonTag = menuBarBaseTag + buttonTag;
    }
    
    UIButton * button = (UIButton *)[self viewWithTag:buttonTag];
    if (button) {
        [button setFrame:CGRectMake(origin.x, origin.y, centerBarButton_wh, centerBarButton_wh)];
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
    CGFloat buttonRadius           = centerBarButton_wh * 0.5;
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
        
        [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                     centerBallMenuHalfSize - triangleHypotenuse - buttonRadius)];
    }
    
    if (_menuBarItems.count == 2) {
        
        CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180 角度
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        CGFloat negativeValue = centerBallMenuHalfSize - triangleB - buttonRadius;
        CGFloat positiveValue = centerBallMenuHalfSize + triangleB - buttonRadius;
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
        [self _setButtonWithTag:1 origin:CGPointMake(centerBallMenuHalfSize - triangleB - buttonRadius,
                                                     centerBallMenuHalfSize - triangleA - buttonRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(centerBallMenuHalfSize + triangleB - buttonRadius,
                                                     centerBallMenuHalfSize - triangleA - buttonRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(centerBallMenuHalfSize - buttonRadius,
                                                     centerBallMenuHalfSize + triangleHypotenuse - buttonRadius)];
    }
    if (_menuBarItems.count == 4) {
        CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        CGFloat negativeValue = centerBallMenuHalfSize - triangleB - buttonRadius;
        CGFloat positiveValue = centerBallMenuHalfSize + triangleB - buttonRadius;
        [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
        [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
        [self _setButtonWithTag:3 origin:CGPointMake(negativeValue, positiveValue)];
        [self _setButtonWithTag:4 origin:CGPointMake(positiveValue, positiveValue)];
    }
    
    if (_menuBarItems.count == 5) {
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
    
    if (_menuBarItems.count == 6) {
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
    if (_menuBarItems.count) {
        [_menuBarItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _menuBarItems = nil;
    }
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

+ (instancetype)showOnce:(BOOL)isOnce menuBarItems:(NSArray<MenuBarHypotenuseButton *> *)menuBarItems {
    CGRect centerMenuFrame = CGRectMake(0, 0, menuView_wh, menuView_wh);
    SuspensionMenuWindow *menuView = [self showOnce:isOnce frame:centerMenuFrame];
    menuView.menuBarItems = menuBarItems;
    return menuView;
}

+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame {
    
    SuspensionMenuWindow *menuView = [[self alloc] initWithFrame:frame];
    [menuView setAlpha:1.0];
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
            [SuspensionControl removeWindowForKey:obj.suspensionView.currentKey];
        }
    }];
    temp = nil;
}

#pragma mark - Private methods

- (void)_moveToSuperview {
    
    UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    UIWindow *suspensionWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
    self.frame = CGRectMake((kSCREENT_WIDTH - self.frame.size.width) * 0.5, (kSCREENT_HEIGHT - self.frame.size.height) * 0.5, self.frame.size.width, self.frame.size.height);
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

@implementation MenuBarHypotenuseButton

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
