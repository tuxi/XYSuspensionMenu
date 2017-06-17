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


@interface UIResponder (SuspensionView)

- (SuspensionView *)showSuspensionViewWithFrame:(CGRect)frame;
- (void)dismissSuspensionView:(void (^)())block;
- (void)setHiddenSuspension:(BOOL)flag;
- (BOOL)isHiddenSuspension;
- (void)setSuspensionTitle:(NSString *)title forState:(UIControlState)state;
- (void)setSuspensionImage:(UIImage *)image forState:(UIControlState)state;
- (void)setSuspensionImageWithImageNamed:(NSString *)name forState:(UIControlState)state;
- (void)setSuspensionBackgroundColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;
@end

@interface SuspensionControl : NSObject

@property (nonatomic, strong, class, readonly) SuspensionControl *shareInstance;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, UIWindow *> *windows;

+ (UIWindow *)windowForKey:(NSString *)key;
+ (void)setWindow:(UIWindow *)window forKey:(NSString *)key;
+ (void)removeWindowForKey:(NSString *)key;
+ (void)removeWindow:(UIWindow *)aWindow;
+ (void)removeAllWindows;

@end






NS_ASSUME_NONNULL_END
