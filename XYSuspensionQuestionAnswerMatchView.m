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

static CGFloat const adjustmentValue = 5.0;
static NSString * const XYSuspensionQuestionAnswerMatchViewHeightkey = @"XYSuspensionQuestionAnswerMatchViewHeightkey";

@interface XYSuspensionQuestionAnswerMatchView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) XYDummyView *dummyView;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, strong) UITextView *consoleTextView;
@property (nonatomic, strong) UIButton *adjustmentHeightButton1;
@property (nonatomic, strong) UIButton *adjustmentHeightButton2;
@property (nonatomic, strong)  id feedbackGenerator;

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
    [self.dummyView addSubview:self.adjustmentHeightButton1];
    [self.dummyView addSubview:self.adjustmentHeightButton2];
    [self addViewsConstraint];
    [self addDummyViewConstraint];
    [self addAdjustmentHeightButtonConstraint];
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
- (void)addAdjustmentHeightButtonConstraint {
    NSLayoutConstraint *buttonTop = [NSLayoutConstraint constraintWithItem:self.adjustmentHeightButton1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dummyView.button  attribute:NSLayoutAttributeTop multiplier:1.0 constant:.0];
    NSLayoutConstraint *buttomBottom = [NSLayoutConstraint constraintWithItem:self.adjustmentHeightButton1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.dummyView.button attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *buttonLeft = [NSLayoutConstraint constraintWithItem:self.adjustmentHeightButton1 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.dummyView.button attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *buttonWidth = [NSLayoutConstraint constraintWithItem:self.adjustmentHeightButton1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80.0];
    [NSLayoutConstraint activateConstraints:@[buttonTop, buttonLeft, buttonWidth, buttomBottom]];
    
    NSLayoutConstraint *button1Top = [NSLayoutConstraint constraintWithItem:self.adjustmentHeightButton2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dummyView.button  attribute:NSLayoutAttributeTop multiplier:1.0 constant:.0];
    NSLayoutConstraint *buttom1Bottom = [NSLayoutConstraint constraintWithItem:self.adjustmentHeightButton2 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.dummyView.button  attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *button1Right = [NSLayoutConstraint constraintWithItem:self.adjustmentHeightButton2 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.dummyView.button  attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *button1Width = [NSLayoutConstraint constraintWithItem:self.adjustmentHeightButton2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.adjustmentHeightButton1 attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [NSLayoutConstraint activateConstraints:@[button1Top, buttom1Bottom, button1Right, button1Width]];
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
        _dummyView.button.backgroundColor = [UIColor colorWithRed:38/255.0 green:238/255.0 blue:38/255.0 alpha:1.0];
    }
    return _dummyView;
}

- (UIButton *)adjustmentHeightButton1 {
    if (!_adjustmentHeightButton1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor clearColor];
        _adjustmentHeightButton1 = button;
        button.accessibilityIdentifier = NSStringFromSelector(_cmd);
        [button addTarget:self action:@selector(adjustmentHeightAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"-" forState:UIControlStateNormal];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        if (@available(iOS 11.0, *)) {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
        } else {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
    return _adjustmentHeightButton1;
}

- (UIButton *)adjustmentHeightButton2 {
    if (!_adjustmentHeightButton2) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor clearColor];
        _adjustmentHeightButton2 = button;
        button.accessibilityIdentifier = NSStringFromSelector(_cmd);
        [button addTarget:self action:@selector(adjustmentHeightAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"+" forState:UIControlStateNormal];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        if (@available(iOS 11.0, *)) {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentTrailing;
        } else {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
    }
    return _adjustmentHeightButton2;
}


- (void)commonInit {
    self.leanEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.backgroundColor = [UIColor whiteColor];
    self.consoleTextView.backgroundColor = [UIColor whiteColor];
    self.consoleTextView.editable = NO;
    self.consoleTextView.textColor = [UIColor blackColor];
    self.consoleTextView.selectable = NO;
    [self.dummyView.button addTarget:self action:@selector(doubleTapOnSelf) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *tit = [[NSAttributedString alloc] initWithString:@"【轻拍顶部】或【按住拖拽】" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:13.0]}];
    [self.dummyView.button setAttributedTitle:tit forState:UIControlStateNormal];
    [self.dummyView hideCleanButton];
    if (@available(iOS 10.0, *)) {
        _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    }
}

- (void)adjustmentHeightAction:(UIButton *)btn {
    // 减少高度
    if ([btn.accessibilityIdentifier isEqualToString:@"adjustmentHeightButton1"]) {
        CGRect rect = self.frame;
        rect.size.height-=adjustmentValue;
        rect.origin.y+=adjustmentValue;
        self.frame = rect;
    }
    // 增加高度
    else if ([btn.accessibilityIdentifier isEqualToString:@"adjustmentHeightButton2"]) {
        CGRect rect = self.frame;
        rect.size.height+=adjustmentValue;
        rect.origin.y-=adjustmentValue;
        self.frame = rect;
    }
    
    [self setWebViewheight:self.frame.size.height];
    
    [self impactOccurred];
}

- (void)impactOccurred {
    void (^tapticBlock)(void) = ^{
        // 到达边缘时触发taptic反馈
        if (@available(iOS 10.0, *)) {
            [(UIImpactFeedbackGenerator *)_feedbackGenerator impactOccurred];
        }
        
    };
    
    tapticBlock();
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
        CGFloat h = [self getWebViewHeight];
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

- (CGFloat)getWebViewHeight {
    NSNumber *heightNum = [[NSUserDefaults standardUserDefaults] objectForKey:XYSuspensionQuestionAnswerMatchViewHeightkey];
    if (!heightNum) {
        return [UIScreen mainScreen].bounds.size.height*0.45;
    }
    return MAX(0.0, heightNum.floatValue);
}

- (void)setWebViewheight:(CGFloat)height {
    [[NSUserDefaults standardUserDefaults] setObject:@(height) forKey:XYSuspensionQuestionAnswerMatchViewHeightkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)xy_hide {
    [self xy_hideWithCompletion:NULL];
}


- (void)didChangeInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (self.isShow) {
        CGRect rect = self.frame;
        rect.origin.y = [UIScreen mainScreen].bounds.size.height - [self getWebViewHeight];
        rect.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [self getWebViewHeight]);
        self.frame = rect;
        
    }
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}
@end
