//
//  XYSuspensionQuestionAnswerMatchView.h
//  XYSuspensionMenuDemo
//
//  Created by swae on 2018/1/15.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "XYSuspensionMenu.h"

@class XYSuspensionQuestionAnswerMatchView;

@interface UIApplication (XYSuspensionQuestionAnswerMatchView)

@property (nonatomic) XYSuspensionQuestionAnswerMatchView *xy_suspensionQuestionAnsweView;

- (XYSuspensionQuestionAnswerMatchView *)xy_showSuspensionQuestionAnswerMatchViewithCompletion:(void (^)(BOOL finished))completion;
- (BOOL)xy_hideSuspensionQuestionAnswerMatchViewWithCompletion:(void (^)(BOOL finished))completion;
- (void)xy_toggleSuspensionQuestionAnswerMatchViewWithCompletion:(void (^)(BOOL finished))completion;

@end

@interface XYSuspensionQuestionAnswerMatchView : SuspensionWindow

@property (nonatomic, strong) NSAttributedString *attributedText;

@end
