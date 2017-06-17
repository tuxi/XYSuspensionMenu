//
//  SuspensionView.h
//  SuspensionView
//
//  Created by Ossey on 17/2/25.
//  Copyright © 2017年 Ossey All rights reserved.
//



#import <UIKit/UIKit.h>
#import "SuspensionView.h"

NS_ASSUME_NONNULL_BEGIN


@class SuspensionView, SuspensionMenuView, MenuBarHypotenuseButton, MenuBarHypotenuseItem;


@interface SuspensionControl : NSObject

@property (nonatomic, strong, class, readonly) SuspensionControl *shareInstance;

+ (NSDictionary<NSString *, UIWindow *> *)windows;

+ (UIWindow *)windowForKey:(NSString *)key;
+ (void)setWindow:(UIWindow *)window forKey:(NSString *)key;
+ (void)removeWindowForKey:(NSString *)key;
+ (void)removeWindow:(UIWindow *)aWindow;
+ (void)removeAllWindows;

@end






NS_ASSUME_NONNULL_END
