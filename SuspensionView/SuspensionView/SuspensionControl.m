//
//  SuspensionView.m
//  SuspensionView
//
//  Created by mofeini on 17/2/25.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "SuspensionControl.h"
#import "Masonry.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

@interface SuspensionViewController : UIViewController

@end

@implementation SuspensionViewController

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end

@interface SuspensionView ()

@property (nonatomic, copy) void (^moveFinishCallBack)();
@property (nonatomic, copy) void (^clickCallBack)();
@property (nonatomic, assign) CGPoint previousCenter;
@property (nonatomic, copy) NSString *currentKey;

@property (nonatomic, assign) BOOL isOnce;

@end

@implementation SuspensionView

- (NSString *)currentKey {
    return _isOnce ? [SuspensionControl shareInstance].key : self.key;
}


#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self addActions];
        [self addObserver];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
        [self addActions];
        [self addObserver];
    }
    return self;
}

- (void)setupUI {
    self.alpha = 0.7;
    self.verticalLeanMargin = 20.0;
    self.horizontalLeanMargin = 0.0;

}

- (void)addActions {
    
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
    pan.delaysTouchesBegan = YES;
    [self addGestureRecognizer:pan];
    
    [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
  
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recoveryPosition:) name:UIDeviceOrientationDidChangeNotification object:nil];
}


#pragma mark - Public
- (void)suspensionView:(void (^)())block {
    
    UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    UIWindow *suspensionWindow = [[UIWindow alloc] initWithFrame:self.frame];
    suspensionWindow.windowLevel = UIWindowLevelAlert * 2;
    [suspensionWindow makeKeyAndVisible];
    // 给window设置rootViewController是为了当屏幕旋转时，winwow跟随旋转并更新坐标
    SuspensionViewController *vc = [SuspensionViewController new];
    suspensionWindow.rootViewController = vc;
    // 不设置此属性，window在选择时，会出现四周黑屏现象
    [suspensionWindow.layer setMasksToBounds:YES];

    
    [SuspensionControl setWindow:suspensionWindow forKey:self.currentKey];
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.clipsToBounds = YES;
    
    [vc.view addSubview:self];
    
    // 保持原先的keyWindow，避免一些不必要的问题
    [currentKeyWindow makeKeyWindow];

    if (block) {
        block();
    }

}

- (void)release:(void (^)())block {
    
    if (block) {
        block();
    }
    // 销毁强引用对象
    self.clickCallBack = nil;
    self.moveFinishCallBack = nil;
    [self removeFromSuperview];
    [SuspensionControl removeWindowForKey:self.currentKey];

}

- (void)moveFinishCallBack:(void (^)())callback {
    self.moveFinishCallBack = callback;
}

- (void)clickCallback:(void (^)())callback {
    self.clickCallBack = callback;
}


#pragma mark - Private
- (void)locationChange:(UIPanGestureRecognizer *)p {
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [p locationInView:appWindow];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1.0;
    }else if(p.state == UIGestureRecognizerStateChanged) {
        
        [SuspensionControl windowForKey:self.currentKey].center = CGPointMake(panPoint.x, panPoint.y);
        
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        self.alpha = 0.7;
        
        [self checkTargetPosition:panPoint];
    }

}


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
    CGPoint newCenter;
    CGFloat targetY = 0;
    
    // 校正垂直方向
    if (panPoint.y < self.verticalLeanMargin + touchHeight / 2.0 + self.verticalLeanMargin) {
        targetY = self.verticalLeanMargin + touchHeight / 2.0 + self.verticalLeanMargin;
    }else if (panPoint.y > (screenHeight - touchHeight / 2.0 - self.verticalLeanMargin)) {
        targetY = screenHeight - touchHeight / 2.0 - self.verticalLeanMargin;
    }else{
        targetY = panPoint.y;
    }
    
    // 根据移动的方向,设置目标值
    if (minSpace == left) {          // 往左边移动
        newCenter = CGPointMake(touchWidth / 2 + self.horizontalLeanMargin, targetY);
    }else if (minSpace == right) {   // 往右边移动
        newCenter = CGPointMake(screenWidth - touchWidth / 2 - self.horizontalLeanMargin, targetY);
    }else if (minSpace == top) {     // 往顶部移动
        newCenter = CGPointMake(panPoint.x, touchHeight / 2 + self.verticalLeanMargin);
    }else if (minSpace == bottom) {  // 往底部移动
        newCenter = CGPointMake(panPoint.x, screenHeight - touchHeight / 2 - self.verticalLeanMargin);
    }
    
    [self updatePositionWithConter:newCenter];

}

/// 更新中心点
- (void)updatePositionWithConter:(CGPoint)center {
    [UIView animateWithDuration:0.2 delay:0.1 usingSpringWithDamping:5 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [SuspensionControl windowForKey:self.currentKey].center = center;
    
    } completion:^(BOOL finished) {
        // 记录当前的center
        self.previousCenter = center;
//        NSLog(@"%@", NSStringFromCGPoint(self.previousCenter));
        if (self.moveFinishCallBack) {
            self.moveFinishCallBack();
        }
    }];
}

#pragma mark - Actions
- (void)btnClick:(UIButton *)btn {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}

- (void)recoveryPosition:(NSNotification *)note {
    
    // 根据移动的方向转换坐标,让气回到默认的位置
//    CGPoint center;
    
//    NSDictionary *ntfDict = [note userInfo];
    
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    switch (orient) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
            

        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
//            NSLog(@"%@", NSStringFromCGPoint(self.previousCenter));
//            center = CGPointMake(self.previousCenter.y, self.previousCenter.x);
//             [self updatePositionWithConter:center];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右横置");
//            center = CGPointMake(self.previousCenter.y, self.previousCenter.x);
//            [self updatePositionWithConter:center];
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法识别");
            break;
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

/// 存放window的字典
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIWindow *> *windows;

@end

@implementation SuspensionControl

@synthesize hidden = _isHidden;



#pragma mark - public methods

+ (SuspensionView *)suspensionViewOnce:(BOOL)isOnce frame:(CGRect)frame block:(void(^)())block {
    
    SuspensionView *s = [[SuspensionView alloc] initWithFrame:frame];
    s.isOnce = isOnce;
    [s suspensionView:block];
    [SuspensionControl shareInstance].suspensionView = s;
    return s;
}


+ (void)releaseAll:(void (^)())block {
    
    [[SuspensionControl shareInstance].suspensionView release:block];
    [[SuspensionControl shareInstance].suspensionView removeFromSuperview];
    [SuspensionControl shareInstance].suspensionView = nil;
    [SuspensionControl removeAllWindows];
}

+ (void)releaseSuspensionView:(SuspensionView *)view block:(void (^)())block {
   
    [SuspensionControl removeWindowForKey:view.key];
    if (block) {
        block();
    }
}


- (void)setHidden:(BOOL)hidden {
    _isHidden = hidden;
    UIWindow *w = [SuspensionControl windowForKey:self.suspensionView.currentKey];
    w.hidden = hidden;
}


- (BOOL)isHidden {
    return [SuspensionControl windowForKey:self.suspensionView.currentKey].isHidden;
}

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

#pragma mark - getter
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


@implementation NSObject (SuspensionMD5)

- (void)setKey:(NSString *)key {
    objc_setAssociatedObject(self, @selector(key), key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)key {
    NSString * key = objc_getAssociatedObject(self, @selector(key));
    if (!key.length) {
        self.key = (key = [self md5:self.description]);
    }
    return key;
}


// 对字符串进行md5加密
- (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


@end



