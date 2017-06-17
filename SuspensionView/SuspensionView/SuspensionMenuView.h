//
//  SuspensionMenuView.h
//  SuspensionView
//
//  Created by Ossey on 2017/6/16.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuspensionView.h"

@class SuspensionView, SuspensionMenuView, MenuBarHypotenuseButton, MenuBarHypotenuseItem;

@protocol SuspensionWindowProtocol <NSObject>

/// 创建悬浮控件
/// isOnce属性为YES时，每次调用都会展示一个，但最终只会展示一个悬浮控件，保存在字典时，key相同，value被覆盖掉
/// isOnce当为NO时重复调用此方法，可展示多个，注意：每调用一次就创建并展示一个
+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame;

/// 释放持有的所有window
+ (void)releaseAll;

- (void)dismiss:(void (^ _Nullable)(void))block;

@end

@interface SuspensionWindow : SuspensionView <SuspensionWindowProtocol>

@end

@interface SuspensionMenuView : UIView

@property (nonatomic, copy) void (^ _Nullable menuBarClickBlock)(NSInteger index);
/// 当显示SuspensionMenuView的时候，依靠到屏幕中心位置
@property (nonatomic, assign) BOOL shouldLeanToScreenCenterWhenShow;
/// 根据menuBarImages创建对应menuBar，最多只能有6个
@property (nonatomic, strong, nullable) NSArray<MenuBarHypotenuseItem *> *menuBarItems;
@property (nonatomic, weak, readonly) SuspensionView *centerButton;
@property (nonatomic, weak, readonly) UIImageView *backgroundImageView;
@property (nonatomic, copy) void (^ _Nullable showCompletion)();
@property (nonatomic, copy) void (^ _Nullable dismissCompletion)();

- (void)show;
- (void)dismiss;

- (void)pushViewController:(UIViewController *)viewController;

@end

@interface SuspensionMenuWindow : SuspensionMenuView <SuspensionWindowProtocol>

@property (nonatomic, assign) BOOL shouldShowWhenViewWillAppear;

+ (instancetype)showWithMenuBarItems:(NSArray<MenuBarHypotenuseItem *> *)menuBarItems menuSize:(CGSize)menuSize itemSize:(CGSize)itemSize;

@end

@interface MenuBarHypotenuseItem : NSObject
@property (nonatomic, strong, readonly) MenuBarHypotenuseButton *hypotenuseButton;
@end

@interface MenuBarHypotenuseButton : UIButton

@end



@interface UIWindow (SuspensionWindow)

@property (nonatomic, weak, nullable) SuspensionView *suspensionView;
@property (nonatomic, weak, nullable) SuspensionMenuView *suspensionMenuView;

@end
