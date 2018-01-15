//
//  XYSuspensionWebView.h
//  VideoTweak
//
//  Created by swae on 2018/1/14.
//  Copyright © 2018年 alpface. All rights reserved.
//

#import "XYSuspensionMenu.h"

@class XYSuspensionWebView;

@interface UIApplication (XYSuspensionWebView)

@property (nonatomic) XYSuspensionWebView *xy_suspensionWebView;

- (XYSuspensionWebView *)xy_showWebViewWithCompletion:(void (^)(BOOL finished))completion;
- (BOOL)xy_hideWebViewWithCompletion:(void (^)(BOOL finished))completion;
- (void)xy_toggleWebViewWithCompletion:(void (^)(BOOL finished))completion;

@end

@interface XYSuspensionWebView : SuspensionWindow

@property (nonatomic, copy) NSString *urlString;

@end

