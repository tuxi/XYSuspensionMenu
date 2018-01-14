//
//  XYConsoleView.m
//  XYConsoleView
//
//  Created by xiaoyuan on 05/12/2017.
//  Copyright © 2017 alpface. All rights reserved.
//

#import "XYConsoleView.h"
#import <objc/runtime.h>
#import "XYDummyView.h"

#if __OBJC__

@implementation NSTimer (XYBlocks)

+ (instancetype)xy_timerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats block:(void (^)(void))block {
    void (^tempBlock)(void) = [block copy];
    NSTimer *timer = [self timerWithTimeInterval:timeInterval target:self selector:@selector(xy_timerBlock:) userInfo:tempBlock repeats:repeats];
    return timer;
}

+ (void)xy_timerBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(void) = (void (^)(void))[timer userInfo];
        block();
    }
}

@end

static NSMutableAttributedString *xy_logSting = nil;
static NSDateFormatter *formatter = nil;
static NSTimer *logTimer = nil;
static NSLock *lock;

NSNotificationName const XYConsoleDidChangeLogNotification = @"XYConsoleDidChangeLogNotification";

__attribute__((constructor)) static void XYConsoleInitialize(void) {
    @autoreleasepool {
        xy_logSting = NSMutableAttributedString.new;
        formatter = NSDateFormatter.new;
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        lock = [NSLock new];
#if DEBUG
        // 优化日志回调，使用[NSRunLoop mainRunLoop]会比回到主线程性能好很多
        // 发觉在子线程中打印log，再回到主线程中显示log会很卡，开启NSTimer每秒钟执行一次显示log，性能会好很多
        logTimer = [NSTimer xy_timerWithTimeInterval:1.0 repeats:YES block:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:XYConsoleDidChangeLogNotification object:xy_logSting];
        }];
        // 发送log所在runLoop的mode使用NSRunLoopCommonModes，不然scrollView滚动时接收不到log
        [[NSRunLoop mainRunLoop] addTimer:logTimer forMode:NSDefaultRunLoopMode];
#endif
    }
}

__attribute__((destructor)) static void XYConsoleDealloc(void) {
    xy_logSting = nil;
    formatter = nil;
    lock = nil;
    if (logTimer.isValid) {
        [logTimer invalidate];
        logTimer = nil;
    }
}

static void sync_log_block(dispatch_block_t block) {
    if (!block) {
        return;
    }
    
    [lock lock];
    block();
    [lock unlock];
    
}


NS_INLINE void xy_print(NSString *msg) {
    @autoreleasepool {
        if (!msg) {
            return;
        }
        sync_log_block(^{
            // 开始打印时，恢复之前的log颜色
            [xy_logSting addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, xy_logSting.length)];
            
            NSMutableAttributedString *currentAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"*** %@ %@ ***\n\n",[formatter stringFromDate:[NSDate new]],  msg]];
            const char *cStr = NULL;
            if ([currentAttributedString.string canBeConvertedToEncoding:NSUTF8StringEncoding]) {
                cStr = [currentAttributedString.string cStringUsingEncoding:NSUTF8StringEncoding];
                printf("%s", cStr);
            }
            
            // 设置当前log的颜色为红色
            [currentAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, currentAttributedString.length)];
            [xy_logSting appendAttributedString:currentAttributedString];
        });
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
        XYSuspensionMenu *menu = [UIApplication sharedApplication].xy_suspensionMenu;
        CGPoint centerBtnPoint = menu.centerButton.frame.origin;
        centerBtnPoint = [menu.centerButton convertPoint:centerBtnPoint toView:[UIApplication sharedApplication].delegate.window];
        view = [[XYConsoleView alloc] initWithFrame:CGRectMake(centerBtnPoint.x, centerBtnPoint.y, 0, 0)];
        self.xy_consoleView = view;
    }
    [self.delegate.window addSubview:view];
    if (view.isShow) {
        return view;
    }
    view.attributedText = xy_logSting;
    [view xy_showWithCompletion:^(BOOL finished) {
        [view.consoleTextView scrollRangeToVisible:NSMakeRange(view.consoleTextView.text.length, 1)];
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
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapOnSelf)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:pinchGestureRecognizer];
    [self addGestureRecognizer:tapGestureRecognizer];
    [self.dummyView.button addTarget:self action:@selector(doubleTapOnSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.dummyView.clearButton addTarget:self action:@selector(clearConsoleLog:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clearConsoleLog:(UIButton *)btn {
    [xy_logSting deleteCharactersInRange:NSMakeRange(0, xy_logSting.length)];
    [self setAttributedText:xy_logSting];
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
    XYSuspensionMenu *menu = [UIApplication sharedApplication].xy_suspensionMenu;
    
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



