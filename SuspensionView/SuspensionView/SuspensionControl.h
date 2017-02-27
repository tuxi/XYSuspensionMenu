//
//  SuspensionView.h
//  SuspensionView
//
//  Created by mofeini on 17/2/25.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//



#import <UIKit/UIKit.h>


/// 悬浮控件自动移动到屏幕边缘的类型
typedef NS_ENUM(NSUInteger, SuspensionViewLeanType) {
    SuspensionViewLeanTypeHorizontal = 1,  /// 自动依靠到屏幕左右边缘
    SuspensionViewLeanTypeEachSide         /// 自动依靠到屏幕四边
};

@class SuspensionView;

@interface SuspensionControl : NSObject

@property (nonatomic, strong) SuspensionView *suspensionView;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

+ (instancetype)shareInstance;
+ (UIWindow *)windowForKey:(NSString *)key;
+ (void)setWindow:(UIWindow *)window forKey:(NSString *)key;
+ (void)removeWindowForKey:(NSString *)key;
+ (void)removeAllWindows;

/// 创建悬浮控件
/// isOnce属性为YES时，每次调用都会展示一个，但最终只会展示一个悬浮控件，保存在字典时，key相同，value被覆盖掉
/// isOnce当为NO时重复调用此方法，可展示多个，注意：每调用一次就创建并展示一个
+ (SuspensionView *)suspensionViewOnce:(BOOL)isOnce frame:(CGRect)frame block:(void(^)())block;

/// 释放持有的所有window
+ (void)releaseAll:(void (^)())block;

/// 通过key释放持有的一个window,
+ (void)releaseSuspensionView:(SuspensionView *)view block:(void (^)())block;


@end

@interface SuspensionView : UIButton

/// 悬浮控件支持停靠屏幕哪些边缘，默认为上下左右
@property (nonatomic, assign) SuspensionViewLeanType leanType;
/// 依靠屏幕顶部和底部边缘的间距, 默认为20
@property (nonatomic, assign) CGFloat verticalLeanMargin;
/// 依靠屏幕左侧和右侧边缘的间距, 默认为0
@property (nonatomic, assign) CGFloat horizontalLeanMargin;


- (void)suspensionView:(void(^)())block;
- (void)release:(void(^)())block;
- (void)clickCallback:(void (^)())callback;
- (void)moveFinishCallBack:(void (^)())callback;

@end

@interface NSObject (SuspensionMd5)

@property (nonatomic, copy) NSString *key;

- (NSString *)md5:(NSString *)str;

@end



