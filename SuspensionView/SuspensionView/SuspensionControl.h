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
typedef NS_ENUM(NSUInteger, SuspensionViewLeanType) {
    SuspensionViewLeanTypeHorizontal = 1,  /// 自动依靠到屏幕左右边缘
    SuspensionViewLeanTypeEachSide         /// 自动依靠到屏幕四边
};

@class SuspensionView, SuspensionMenuView;

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

+ (instancetype)shareInstance;

+ (UIWindow *)windowForKey:(NSString *)key;
+ (void)setWindow:(UIWindow *)window forKey:(NSString *)key;
+ (void)removeWindowForKey:(NSString *)key;
+ (void)removeWindow:(UIWindow *)aWindow;
+ (void)removeAllWindows;

@end


@interface SuspensionView : UIButton

/// 悬浮控件支持停靠屏幕哪些边缘，默认为上下左右
@property (nonatomic, assign) SuspensionViewLeanType leanType;
/// 依靠屏幕顶部和底部边缘的间距, 默认为20
@property (nonatomic, assign) CGFloat verticalLeanMargin;
/// 依靠屏幕左侧和右侧边缘的间距, 默认为0
@property (nonatomic, assign) CGFloat horizontalLeanMargin;
@property (nonatomic, assign) BOOL invalidHidden;
@property (nonatomic, assign) BOOL isMoving;
/// 范围的为0.0f到1.0f，数值越小「弹簧」的振动效果越明显
@property (nonatomic, assign) CGFloat usingSpringWithDamping;
/// 表示初始的速度，数值越大一开始移动越快
@property (nonatomic, assign) CGFloat initialSpringVelocity;

@property (nonatomic, copy) void (^locationChange)(CGPoint currentPoint);

@property (nonatomic, weak, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/// 是否移动到边缘
@property (nonatomic, assign, getter=isMoveToLean) BOOL moveToLean;

- (void)clickCallback:(void (^)())callback;
- (void)defaultAnimation;

- (void)dismiss:(void (^ _Nullable)(void))block;
@end

@interface SuspensionWindow : SuspensionView <SuspensionWindowProtocol>

@end


@interface SuspensionMenuView : UIView


@property (nonatomic, strong) UIImage *centerBarBackgroundImage;
@property (nonatomic, copy) void (^ _Nullable menuBarClickBlock)(NSInteger index);

/// 最多只能6个menu bar 按钮
- (void)setMenuBarImages:(NSArray<UIImage *> * _Nullable)menuBarImages titles:(NSArray<NSString *> * _Nullable)titles;

/// 恢复默认状态
- (void)recoverToNormalStatus;
- (void)dismiss;
- (void)show;

//// Push View Controller
- (void)pushViewController:(UIViewController *)viewController;

@end

@interface SuspensionMenuWindow : SuspensionMenuView <SuspensionWindowProtocol>

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
