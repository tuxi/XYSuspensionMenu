//
//  XYSuspensionQuestionAnswerMatchView.m
//  XYSuspensionMenuDemo
//
//  Created by swae on 2018/1/15.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "XYSuspensionQuestionAnswerMatchView.h"
#import <objc/runtime.h>
#import "XYDummyView.h"

#define XYWebViewheight [UIScreen mainScreen].bounds.size.height*0.45

@interface XYSuspensionQuestionAnswerMatchView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) XYDummyView *dummyView;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, strong) UITextView *consoleTextView;

- (void)xy_showWithCompletion:(void (^)(BOOL finished))completion;
- (void)xy_hideWithCompletion:(void (^)(BOOL finished))completion;;

@end



@implementation UIApplication (XYSuspensionQuestionAnswerMatchView)

- (void)setXy_suspensionQuestionAnsweView:(XYSuspensionQuestionAnswerMatchView *)xy_suspensionQuestionAnsweView {
    objc_setAssociatedObject(self, @selector(xy_suspensionQuestionAnsweView), xy_suspensionQuestionAnsweView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XYSuspensionQuestionAnswerMatchView *)xy_suspensionQuestionAnsweView {
    XYSuspensionQuestionAnswerMatchView *view = objc_getAssociatedObject(self, _cmd);
    return view;
}


- (XYSuspensionQuestionAnswerMatchView *)xy_showSuspensionQuestionAnswerMatchViewithCompletion:(void (^)(BOOL))completion {
    XYSuspensionQuestionAnswerMatchView *matchView = [self xy_suspensionQuestionAnsweView];
    if (!matchView) {
        XYSuspensionMenu *menu = [UIApplication sharedApplication].xy_suspensionMenu;
        CGPoint centerBtnPoint = menu.centerButton.frame.origin;
        centerBtnPoint = [menu.centerButton convertPoint:centerBtnPoint toView:[UIApplication sharedApplication].delegate.window];
        matchView = [[XYSuspensionQuestionAnswerMatchView alloc] initWithFrame:CGRectMake(centerBtnPoint.x, centerBtnPoint.y, 0, 0)];
        self.xy_suspensionQuestionAnsweView = matchView;
        [self.delegate.window addSubview:matchView];
    }
    if (matchView.isShow) {
        return matchView;
    }
    [matchView xy_showWithCompletion:^(BOOL finished) {
        [matchView.consoleTextView scrollRangeToVisible:NSMakeRange(matchView.consoleTextView.text.length, 1)];
        if (completion) {
            completion(finished);
        }
    }];
    return matchView;
}

- (BOOL)xy_hideSuspensionQuestionAnswerMatchViewWithCompletion:(void (^)(BOOL))completion {
    XYSuspensionQuestionAnswerMatchView *matchView = [self xy_suspensionQuestionAnsweView];
    if (!matchView) {
        return NO;
    }
    [matchView xy_hideWithCompletion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
    
    return YES;
}

- (void)xy_toggleSuspensionQuestionAnswerMatchViewWithCompletion:(void (^)(BOOL))completion {
    if (self.xy_suspensionQuestionAnsweView.isShow) {
        [self xy_hideSuspensionQuestionAnswerMatchViewWithCompletion:completion];
    }
    else {
        [self xy_showSuspensionQuestionAnswerMatchViewithCompletion:completion];
    }
}

@end

@implementation XYSuspensionQuestionAnswerMatchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self commonInit];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.consoleTextView];
    [self addSubview:self.dummyView];
    [self addViewsConstraint];
    [self addDummyViewConstraint];
}

- (void)addViewsConstraint {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.consoleTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dummyView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.consoleTextView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.consoleTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.consoleTextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [NSLayoutConstraint activateConstraints:@[top, left, right, bottom]];
    
}

- (void)addDummyViewConstraint {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.dummyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.dummyView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.dummyView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.dummyView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [NSLayoutConstraint activateConstraints:@[top, left, right, height]];
    [self.dummyView getButtonTopConstraint].constant = 0;
    
}

