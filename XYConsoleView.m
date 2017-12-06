//
//  XYConsoleView.m
//  XYConsoleView
//
//  Created by xiaoyuan on 05/12/2017.
//  Copyright © 2017 xiaoyuan. All rights reserved.
//

#ifdef __OBJC__

#import <Foundation/Foundation.h>

NSNotificationName const XYConsoleDidChangeLogNotification = @"XYConsoleDidChangeLogNotification";

NS_INLINE NSMutableString *xy_logSting() {
    static NSMutableString *xy_logSting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xy_logSting = NSMutableString.new;
    });
    return xy_logSting;
}

NS_INLINE NSDateFormatter *dataFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = NSDateFormatter.new;
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    return formatter;
}

NS_INLINE void xy_print(NSString *msg) {
    @autoreleasepool {
        NSString *tempMsg = msg.copy;
        tempMsg = [NSString stringWithFormat:@"*** %@ %@ ***\n\n",[dataFormatter() stringFromDate:[NSDate new]],  msg];
        const char *cStr = NULL;
        if ([tempMsg canBeConvertedToEncoding:NSUTF8StringEncoding]) {
            cStr = [tempMsg cStringUsingEncoding:NSUTF8StringEncoding];
            printf("%s", cStr);
        }
        [xy_logSting() appendString:tempMsg];
        
#if DEBUG
        
        dispatch_block_t block = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:XYConsoleDidChangeLogNotification object:xy_logSting()];
        };
        
        if ([NSThread isMainThread]) {
            block();
        }
        else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
#endif
    }
}

void xy_log(NSString *format, ...) {
    @autoreleasepool {
        va_list args;
        
        if (format) {
            va_start(args, format);
            
            NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
            
            xy_print(message);
        }
        
    }
    
}

#endif

#import "XYConsoleView.h"
#import <objc/runtime.h>
#import "XYSuspensionMenu.h"


@interface XYDummyView : UIView

@property (nonatomic, weak) UIButton *button;
@property (nonatomic, weak) UIButton *clearButton;

@end

@interface XYConsoleView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) XYDummyView *dummyView;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic) CGAffineTransform currentTransform;
@property (nonatomic) CGFloat lastScale;
@property (nonatomic, strong) UITextView *consoleTextView;

- (void)xy_showWithCompletion:(void (^)(BOOL finished))completion;
- (void)xy_hideWithCompletion:(void (^)(BOOL finished))completion;;

@end

@implementation UIApplication (XYConsole)

