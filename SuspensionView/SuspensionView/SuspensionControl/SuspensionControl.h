//
//  SuspensionView.h
//  SuspensionView
//
//  Created by Ossey on 17/2/25.
//  Copyright © 2017年 Ossey All rights reserved.
//


#import <UIKit/UIKit.h>

#define kSCREENT_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kSCREENT_WIDTH [UIScreen mainScreen].bounds.size.width

NS_ASSUME_NONNULL_BEGIN
@class SuspensionView, SuspensionMenuView, MenuBarHypotenuseButton, MenuBarHypotenuseItem;


typedef NS_ENUM(NSInteger, OSButtonType) {
    OSButtonTypeDefault,
    OSButtonType1,
    OSButtonType2,
    OSButtonType3,
    OSButtonType4
};

@protocol SuspensionViewDelegate <NSObject>

@optional
- (void)suspensionViewClickedButton:(SuspensionView *)suspensionView;
- (void)suspensionView:(SuspensionView *)suspensionView locationChange:(UIPanGestureRecognizer *)pan;
- (CGPoint)leanToNewTragetPosionForSuspensionView:(SuspensionView *)suspensionView;
- (void)suspensionView:(SuspensionView *)suspensionView didAutoLeanToTargetPosition:(CGPoint)position;
- (void)suspensionView:(SuspensionView *)suspensionView willAutoLeanToTargetPosition:(CGPoint)position;

@end

@protocol SuspensionMenuViewDelegate <NSObject>

@optional
- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedHypotenuseButtonAtIndex:(NSInteger)buttonIndex;
- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView clickedCenterButton:(SuspensionView *)centerButton;
- (void)suspensionMenuViewDidShow:(SuspensionMenuView *)suspensionMenuView;
- (void)suspensionMenuViewDidDismiss:(SuspensionMenuView *)suspensionMenuView;
- (void)suspensionMenuView:(SuspensionMenuView *)suspensionMenuView centerButtonLocationChange:(UIPanGestureRecognizer *)pan;

@end


@interface OSCustomButton : UIControl

@property (nonatomic, assign) OSButtonType buttonType;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *contentColor;
@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, strong) UIColor *borderAnimateColor;
@property (nonatomic, strong) UIColor *contentAnimateColor;
@property (nonatomic, strong) UIColor *foregroundAnimateColor;
@property (nonatomic, assign) BOOL restoreSelectedState;
@property (nonatomic, assign) BOOL fadeInOutOnDisplay;
@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UILabel *detailLabel;
@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

- (instancetype)initWithFrame:(CGRect)frame;
+ (instancetype)buttonWithType:(OSButtonType)buttonType;
- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setSubtitle:(NSString *)subtitle forState:(UIControlState)state;
- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state;

@end

typedef NS_ENUM(NSUInteger, SuspensionViewLeanEdgeType) {
    SuspensionViewLeanEdgeTypeHorizontal = 1,  /// 自动依靠到屏幕左右边缘
    SuspensionViewLeanEdgeTypeEachSide         /// 自动依靠到屏幕四边
};

@interface SuspensionView : OSCustomButton

@property (nonatomic, weak) id<SuspensionViewDelegate> delegate;

@property (nonatomic, assign) BOOL isOnce;

@property (nonatomic, assign) SuspensionViewLeanEdgeType leanEdgeType;
@property (nonatomic, assign) UIEdgeInsets leanEdgeInsets;
@property (nonatomic, assign) BOOL invalidHidden;
@property (nonatomic, assign, readonly) BOOL isMoving;
@property (nonatomic, weak, readonly) UIPanGestureRecognizer *panGestureRecognizer;
/// 范围的为0.0f到1.0f，数值越小「弹簧」的振动效果越明显
@property (nonatomic, assign) CGFloat usingSpringWithDamping;
/// 表示初始的速度，数值越大一开始移动越快
@property (nonatomic, assign) CGFloat initialSpringVelocity;
@property (nonatomic, copy, nullable) void (^locationChange)(CGPoint currentPoint);
@property (nonatomic, copy, nullable) void (^ leanFinishCallBack)(CGPoint centerPoint);
@property (nonatomic, assign, getter=isAutoLeanEdge) BOOL autoLeanEdge;
@property (nonatomic, copy, nullable) void (^clickCallBack)();
@property (nonatomic, assign) BOOL shouldLeanToPreviousPositionWhenAppStart;

- (void)moveToScreentCenter;
- (void)moveToPreviousLeanPosition;
- (void)checkTargetPosition;

@end

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

@interface SuspensionWindow : SuspensionView

+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame;
- (void)removeFromSuperview;
+ (void)releaseAll;

@end

@interface SuspensionMenuView : UIView

@property (nonatomic, weak) id<SuspensionMenuViewDelegate> delegate;

@property (nonatomic, assign) BOOL isOnce;
@property (nonatomic, copy) void (^ _Nullable menuBarClickBlock)(NSInteger index);
@property (nonatomic, assign) BOOL shouldLeanToScreenCenterWhenShow;
@property (nonatomic, strong, readonly) NSArray<MenuBarHypotenuseItem *> *menuBarItems;
@property (nonatomic, weak, readonly) SuspensionView *centerButton;
@property (nonatomic, weak, readonly) UIImageView *backgroundImageView;
@property (nonatomic, copy) void (^ _Nullable showCompletion)();
@property (nonatomic, copy) void (^ _Nullable dismissCompletion)();

- (void)setMenuBarItems:(NSArray<MenuBarHypotenuseItem *> *)menuBarItems
               itemSize:(CGSize)itemSize;

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

@property (nonatomic, strong, readonly) OSCustomButton *hypotenuseButton;
- (instancetype)initWithButtonType:(OSButtonType)buttonType;

@end

@interface UIWindow (SuspensionWindow)

@property (nonatomic, weak, nullable) SuspensionView *suspensionView;
@property (nonatomic, weak, nullable) SuspensionMenuView *suspensionMenuView;

@end

@interface SuspensionControl : NSObject

@property (nonatomic, strong, class, readonly) SuspensionControl *shareInstance;

+ (NSDictionary<NSString *, UIWindow *> *)windows;

+ (UIWindow *)windowForKey:(NSString *)key;
+ (void)setWindow:(UIWindow *)window forKey:(NSString *)key;
+ (void)removeWindowForKey:(NSString *)key;
+ (void)removeWindow:(UIWindow *)aWindow;
+ (void)removeAllWindows;

@end

@interface NSObject (SuspensionKey)

@property (nonatomic, copy) NSString *key;

- (NSString *)keyWithIdentifier:(NSString *)indetifier;

@end


NS_ASSUME_NONNULL_END
