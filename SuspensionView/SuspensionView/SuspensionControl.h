//
//  SuspensionView.h
//  SuspensionView
//
//  Created by Ossey on 17/2/25.
//  Copyright © 2017年 Ossey All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 悬浮控件自动移动到屏幕边缘的类型
typedef NS_ENUM(NSUInteger, SuspensionViewLeanEdgeType) {
    SuspensionViewLeanEdgeTypeHorizontal = 1,  /// 自动依靠到屏幕左右边缘
    SuspensionViewLeanEdgeTypeEachSide         /// 自动依靠到屏幕四边
};

@class SuspensionView, SuspensionMenuView, MenuBarHypotenuseButton;

@protocol SuspensionWindowProtocol <NSObject>

/// 创建悬浮控件
/// isOnce属性为YES时，每次调用都会展示一个，但最终只会展示一个悬浮控件，保存在字典时，key相同，value被覆盖掉
/// isOnce当为NO时重复调用此方法，可展示多个，注意：每调用一次就创建并展示一个
+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame;

/// 释放持有的所有window
+ (void)releaseAll;

- (void)dismiss:(void (^ _Nullable)(void))block;

@end

@interface UIResponder (SuspensionView)

- (SuspensionView *)showSuspensionViewWithFrame:(CGRect)frame;
- (void)dismissSuspensionView:(void (^)())block;
- (void)setHiddenSuspension:(BOOL)flag;
- (BOOL)isHiddenSuspension;
- (void)setSuspensionTitle:(NSString *)title forState:(UIControlState)state;
- (void)setSuspensionImage:(UIImage *)image forState:(UIControlState)state;
- (void)setSuspensionImageWithImageNamed:(NSString *)name forState:(UIControlState)state;

@end

@interface SuspensionControl : NSObject

@property (nonatomic, strong, class, readonly) SuspensionControl *shareInstance;

+ (UIWindow *)windowForKey:(NSString *)key;
+ (void)setWindow:(UIWindow *)window forKey:(NSString *)key;
+ (void)removeWindowForKey:(NSString *)key;
+ (void)removeWindow:(UIWindow *)aWindow;
+ (void)removeAllWindows;

@end


@interface SuspensionView : UIButton

/// 悬浮控件支持停靠屏幕哪些边缘，默认为上下左右
@property (nonatomic, assign) SuspensionViewLeanEdgeType leanEdgeType;
/// 依靠屏幕边缘的间距, 默认上为20，下左右为0
@property (nonatomic, assign) UIEdgeInsets leanEdgeInsets;
@property (nonatomic, assign) BOOL invalidHidden;
@property (nonatomic, assign) BOOL isMoving;
/// 范围的为0.0f到1.0f，数值越小「弹簧」的振动效果越明显
@property (nonatomic, assign) CGFloat usingSpringWithDamping;
/// 表示初始的速度，数值越大一开始移动越快
@property (nonatomic, assign) CGFloat initialSpringVelocity;

@property (nonatomic, copy) void (^locationChange)(CGPoint currentPoint);

@property (nonatomic, weak, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, copy) void (^ _Nullable leanFinishCallBack)(CGPoint centerPoint);

/// 默认为YES，会在移动完成后，自动依靠到边缘
@property (nonatomic, assign, getter=isAutoLeanEdge) BOOL autoLeanEdge;

- (void)clickCallback:(void (^)())callback;
- (void)defaultAnimation;
/// 移动移动到屏幕中心位置
- (void)leanToScreentCenter;
/// 移动到上次依靠的位置
- (void)leanToPreviousLeanPosition;
/// 根据当前SuspensionView所处中心点检查处理最终依靠到边缘的位置
- (void)checkTargetPosition;

- (void)dismiss:(void (^ _Nullable)(void))block;

@end

@interface SuspensionWindow : SuspensionView <SuspensionWindowProtocol>

@end

@interface SuspensionMenuView : UIView

//@property (nonatomic, strong) UIImage *centerItemBackgroundImage;
@property (nonatomic, copy) void (^ _Nullable menuBarClickBlock)(NSInteger index);
/// 当显示SuspensionMenuView的时候，依靠到屏幕中心位置
@property (nonatomic, assign) BOOL shouldLeanToScreenCenterWhenShow;
/// 当初始化SuspensionMenuView的时候，显示SuspensionMenuView
@property (nonatomic, assign) BOOL shouldShowWhenViewWillAppear;
/// 根据menuBarImages创建对应menuBar，最多只能有6个
@property (nonatomic, strong, nullable) NSArray<MenuBarHypotenuseButton *> *menuBarItems;
@property (nonatomic, weak, readonly) SuspensionView *centerButton;
@property (nonatomic, weak, readonly) UIImageView *backgroundImView;

- (void)show;
- (void)dismiss;

- (void)pushViewController:(UIViewController *)viewController;

@end

@interface SuspensionMenuWindow : SuspensionMenuView <SuspensionWindowProtocol>

+ (instancetype)showOnce:(BOOL)isOnce menuBarItems:(NSArray<MenuBarHypotenuseButton *> *)menuBarItems;

@end

/// 斜边使用的按钮
@interface MenuBarHypotenuseButton : UIButton

@end

@interface NSObject (SuspensionKey)

@property (nonatomic, copy) NSString *key;

- (NSString *)keyWithIdentifier:(NSString *)indetifier;

@end

@interface UIWindow (SuspensionWindow)

@property (nonatomic, weak, nullable) SuspensionView *suspensionView;
@property (nonatomic, weak, nullable) SuspensionMenuView *suspensionMenuView;

@end

NS_ASSUME_NONNULL_END
