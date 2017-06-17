//
//  SuspensionView.m
//  SuspensionView
//
//  Created by Ossey on 2017/6/16.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "SuspensionView.h"
#import "SuspensionControl.h"

@interface SuspensionView ()

@property (nonatomic, copy) void (^movingCallBack)();
@property (nonatomic, copy) void (^beginMoveCallBack)();
@property (nonatomic, assign) CGPoint previousCenter;
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

//- (void)leanToPosition:(CGPoint)point{
//    CGPoint newPoint = [self convertPoint:point toView:[UIApplication sharedApplication].delegate.window];
//    [self autoLeanToTargetPosition:newPoint];
//}

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
        
        [self performSelector:@selector(_checkTargetPosition:) withObject:[NSValue valueWithCGPoint:currentPoint] afterDelay:0.0];
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