- (void)setXy_consoleView:(XYConsoleView *)xy_consoleView {
    objc_setAssociatedObject(self, @selector(xy_consoleView), xy_consoleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XYConsoleView *)xy_consoleView {
    XYConsoleView *view = objc_getAssociatedObject(self, _cmd);
    return view;
}

- (XYConsoleView *)xy_showConsoleWithCompletion:(void (^)(BOOL))completion {
    XYConsoleView *view = [self xy_consoleView];
    if (!view) {
        SuspensionMenuWindow *menu = [UIApplication sharedApplication].xy_suspensionMenuWindow;
        CGPoint centerBtnPoint = menu.centerButton.frame.origin;
        centerBtnPoint = [menu.centerButton convertPoint:centerBtnPoint toView:[UIApplication sharedApplication].delegate.window];
        view = [[XYConsoleView alloc] initWithFrame:CGRectMake(centerBtnPoint.x, centerBtnPoint.y, 0, 0)];
        self.xy_consoleView = view;
    }
    [self.delegate.window addSubview:view];
    if (view.isShow) {
        return view;
    }
    [view xy_showWithCompletion:^(BOOL finished) {
        CGRect rect = CGRectMake(0, view.consoleTextView.contentSize.height-15, view.consoleTextView.contentSize.width, 10);
        [view.consoleTextView scrollRectToVisible:rect animated:YES];
        if (completion) {
            completion(finished);
        }
    }];
    return view;
}

- (BOOL)xy_hideConsoleWithCompletion:(void (^)(BOOL))completion {
    XYConsoleView *view = [self xy_consoleView];
    if (!view) {
        return NO;
    }
    [view xy_hideWithCompletion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
    
    return YES;
}

- (void)xy_toggleConsoleWithCompletion:(void (^)(BOOL))completion {
    if (self.xy_consoleView.isShow) {
        [self xy_hideConsoleWithCompletion:completion];
    }
    else {
        [self xy_showConsoleWithCompletion:completion];
    }
}

@end

@implementation XYConsoleView

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
    [self addConsoleTextViewConstraint];
    [self addDummyViewConstraint];
}

- (void)addConsoleTextViewConstraint {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.consoleTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dummyView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.consoleTextView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.consoleTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.consoleTextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [NSLayoutConstraint activateConstraints:@[top, left, right, bottom]];
    
}

- (void)addDummyViewConstraint {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.dummyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.dummyView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.dummyView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.dummyView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [NSLayoutConstraint activateConstraints:@[top, left, right, height]];
    
}

- (UITextView *)consoleTextView {
    
    if (!_consoleTextView) {
        UITextView *textView = [[UITextView alloc] init];
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        _consoleTextView = textView;
    }
    return _consoleTextView;
}

- (XYDummyView *)dummyView {
    if (!_dummyView) {
        _dummyView = [[XYDummyView alloc] initWithFrame:CGRectZero];
        _dummyView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _dummyView;
}

- (void)commonInit {
    self.leanEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
     _lastScale = 1.0;
    self.backgroundColor = [UIColor whiteColor];
    self.consoleTextView.backgroundColor = [UIColor whiteColor];
    self.consoleTextView.editable = NO;
    self.consoleTextView.textColor = [UIColor blackColor];
    self.consoleTextView.selectable = NO;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapOnSelf:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:pinchGestureRecognizer];
    [self addGestureRecognizer:tapGestureRecognizer];
    [self.dummyView.button addTarget:self action:@selector(xy_hide) forControlEvents:UIControlEventTouchUpInside];
    [self.dummyView.clearButton addTarget:self action:@selector(clearConsoleLog:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clearConsoleLog:(UIButton *)btn {
    [xy_logSting() setString:@""];
    [self setText:@""];
}

- (void)pinchView:(UIPinchGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        _currentTransform = self.transform;
        
    }
    
    if (gesture.state ==UIGestureRecognizerStateChanged) {
        
        CGAffineTransform tr = CGAffineTransformScale(_currentTransform,
                                                      gesture.scale,
                                                      gesture.scale);
        
        self.transform = tr;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                self.frame.size.height);
        
        
    }
    
    if ((gesture.state == UIGestureRecognizerStateEnded) ||
        (gesture.state == UIGestureRecognizerStateCancelled)) {
        
        _lastScale =_lastScale*gesture.scale;
    }
}

- (void)doubleTapOnSelf:(UITapGestureRecognizer *)tapGesture {
    
    if (self.show == NO) {
        [self xy_showWithCompletion:^(BOOL finished) {
            
        }];
    }
    else {
        [self xy_hideWithCompletion:^(BOOL finished) {
            
        }];
        
    }
}

- (void)xy_showWithCompletion:(void (^)(BOOL finished))completion {
    self.consoleTextView.scrollEnabled = YES;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = [UIScreen mainScreen].bounds;
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
    SuspensionMenuWindow *menu = [UIApplication sharedApplication].xy_suspensionMenuWindow;
    
    UIView *targetView = (UIView *)menu.currentResponderItem.hypotenuseButton;
    if (!targetView) {
        targetView = menu.centerButton;
    }
    CGPoint targetPoint = targetView.frame.origin;
    targetPoint = [targetView convertPoint:targetPoint toView:[UIApplication sharedApplication].delegate.window];
    
    self.consoleTextView.scrollEnabled = NO;
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

- (void)setText:(NSString *)text {
    self.consoleTextView.text = text;
}

- (NSString *)text {
    return self.consoleTextView.text;
}

- (void)didChangeInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (self.isShow) {
        
        [self setTransform:CGAffineTransformIdentity];
        
        CGRect rect = self.frame;
        rect.size = [UIScreen mainScreen].bounds.size;
        self.frame = rect;
        
    }
  
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}
@end

@implementation XYDummyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubview];
    }
    
    return self;
}

- (void)setupSubview {
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
    bottomButton.backgroundColor = [UIColor grayColor];
    self.backgroundColor = [UIColor clearColor];
    [bottomButton setTitle:@"轻拍或拖拽" forState:UIControlStateNormal];
    [self addSubview:bottomButton];
    NSLayoutConstraint *bottomButtonTop = [NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bottomButton.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
    NSLayoutConstraint *bottomButtonBottom = [NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomButton.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomButtonLeft = [NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:bottomButton.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [NSLayoutConstraint activateConstraints:@[bottomButtonTop, bottomButtonLeft, bottomButtonBottom]];
    
    self.button = bottomButton;
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    clearButton.backgroundColor = [UIColor grayColor];
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    [self addSubview:clearButton];
    NSLayoutConstraint *clearButtonTop = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bottomButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *clearButtonRight = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
     NSLayoutConstraint *clearButtonBottom = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
     NSLayoutConstraint *clearButtonLeft = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:bottomButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
     NSLayoutConstraint *clearButtonWidth = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80.0];
    [NSLayoutConstraint activateConstraints:@[clearButtonTop, clearButtonRight, clearButtonBottom, clearButtonLeft, clearButtonWidth]];
    self.clearButton = clearButton;
}

@end

