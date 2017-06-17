//
//  SuspensionView.h
//  SuspensionView
//
//  Created by Ossey on 2017/6/16.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+SuspensionKey.h"
#import "OSCustomButton.h"

NS_ASSUME_NONNULL_BEGIN

#define kSCREENT_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kSCREENT_WIDTH [UIScreen mainScreen].bounds.size.width


/// 悬浮控件自动移动到屏幕边缘的类型
typedef NS_ENUM(NSUInteger, SuspensionViewLeanEdgeType) {
    SuspensionViewLeanEdgeTypeHorizontal = 1,  /// 自动依靠到屏幕左右边缘
    SuspensionViewLeanEdgeTypeEachSide         /// 自动依靠到屏幕四边
};

@interface SuspensionView : OSCustomButton

@property (nonatomic, copy) NSString *currentKey;
@property (nonatomic, assign) BOOL isOnce;

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

@property (nonatomic, copy) void (^clickCallBack)();

- (void)clickCallback:(void (^)())callback;
- (void)defaultAnimation;
/// 移动移动到屏幕中心位置
- (void)leanToScreentCenter;
/// 移动到上次依靠的位置
- (void)leanToPreviousLeanPosition;
//- (void)leanToPosition:(CGPoint)point;
/// 根据当前SuspensionView所处中心点检查处理最终依靠到边缘的位置
- (void)checkTargetPosition;

- (void)dismiss:(void (^ _Nullable)(void))block;

@end

NS_ASSUME_NONNULL_END
