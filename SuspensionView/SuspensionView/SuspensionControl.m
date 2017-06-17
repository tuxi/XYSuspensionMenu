//
//  SuspensionView.m
//  SuspensionView
//
//  Created by Ossey on 17/2/25.
//  Copyright © 2017年 Ossey All rights reserved.
//

#import "SuspensionControl.h"
#import <objc/runtime.h>

#pragma clang diagnostic ignored "-Wundeclared-selector"



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
//    [self.suspensionView setTitle:title forState:state];
    [self.suspensionView setTitle:title];
}
- (void)setSuspensionImage:(UIImage *)image forState:(UIControlState)state {
//    [self.suspensionView setImage:image forState:state];
    [self.suspensionView setImage:image];
}
- (void)setSuspensionImageWithImageNamed:(NSString *)name forState:(UIControlState)state {
    if ([name isEqualToString:@"partner_expedia"]) {
        //        [self setHiddenSuspension:YES];
        //        self.suspensionView.invalidHidden = YES;
        //        name = @"scallcentergroup2.png";
    }
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

