//
//  XYSuspensionWebView.m
//  VideoTweak
//
//  Created by swae on 2018/1/14.
//  Copyright © 2018年 alpface. All rights reserved.
//

#import "XYSuspensionWebView.h"
#import <objc/runtime.h>
#import "UIWebView+XYBlocks.h"
#import "XYDummyView.h"

#define XYWebViewheight [UIScreen mainScreen].bounds.size.height*0.45

@interface XYSuspensionWebView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) XYDummyView *dummyView;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSMutableURLRequest *request;

- (void)xy_showWithCompletion:(void (^)(BOOL finished))completion;
- (void)xy_hideWithCompletion:(void (^)(BOOL finished))completion;;

@end

@implementation UIApplication (XYSuspensionWebView)

- (void)setXy_suspensionWebView:(XYSuspensionWebView *)xy_suspensionWebView {
    objc_setAssociatedObject(self, @selector(xy_suspensionWebView), xy_suspensionWebView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XYSuspensionWebView *)xy_suspensionWebView {
    XYSuspensionWebView *view = objc_getAssociatedObject(self, _cmd);
    return view;
}

- (XYSuspensionWebView *)xy_showWebViewWithCompletion:(void (^)(BOOL finished))completion {
    XYSuspensionWebView *webView = [self xy_suspensionWebView];
    if (!webView) {
        XYSuspensionMenu *menu = [UIApplication sharedApplication].xy_suspensionMenu;
        CGPoint centerBtnPoint = menu.centerButton.frame.origin;
        centerBtnPoint = [menu.centerButton convertPoint:centerBtnPoint toView:[UIApplication sharedApplication].delegate.window];
        webView = [[XYSuspensionWebView alloc] initWithFrame:CGRectMake(centerBtnPoint.x, centerBtnPoint.y, 0, 0)];
        self.xy_suspensionWebView = webView;
        [self.delegate.window addSubview:webView];
    }
    if (webView.isShow) {
        return webView;
    }
    [webView xy_showWithCompletion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
    return webView;
}

- (BOOL)xy_hideWebViewWithCompletion:(void (^)(BOOL))completion {
    XYSuspensionWebView *webView = [self xy_suspensionWebView];
    if (!webView) {
        return NO;
    }
    [webView xy_hideWithCompletion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
    
    return YES;
}

- (void)xy_toggleWebViewWithCompletion:(void (^)(BOOL))completion {
    if (self.xy_suspensionWebView.isShow) {
        [self xy_hideWebViewWithCompletion:completion];
    }
    else {
        [self xy_showWebViewWithCompletion:completion];
    }
}

@end

@implementation XYSuspensionWebView

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
    [self addSubview:self.webView];
    [self addSubview:self.dummyView];
    [self addViewsConstraint];
    [self addDummyViewConstraint];
}

- (void)addViewsConstraint {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dummyView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
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

- (UIWebView *)webView {
    if (!_webView) {
        UIWebView *webView  = [[UIWebView alloc] initWithFrame:CGRectZero];
        webView.translatesAutoresizingMaskIntoConstraints = NO;
        webView.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView = webView;
    }
    return _webView;
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
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.dummyView.button addTarget:self action:@selector(doubleTapOnSelf) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *tit = [[NSAttributedString alloc] initWithString:@"【轻拍顶部区域两次】或【按住拖拽】" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:13.0]}];
    [self.dummyView.button setAttributedTitle:tit forState:UIControlStateNormal];
    [self.dummyView hideCleanButton];
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

- (NSMutableURLRequest *)request {
    
    if (!_request) {
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        request.timeoutInterval = 8.0;
        _request = request;
    }
    return _request;
}


- (void)setUrlString:(NSString *)urlString {
    if ([urlString isEqualToString:_urlString] || !urlString.length) {
        return;
    }
    
    self.request.URL = [NSURL URLWithString:urlString];
    
    [self.webView loadRequest:self.request
                                      loaded:^(UIWebView *aWebView) {
                                          NSLog(@"Loaded %@", aWebView.request.URL);
                                          
                                      }
                                      failed:^(UIWebView *aWebView, NSError *error) {
                                          NSLog(@"Failed loading with error: %@", error.localizedDescription);
                                      }
                                 loadStarted:^(UIWebView *aWebView) {
                                     NSLog(@"Started loading");
                                 }
                                  shouldLoad:^BOOL(UIWebView *aWebView, NSURLRequest *request, UIWebViewNavigationType navigationType) {
                                      return YES;
                                  }];
    
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



