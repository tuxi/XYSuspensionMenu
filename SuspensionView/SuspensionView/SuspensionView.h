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

@class SuspensionView;

@protocol SuspensionViewDelegate <NSObject>

- (void)suspensionViewDidClickedButton:(SuspensionView *)suspensionView;
- (void)suspensionView:(SuspensionView *)suspensionView locationChange:(UIPanGestureRecognizer *)pan;
- (CGPoint)leanToNewTragetPosionForSuspensionView:(SuspensionView *)suspensionView;
- (void)suspensionView:(SuspensionView *)suspensionView didAutoLeanToTargetPosition:(CGPoint)position;
- (void)suspensionView:(SuspensionView *)suspensionView willAutoLeanToTargetPosition:(CGPoint)position;

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

NS_ASSUME_NONNULL_END