- (UITextView *)consoleTextView {
    
    if (!_consoleTextView) {
        UITextView *textView = [[UITextView alloc] init];
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        _consoleTextView = textView;
        // 是否非连续布局属性，如果设置为YES就会导致每次调用scrollRangeToVisible::时都会从顶部跳到最后一行
        // 防止TextView重置滑动
        _consoleTextView.layoutManager.allowsNonContiguousLayout = NO;
    }
    return _consoleTextView;
}


- (XYDummyView *)dummyView {
    if (!_dummyView) {
        _dummyView = [[XYDummyView alloc] initWithFrame:CGRectZero];
        _dummyView.translatesAutoresizingMaskIntoConstraints = NO;
        _dummyView.button.backgroundColor = [UIColor colorWithRed:38/255.0 green:21/255.0 blue:53/255.0 alpha:1.0];
    }
    return _dummyView;
}

- (void)commonInit {
    self.leanEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.backgroundColor = [UIColor whiteColor];
    self.consoleTextView.backgroundColor = [UIColor whiteColor];
    self.consoleTextView.editable = NO;
    self.consoleTextView.textColor = [UIColor blackColor];
    self.consoleTextView.selectable = NO;
    [self.dummyView.button addTarget:self action:@selector(doubleTapOnSelf) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *tit = [[NSAttributedString alloc] initWithString:@"【轻拍顶部区域两次】或【按住拖拽】" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:13.0]}];
    [self.dummyView.button setAttributedTitle:tit forState:UIControlStateNormal];
    [self.dummyView hideCleanButton];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (!self.isShow) {
        return;
    }
    self.consoleTextView.attributedText = attributedText;
    if (self.consoleTextView.isDecelerating || self.consoleTextView.isDragging) {
        return;
    }
    [self.consoleTextView scrollRangeToVisible:NSMakeRange(attributedText.length, 1)];
}

- (NSString *)text {
    return self.consoleTextView.text;
}

- (NSAttributedString *)attributedText {
    return self.consoleTextView.attributedText;
}



- (void)doubleTapOnSelf {
    if (self.show == NO) {
        [self xy_showWithCompletion:^(BOOL finished) {
            [[UIApplication sharedApplication].xy_suspensionMenu close];
        }];
    }
    else {
        [[UIApplication sharedApplication].xy_suspensionMenu openWithCompetion:^(BOOL finished) {
            [self xy_hideWithCompletion:^(BOOL finished) {
                [[UIApplication sharedApplication].xy_suspensionMenu close];
            }];
        }];
    }
}

- (void)xy_showWithCompletion:(void (^)(BOOL finished))completion {
    self.consoleTextView.scrollEnabled = YES;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat h = XYWebViewheight;
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-h, [UIScreen mainScreen].bounds.size.width, h);
    } completion:^(BOOL finished) {
        self.show = YES;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)xy_show {
    [self xy_showWithCompletion:NULL];
}

- (void)xy_hideWithCompletion:(void (^)(BOOL finished))completion {
    XYSuspensionMenu *menu = [UIApplication sharedApplication].xy_suspensionMenu;
    
    UIView *targetView = (UIView *)menu.currentResponderItem.hypotenuseButton;
    if (!targetView) {
        targetView = menu.centerButton;
    }
    CGPoint targetPoint = targetView.frame.origin;
    targetPoint = [targetView convertPoint:targetPoint toView:[UIApplication sharedApplication].delegate.window];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = CGRectMake(targetPoint.x, targetPoint.y, 0, 0);
    } completion:^(BOOL finished) {
        self.show = NO;
        [self setTransform:CGAffineTransformIdentity];
        if (completion) {
            completion(finished);
        }
    }];
}



- (void)xy_hide {
    [self xy_hideWithCompletion:NULL];
}


- (void)didChangeInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (self.isShow) {
        CGRect rect = self.frame;
        rect.origin.y = [UIScreen mainScreen].bounds.size.height - XYWebViewheight;
        rect.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, XYWebViewheight);
        self.frame = rect;
        
    }
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}
@end
