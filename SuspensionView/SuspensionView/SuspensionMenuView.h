//
//  SuspensionMenuView.h
//  SuspensionView
//
//  Created by Ossey on 2017/6/16.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuspensionView.h"


NS_ASSUME_NONNULL_BEGIN

@class SuspensionView, SuspensionMenuView, MenuBarHypotenuseButton, MenuBarHypotenuseItem;


@interface SuspensionWindow : SuspensionView 

+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame;
- (void)removeFromSuperview;
+ (void)releaseAll;

@end

@interface SuspensionMenuView : UIView

@property (nonatomic, assign) BOOL isOnce;
@property (nonatomic, copy) void (^ _Nullable menuBarClickBlock)(NSInteger index);
/// 当显示SuspensionMenuView的时候，依靠到屏幕中心位置
@property (nonatomic, assign) BOOL shouldLeanToScreenCenterWhenShow;
/// 根据menuBarImages创建对应menuBar，最多只能有6个
@property (nonatomic, strong, readonly) NSArray<MenuBarHypotenuseItem *> *menuBarItems;
@property (nonatomic, weak, readonly) SuspensionView *centerButton;
@property (nonatomic, weak, readonly) UIImageView *backgroundImageView;
@property (nonatomic, copy) void (^ _Nullable showCompletion)();
@property (nonatomic, copy) void (^ _Nullable dismissCompletion)();

- (void)setMenuBarItems:(NSArray<MenuBarHypotenuseItem *> *)menuBarItems itemSize:(CGSize)itemSize;

- (void)show;
- (void)dismiss;

- (void)pushViewController:(UIViewController *)viewController;

@end

@interface SuspensionMenuWindow : SuspensionMenuView

@property (nonatomic, assign) BOOL shouldShowWhenViewWillAppear;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)removeFromSuperview;
+ (void)releaseAll;

@end

@interface MenuBarHypotenuseItem : NSObject
@property (nonatomic, strong, readonly) MenuBarHypotenuseButton *hypotenuseButton;
@end

@interface MenuBarHypotenuseButton : OSCustomButton

@end

@interface UIWindow (SuspensionWindow)

@property (nonatomic, weak, nullable) SuspensionView *suspensionView;
@property (nonatomic, weak, nullable) SuspensionMenuView *suspensionMenuView;

@end

NS_ASSUME_NONNULL_END
