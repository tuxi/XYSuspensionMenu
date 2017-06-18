//
//  SuspensionView.m
//  SuspensionView
//
//  Created by Ossey on 2017/6/16.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "SuspensionView.h"
#import "SuspensionControl.h"
#import <objc/runtime.h>

static NSString * const PreviousCenterXKey = @"previousCenterX";
static NSString * const PreviousCenterYKey = @"previousCenterY";

@interface SuspensionView ()

@property (nonatomic, assign) CGPoint previousCenter;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) BOOL isMoving;

@end

@implementation SuspensionView

@synthesize previousCenter = _previousCenter;

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ initialize ~~~~~~~~~~~~~~~~~~~~~~~


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _suspensionViewSetup];
        [self addActions];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _suspensionViewSetup];
        [self addActions];
    }
    return self;
}

- (void)_suspensionViewSetup {
    
    self.autoLeanEdge = YES;
    self.leanEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
    self.invalidHidden = NO;
    self.isMoving = NO;
    self.usingSpringWithDamping = 0.8;
    self.initialSpringVelocity = 3.0;
    self.shouldLeanToPreviousPositionWhenAppStart = YES;
    CGFloat centerX = [[NSUserDefaults standardUserDefaults] doubleForKey:PreviousCenterXKey];
    CGFloat centerY = [[NSUserDefaults standardUserDefaults] doubleForKey:PreviousCenterYKey];
    if (centerX > 0 || centerY > 0) {
        self.previousCenter = CGPointMake(centerX, centerY);
    } else {
        self.previousCenter = self.center;
    }
    
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

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Public ~~~~~~~~~~~~~~~~~~~~~~~


- (void)leanFinishCallBack:(void (^)(CGPoint centerPoint))callback {
    self.leanFinishCallBack = callback;
}

- (void)setHidden:(BOOL)hidden {
    if (self.invalidHidden) {
        return;
    }
    [super setHidden:hidden];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    self.clickCallBack = nil;
    self.leanFinishCallBack = nil;
    self.delegate = nil;
}


#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Position ~~~~~~~~~~~~~~~~~~~~~~~

- (void)_locationChange:(UIPanGestureRecognizer *)p {
    
    CGPoint panPoint = [p locationInView:[UIApplication sharedApplication].delegate.window];
    
    if(p.state == UIGestureRecognizerStateBegan) {
    
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionView:locationChange:)]) {
        [self.delegate suspensionView:self locationChange:p];
        return;
    }
    
    if (self.locationChange) {
        self.locationChange(panPoint);
    }
}


/// 手指移动时，移动视图
- (void)movingWithPoint:(CGPoint)point {
    [SuspensionControl windowForKey:self.key].center = CGPointMake(point.x, point.y);
    UIWindow *w = [SuspensionControl windowForKey:self.key];
    if (w) {
        w.center = CGPointMake(point.x, point.y);
    } else {
        self.center = CGPointMake(point.x, point.y);
    }
    _isMoving = YES;
}

- (void)checkTargetPosition {
    
    if (self.shouldLeanToPreviousPositionWhenAppStart) {
        CGPoint newTargetPoint = [self _checkTargetPosition:self.previousCenter];
        [self autoLeanToTargetPosition:newTargetPoint];
    } else {
        CGPoint currentPoint = [self convertPoint:self.center toView:[UIApplication sharedApplication].delegate.window];
        CGPoint newTargetPoint = [self _checkTargetPosition:currentPoint];
        [self autoLeanToTargetPosition:newTargetPoint];
    }
    
}

/// 根据传入的位置检查处理最终依靠到边缘的位置
- (CGPoint)_checkTargetPosition:(CGPoint)panPoint {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionViewLeanToNewTragetPosion:)]) {
        self.previousCenter = [self.delegate suspensionViewLeanToNewTragetPosion:self];
        return self.previousCenter;
    }
    
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


- (void)moveToPreviousLeanPosition {
    
    [self autoLeanToTargetPosition:self.previousCenter];
}

/// 移动移动到屏幕中心位置
- (void)moveToScreentCenter {
    
//    CGPoint screenCenter = CGPointMake((kSCREENT_WIDTH - [SuspensionControl windowForKey:self.key].bounds.size.width)*0.5, (kSCREENT_HEIGHT - [SuspensionControl windowForKey:self.key].bounds.size.height)*0.5);
    
    [self autoLeanToTargetPosition:[UIApplication sharedApplication].delegate.window.center];
}

/// 自动移动到边缘，此方法在手指松开后会自动移动到目标位置
- (void)autoLeanToTargetPosition:(CGPoint)point {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionView:willAutoLeanToTargetPosition:)]) {
        [self.delegate suspensionView:self willAutoLeanToTargetPosition:point];
    }
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:self.usingSpringWithDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
        UIWindow *w = [SuspensionControl windowForKey:self.key];
        if (w) {
            w.center = point;
        } else {
            self.center = point;
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            
            [self autoLeanToTargetPositionCompletion:point];
            _isMoving = NO;
        }
    }];
}

- (void)autoLeanToTargetPositionCompletion:(CGPoint)currentPosition {
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionView:didAutoLeanToTargetPosition:)]) {
        [self.delegate suspensionView:self didAutoLeanToTargetPosition:currentPosition];
        return;
    }
    if (self.leanFinishCallBack) {
        self.leanFinishCallBack(currentPosition);
    }
}

- (void)orientationDidChange:(NSNotification *)note {
    if (self.isAutoLeanEdge) {
        /// 屏幕旋转时检测下最终依靠的位置，防止出现屏幕旋转记录的previousCenter未更新坐标时，导致按钮不见了
        CGPoint currentPoint = [self convertPoint:self.center toView:[UIApplication sharedApplication].delegate.window];
        
        [self performSelector:@selector(_checkTargetPosition:) withObject:[NSValue valueWithCGPoint:currentPoint] afterDelay:0.0];
    }
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Actions ~~~~~~~~~~~~~~~~~~~~~~~

- (void)btnClick:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionViewClickedButton:)]) {
        [self.delegate suspensionViewClickedButton:self];
        return;
    }
    
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ setter \ getter ~~~~~~~~~~~~~~~~~~~~~~~

- (SuspensionViewLeanEdgeType)leanEdgeType {
    return _leanEdgeType ?: SuspensionViewLeanEdgeTypeEachSide;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

- (NSString *)key {
    return _isOnce ? [[SuspensionControl shareInstance] keyWithIdentifier:NSStringFromClass([self class])] : [super key];
}

- (void)setPreviousCenter:(CGPoint)previousCenter {
    _previousCenter = previousCenter;
    [[NSUserDefaults standardUserDefaults] setDouble:previousCenter.x forKey:PreviousCenterXKey];
    [[NSUserDefaults standardUserDefaults] setDouble:previousCenter.y forKey:PreviousCenterYKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


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
    [self.suspensionView setTitle:title forState:UIControlStateNormal];
}
- (void)setSuspensionImage:(UIImage *)image forState:(UIControlState)state {
    [self.suspensionView setImage:image forState:UIControlStateNormal];
}
- (void)setSuspensionImageWithImageNamed:(NSString *)name forState:(UIControlState)state {
    [self setSuspensionImage:[UIImage imageNamed:name] forState:state];
}

- (void)setSuspensionBackgroundColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    [self.suspensionView setBackgroundColor:color];
    if (cornerRadius) {
        self.suspensionView.layer.cornerRadius = cornerRadius;
        self.suspensionView.layer.masksToBounds = YES;
    }
}

- (SuspensionView *)suspensionView {
    return objc_getAssociatedObject(self, @selector(suspensionView));
}

- (void)setSuspensionView:(SuspensionView *)suspensionView {
    objc_setAssociatedObject(self, @selector(suspensionView), suspensionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
