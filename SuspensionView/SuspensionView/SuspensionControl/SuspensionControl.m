//
//  SuspensionView.m
//  SuspensionView
//
//  Created by Ossey on 17/2/25.
//  Copyright © 2017年 Ossey All rights reserved.
//

#import "SuspensionControl.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

#pragma clang diagnostic ignored "-Wundeclared-selector"

#define OS_MAX_CORNER_RADIUS    MIN(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5)
#define OS_MAX_BORDER_WIDTH     OS_MAX_CORNER_RADIUS
#define OS_PADDING_VALUE        0.29

typedef NS_ENUM(NSInteger, OSButtonStyle) {
    OSButtonStyleDefault,
    OSButtonStyleSubTitle,
    OSButtonStyleCentralImage,
    OSButtonStyleImageWithSubtitle
};


typedef void(^OSButtonAnimateBlock)();

static CGRect CGRectEdgeInset(CGRect rect, UIEdgeInsets insets)
{
    return CGRectMake(CGRectGetMinX(rect) + insets.left,
                      CGRectGetMinY(rect) + insets.top,
                      CGRectGetWidth(rect) - insets.left - insets.right,
                      CGRectGetHeight(rect) - insets.top - insets.bottom);
}



@interface OSLabelContentView : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign) BOOL usingMaskView;

@end

@implementation OSLabelContentView

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.minimumScaleFactor = 0.1;
        _textLabel.numberOfLines = 2;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        if (_usingMaskView) {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                self.maskView = _textLabel;
            } else {
                self.layer.mask = _textLabel.layer;
            }
        }
        
    }
    return _textLabel;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = self.bounds;
}

@end

@interface OSImageConentView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL usingMaskView;

@end

@implementation OSImageConentView

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
        if (_usingMaskView) {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                self.maskView = _imageView;
            } else {
                self.layer.mask = _imageView.layer;
            }
        }
        
    }
    return _imageView;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    
}

@end


@interface OSCustomButton ()

@property (nonatomic, assign, getter=isTrackingInside) BOOL trackingInside;
@property (nonatomic, strong) UIView *foregroundView;
@property (nonatomic, strong) OSLabelContentView *titleContentView;
@property (nonatomic, strong) OSLabelContentView *detailContentView;
@property (nonatomic, strong) OSImageConentView *imageContentView;
@property (nonatomic, assign) OSButtonStyle buttonStyle;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) UIImage *image;

@end


@implementation OSCustomButton
{
    /// 保存修改背景颜色之前的背景颜色
    UIColor *_backgroundColorCache;
    
}

@synthesize
contentColor = _contentColor,
foregroundColor = _foregroundColor,
titleLabel = _titleLabel,
detailLabel = _detailLabel,
imageView = _imageView;

////////////////////////////////////////////////////////////////////////
#pragma mark - initialize
////////////////////////////////////////////////////////////////////////

+ (instancetype)buttonWithType:(OSButtonType)buttonType  {
    return [[self alloc] initWithFrame:CGRectZero buttonType:buttonType];
}

- (instancetype)initWithFrame:(CGRect)frame buttonType:(OSButtonType)type {
    if (self = [self initWithFrame:frame]) {
        self.buttonType = type;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        _restoreSelectedState = YES;
        _trackingInside = NO;
        _cornerRadius = 0.0;
        _borderWidth = 0.0;
        _contentEdgeInsets = UIEdgeInsetsZero;
        _fadeInOutOnDisplay = YES;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////

- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state {
    _titleContentView.textLabel.textColor = color;
}


- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    if (_title == title) {
        return;
    }
    _title = title;
    [self setNeedsLayout];
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}
- (void)setSubtitle:(NSString *)subtitle forState:(UIControlState)state {
    if (_subtitle == subtitle) {
        return;
    }
    _subtitle = subtitle;
    [self setNeedsLayout];
    self.detailLabel.text = subtitle;
    [self.detailLabel sizeToFit];
}
- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (_image == image) {
        return;
    }
    _image = image;
    [self setNeedsLayout];
    self.imageView.image = image;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - layout
////////////////////////////////////////////////////////////////////////

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setButtonType:self.buttonType];
    
    CGFloat cornerRadius = self.layer.cornerRadius = MAX(MIN(OS_MAX_CORNER_RADIUS, self.cornerRadius), 0);
    CGFloat borderWidth = self.layer.borderWidth = MAX(MIN(OS_MAX_BORDER_WIDTH, self.borderWidth), 0);
    
    _borderWidth = borderWidth;
    _cornerRadius = cornerRadius;
    
    CGFloat layoutBorderWidth = borderWidth == 0.0 ? 0.0 : borderWidth - 0.1;
    self.foregroundView.frame = CGRectMake(layoutBorderWidth,
                                           layoutBorderWidth,
                                           CGRectGetWidth(self.bounds) - layoutBorderWidth * 2,
                                           CGRectGetHeight(self.bounds) - layoutBorderWidth * 2);
    self.foregroundView.layer.cornerRadius = cornerRadius - borderWidth;
    switch (self.buttonStyle)
    {
        case OSButtonStyleDefault:
        {
            if (_imageContentView.usingMaskView) {
                _imageContentView.frame = CGRectNull;
                [_imageContentView removeFromSuperview];
            } else {
                _imageContentView.imageView.frame = CGRectNull;
                [_imageContentView.imageView removeFromSuperview];
            }
            if (_detailContentView.usingMaskView) {
                _detailContentView.frame = CGRectNull;
                [_detailContentView removeFromSuperview];
            } else {
                _detailContentView.textLabel.frame = CGRectNull;
                [_detailContentView.textLabel removeFromSuperview];
            }
            if (_titleContentView.usingMaskView) {
                _titleContentView.frame = [self boxingRect];
            } else {
                _titleContentView.textLabel.frame = [self boxingRect];
            }
        }
            break;
            
        case OSButtonStyleSubTitle:
        {
            CGRect boxRect = [self boxingRect];
            if (_imageContentView.usingMaskView) {
                _imageContentView.frame = CGRectNull;
                [_imageContentView removeFromSuperview];
            } else {
                _imageContentView.imageView.frame = CGRectNull;
                [_imageContentView.imageView removeFromSuperview];
            }
            if (_detailContentView.usingMaskView) {
                self.detailContentView.frame = CGRectMake(boxRect.origin.x,
                                                          CGRectGetMaxY(self.titleContentView.frame),
                                                          CGRectGetWidth(boxRect),
                                                          CGRectGetHeight(boxRect) * 0.2);
            } else {
                self.detailContentView.textLabel.frame = CGRectMake(boxRect.origin.x,
                                                                    CGRectGetMaxY(self.titleContentView.frame),
                                                                    CGRectGetWidth(boxRect),
                                                                    CGRectGetHeight(boxRect) * 0.2);
            }
            if (_titleContentView.usingMaskView) {
                self.titleContentView.frame = CGRectMake(boxRect.origin.x,
                                                         boxRect.origin.y,
                                                         CGRectGetWidth(boxRect),
                                                         CGRectGetHeight(boxRect) * 0.8);
            } else {
                self.titleContentView.textLabel.frame = CGRectMake(boxRect.origin.x,
                                                                   boxRect.origin.y,
                                                                   CGRectGetWidth(boxRect),
                                                                   CGRectGetHeight(boxRect) * 0.8);
            }
            
            
        }
            break;
            
        case OSButtonStyleCentralImage:
        {
            if (_imageContentView.usingMaskView) {
                self.imageContentView.frame = [self boxingRect];
            } else {
                self.imageContentView.imageView.frame = [self boxingRect];
            }
            if (_detailContentView.usingMaskView) {
                _detailContentView.frame = CGRectNull;
                [_detailContentView removeFromSuperview];
            } else {
                _detailContentView.textLabel.frame = CGRectNull;
                [_detailContentView.textLabel removeFromSuperview];
            }
            if (_titleContentView.usingMaskView) {
                _titleContentView.frame = CGRectNull;
                [_titleContentView removeFromSuperview];
            } else {
                _titleContentView.textLabel.frame = CGRectNull;
                [_titleContentView.textLabel removeFromSuperview];
            }
            
        }
            break;
            
        case OSButtonStyleImageWithSubtitle:
        default:
        {
            CGRect boxRect = [self boxingRect];
            
            if (_imageContentView.usingMaskView) {
                self.imageContentView.frame = CGRectMake(boxRect.origin.x,
                                                         boxRect.origin.y,
                                                         CGRectGetWidth(boxRect),
                                                         CGRectGetHeight(boxRect) * 0.8);
            } else {
                self.imageContentView.imageView.frame = CGRectMake(boxRect.origin.x,
                                                                   boxRect.origin.y,
                                                                   CGRectGetWidth(boxRect),
                                                                   CGRectGetHeight(boxRect) * 0.8);
            }
            if (_detailContentView.usingMaskView) {
                self.detailContentView.frame = CGRectMake(boxRect.origin.x,
                                                          CGRectGetMaxY(self.imageContentView.frame),
                                                          CGRectGetWidth(boxRect),
                                                          CGRectGetHeight(boxRect) * 0.2);
            } else {
                self.detailContentView.textLabel.frame = CGRectMake(boxRect.origin.x,
                                                                    CGRectGetMaxY(self.imageContentView.frame),
                                                                    CGRectGetWidth(boxRect),
                                                                    CGRectGetHeight(boxRect) * 0.2);
            }
            if (_titleContentView.usingMaskView) {
                _titleContentView.frame = CGRectNull;
                [_titleContentView removeFromSuperview];
            } else {
                _titleContentView.textLabel.frame = CGRectNull;
                [_titleContentView.textLabel removeFromSuperview];
            }
        }
            break;
    }
    
}

- (OSButtonStyle)buttonStyle {
    if ([self shouldDisplayImageView] && ![self shouldDisplayTitleLabel] && [self shouldDisplayDetailLabel]) {
        return OSButtonStyleImageWithSubtitle;
    } else if ([self shouldDisplayImageView] && ![self shouldDisplayTitleLabel] && ![self shouldDisplayDetailLabel]) {
        return OSButtonStyleCentralImage;
    } else if (![self shouldDisplayImageView] && [self shouldDisplayTitleLabel] && [self shouldDisplayDetailLabel]) {
        return OSButtonStyleSubTitle;
    } else if (![self shouldDisplayImageView] && [self shouldDisplayTitleLabel] && ![self shouldDisplayDetailLabel]) {
        return OSButtonStyleDefault;
    }
    return OSButtonStyleDefault;
}

- (CGRect)boxingRect {
    CGRect internalRect = CGRectInset(self.bounds,
                                      self.layer.cornerRadius * OS_PADDING_VALUE + self.layer.borderWidth,
                                      self.layer.cornerRadius * OS_PADDING_VALUE + self.layer.borderWidth);
    return CGRectEdgeInset(internalRect, self.contentEdgeInsets);
}

- (BOOL)shouldDisplayTitleLabel {
    return _titleLabel && _titleLabel.text.length;
}

- (BOOL)shouldDisplayDetailLabel {
    return _detailLabel && _detailLabel.text.length;
}

- (BOOL)shouldDisplayImageView {
    return _imageView && _imageView.image;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Set get
////////////////////////////////////////////////////////////////////////

- (UIColor *)contentColor {
    return _buttonType == OSButtonTypeDefault ? nil : _contentColor ?: self.tintColor;
}

- (UIColor *)foregroundColor {
    return _buttonType == OSButtonTypeDefault ? [UIColor clearColor] : _foregroundColor ?: [UIColor whiteColor];
}

- (UIView *)foregroundView {
    if (!_foregroundView && _buttonType != OSButtonTypeDefault) {
        _foregroundView = [[UIView alloc] initWithFrame:CGRectNull];
        _foregroundView.backgroundColor = self.foregroundColor;
        _foregroundView.layer.masksToBounds = YES;
        [self addSubview:_foregroundView];
    }
    return _foregroundView;
}

- (OSLabelContentView *)titleContentView {
    if (!_titleContentView) {
        _titleContentView = [[OSLabelContentView alloc] initWithFrame:CGRectNull];
        _titleContentView.backgroundColor = self.contentColor;
        _titleContentView.usingMaskView = _buttonType != OSButtonTypeDefault;
        _titleContentView.layer.masksToBounds = YES;
        if (_titleContentView.usingMaskView) {
            [self insertSubview:_titleContentView aboveSubview:self.foregroundView];
        } else {
            [self addSubview:_titleContentView.textLabel];
        }
    }
    return _titleContentView;
}

- (OSLabelContentView *)detailContentView {
    if (!_detailContentView) {
        _detailContentView = [[OSLabelContentView alloc] initWithFrame:CGRectNull];
        _detailContentView.backgroundColor = self.contentColor;
        _detailContentView.usingMaskView = _buttonType != OSButtonTypeDefault;
        _detailContentView.layer.masksToBounds = YES;
        if (_detailContentView.usingMaskView) {
            [self insertSubview:_detailContentView aboveSubview:self.foregroundView];
        } else {
            [self addSubview:_detailContentView.textLabel];
        }
    }
    return _detailContentView;
}

- (OSImageConentView *)imageContentView {
    if (!_imageContentView) {
        _imageContentView = [[OSImageConentView alloc] initWithFrame:CGRectNull];
        _imageContentView.usingMaskView = _buttonType != OSButtonTypeDefault;
        _imageContentView.backgroundColor = self.contentColor;
        _imageContentView.layer.masksToBounds = YES;
        if (_imageContentView.usingMaskView) {
            [self insertSubview:_imageContentView aboveSubview:self.foregroundView];
        } else {
            [self addSubview:_imageContentView.imageView];
        }
    }
    return _imageContentView;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth == borderWidth) {
        return;
    }
    _borderWidth = borderWidth;
    [self setNeedsLayout];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setContentColor:(UIColor *)contentColor {
    _contentColor = contentColor;
    self.titleContentView.backgroundColor = contentColor;
    self.detailContentView.backgroundColor = contentColor;
    self.imageContentView.backgroundColor = contentColor;
}

- (void)setForegroundColor:(UIColor *)foregroundColor {
    _foregroundColor = foregroundColor;
    self.foregroundView.backgroundColor = foregroundColor;
}

- (UILabel *)titleLabel {
    return _titleLabel = self.titleContentView.textLabel;
}

- (UILabel *)detailLabel {
    return _detailLabel = self.detailContentView.textLabel;
}

- (UIImageView *)imageView {
    return _imageView = self.imageContentView.imageView;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [UIView animateWithDuration:0.3 delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.foregroundView.alpha = enabled ? 1.0 : 0.5;
                     }
                     completion:nil];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (self.fadeInOutOnDisplay) {
        if (selected) {
            [UIView animateWithDuration:0.3 delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:[self fadeInBlock]
                             completion:nil];
        } else {
            [UIView animateWithDuration:0.3 delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:[self fadeOutBlock]
                             completion:nil];
        }
    } else {
        if (selected) {
            [self fadeInBlock]();
        } else {
            [self fadeOutBlock]();
        }
    }
}

- (void)setButtonType:(OSButtonType)buttonType {
    _buttonType = buttonType;
    if (buttonType == OSButtonType1) {
        self.cornerRadius = OS_MAX_BORDER_WIDTH;
        self.borderColor  = [UIColor clearColor];
        self.contentColor = [UIColor blackColor];
        self.contentAnimateColor = [UIColor whiteColor];
        self.foregroundColor = [UIColor whiteColor];
        self.foregroundAnimateColor = [UIColor clearColor];
    } else if (buttonType == OSButtonType2) {
        self.cornerRadius = OS_MAX_BORDER_WIDTH;
        self.borderWidth = 1.5;
        self.restoreSelectedState = NO;
        self.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.borderAnimateColor = [UIColor colorWithRed:120/255.0 green:1.0/255.0 blue:1.0/255.0 alpha:1.0];
        self.contentColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.contentAnimateColor = [UIColor colorWithRed:220/255.0 green:1.0/255.0 blue:1.0/255.0 alpha:1.0];
        self.foregroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        self.backgroundColor = [UIColor clearColor];
    } else if (buttonType == OSButtonType3) {
        self.cornerRadius = OS_MAX_BORDER_WIDTH;
        self.borderWidth  = 2;
        self.restoreSelectedState = NO;
        self.borderColor = [UIColor clearColor];
        self.borderAnimateColor = [UIColor whiteColor];
        self.contentColor = [UIColor whiteColor];
        self.contentAnimateColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:255.0/255.0 alpha:1.0];;
        self.foregroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.foregroundAnimateColor = [UIColor whiteColor];
    } else if (buttonType == OSButtonType4 ){
        self.contentAnimateColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.foregroundColor = [UIColor clearColor];
        self.foregroundAnimateColor = [UIColor clearColor];
    } else {
        if (_imageContentView) {
            _imageContentView.backgroundColor = [UIColor clearColor];
            _imageContentView.imageView.backgroundColor = [UIColor clearColor];
        }
    }
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Touchs
////////////////////////////////////////////////////////////////////////

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *touchView = [super hitTest:point withEvent:event];
    if ([self pointInside:point withEvent:event]) {
        return self;
    }
    return touchView;
}

/// 返回值:YES 接受用户通过addTarget:action:forControlEvents添加的事件继续处理。
/// 返回值:NO  则屏蔽用户添加的任何事件
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.trackingInside = YES;
    self.selected = !self.isSelected;
    return [super beginTrackingWithTouch:touch withEvent:event];
}

/// 判断是否保持追踪当前的触摸事件,这里根据得到的位置来判断是否正处于button的范围内，进而发送对应的事件
/// 控制OSButton的selected属性
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL wasTrackingInside = self.isTrackingInside;
    self.trackingInside = [self isTouchInside];
    /*
     if (wasTrackingInside && !self.isTrackingInside) {
     self.selected = !self.isSelected;
     } else if (!wasTrackingInside && self.isTrackingInside) {
     self.selected = !self.isSelected;
     }
     */
    if (wasTrackingInside != self.isTrackingInside) {
        self.selected = !self.isSelected;
    }
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.trackingInside = [self isTouchInside];
    if (self.isTrackingInside && self.restoreSelectedState) {
        self.selected = !self.isSelected;
    }
    self.trackingInside = NO;
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    self.trackingInside = [self isTouchInside];
    if (self.trackingInside) {
        self.selected = !self.isSelected;
    }
    self.trackingInside = NO;
    [super cancelTrackingWithEvent:event];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Animate
////////////////////////////////////////////////////////////////////////

- (OSButtonAnimateBlock)fadeInBlock {
    return ^ {
        if (self.contentAnimateColor) {
            self.titleContentView.backgroundColor = self.contentAnimateColor;
            self.detailContentView.backgroundColor = self.contentAnimateColor;
            self.imageContentView.backgroundColor = self.contentAnimateColor;
        }
        
        if (self.borderAnimateColor && self.foregroundAnimateColor && self.borderAnimateColor == self.foregroundAnimateColor) {
            _backgroundColorCache = self.backgroundColor;
            self.foregroundView.backgroundColor = [UIColor clearColor];
            self.backgroundColor = self.borderAnimateColor;
            return;
        }
        
        if (self.borderAnimateColor) {
            self.layer.borderColor = self.borderAnimateColor.CGColor;
        }
        
        if (self.foregroundAnimateColor) {
            self.foregroundView.backgroundColor = self.foregroundAnimateColor;
        }
    };
    
}

- (OSButtonAnimateBlock)fadeOutBlock {
    return ^ {
        self.titleContentView.backgroundColor = self.contentColor;
        self.detailContentView.backgroundColor = self.contentColor;
        self.imageContentView.backgroundColor = self.contentColor;
        
        if (self.borderAnimateColor && self.foregroundAnimateColor && self.borderAnimateColor == self.foregroundAnimateColor) {
            self.foregroundView.backgroundColor = self.foregroundColor;
            self.backgroundColor = _backgroundColorCache;
            _backgroundColorCache = nil;
        }
        
        self.foregroundView.backgroundColor = self.foregroundColor;
        self.layer.borderColor = self.borderColor.CGColor;
    };
}


@end

static NSString * const PreviousCenterXKey = @"previousCenterX";
static NSString * const PreviousCenterYKey = @"previousCenterY";

@interface SuspensionView ()

@property (nonatomic, assign) CGPoint previousCenter;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) BOOL isMoving;

@end

@implementation SuspensionView

@synthesize previousCenter = _previousCenter;

////////////////////////////////////////////////////////////////////////
#pragma mark - initialize
////////////////////////////////////////////////////////////////////////


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _suspensionViewSetup];
        [self addActions];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _suspensionViewSetup];
        [self addActions];
    }
    return self;
}

- (void)_suspensionViewSetup {
    
    self.autoLeanEdge = YES;
    self.leanEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
    self.invalidHidden = NO;
    self.isMoving = NO;
    self.usingSpringWithDamping = 0.8;
    self.initialSpringVelocity = 3.0;
    self.shouldLeanToPreviousPositionWhenAppStart = YES;
    CGFloat centerX = [[NSUserDefaults standardUserDefaults] doubleForKey:PreviousCenterXKey];
    CGFloat centerY = [[NSUserDefaults standardUserDefaults] doubleForKey:PreviousCenterYKey];
    if (centerX > 0 || centerY > 0) {
        self.previousCenter = CGPointMake(centerX, centerY);
    } else {
        self.previousCenter = self.center;
    }
    
}


- (void)addActions {
    
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(_locationChange:)];
    pan.delaysTouchesBegan = YES;
    [self addGestureRecognizer:pan];
    _panGestureRecognizer = pan;
    
    [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////


- (void)leanFinishCallBack:(void (^)(CGPoint centerPoint))callback {
    self.leanFinishCallBack = callback;
}

- (void)setHidden:(BOOL)hidden {
    if (self.invalidHidden) {
        return;
    }
    [super setHidden:hidden];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    self.clickCallBack = nil;
    self.leanFinishCallBack = nil;
    self.delegate = nil;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Position
////////////////////////////////////////////////////////////////////////

- (void)_locationChange:(UIPanGestureRecognizer *)p {
    
    CGPoint panPoint = [p locationInView:[UIApplication sharedApplication].delegate.window];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        
    }else if(p.state == UIGestureRecognizerStateChanged) {
        [self movingWithPoint:panPoint];
        
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        
        if (!self.isAutoLeanEdge) {
            return;
        }
        CGPoint newTargetPoint = [self _checkTargetPosition:panPoint];
        [self autoLeanToTargetPosition:newTargetPoint];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionView:locationChange:)]) {
        [self.delegate suspensionView:self locationChange:p];
        return;
    }
    
    if (self.locationChange) {
        self.locationChange(panPoint);
    }
}


/// 手指移动时，移动视图
- (void)movingWithPoint:(CGPoint)point {
    [SuspensionControl windowForKey:self.key].center = CGPointMake(point.x, point.y);
    UIWindow *w = [SuspensionControl windowForKey:self.key];
    if (w) {
        w.center = CGPointMake(point.x, point.y);
    } else {
        self.center = CGPointMake(point.x, point.y);
    }
    _isMoving = YES;
}

- (void)checkTargetPosition {
    
    if (self.shouldLeanToPreviousPositionWhenAppStart) {
        CGPoint newTargetPoint = [self _checkTargetPosition:self.previousCenter];
        [self autoLeanToTargetPosition:newTargetPoint];
    } else {
        CGPoint currentPoint = [self convertPoint:self.center toView:[UIApplication sharedApplication].delegate.window];
        CGPoint newTargetPoint = [self _checkTargetPosition:currentPoint];
        [self autoLeanToTargetPosition:newTargetPoint];
    }
    
}

/// 根据传入的位置检查处理最终依靠到边缘的位置
- (CGPoint)_checkTargetPosition:(CGPoint)panPoint {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(leanToNewTragetPosionForSuspensionView:)]) {
        self.previousCenter = [self.delegate leanToNewTragetPosionForSuspensionView:self];
        return self.previousCenter;
    }
    
    CGFloat touchWidth = self.frame.size.width;
    CGFloat touchHeight = self.frame.size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat left = fabs(panPoint.x);
    CGFloat right = fabs(screenWidth - left);
    CGFloat top = fabs(panPoint.y);
    CGFloat bottom = fabs(screenHeight - top);
    
    CGFloat minSpace = 0;
    if (self.leanEdgeType == SuspensionViewLeanEdgeTypeHorizontal) {
        minSpace = MIN(left, right);
    }else if (self.leanEdgeType == SuspensionViewLeanEdgeTypeEachSide) {
        minSpace = MIN(MIN(MIN(top, left), bottom), right);
    }
    CGPoint newTargetPoint = CGPointZero;
    CGFloat targetY = 0;
    
    if (panPoint.y < self.leanEdgeInsets.top + touchHeight / 2.0 + self.leanEdgeInsets.top) {
        targetY = self.leanEdgeInsets.top + touchHeight / 2.0 + self.leanEdgeInsets.top;
    }else if (panPoint.y > (screenHeight - touchHeight / 2.0 - self.leanEdgeInsets.bottom)) {
        targetY = screenHeight - touchHeight / 2.0 - self.leanEdgeInsets.bottom;
    }else{
        targetY = panPoint.y;
    }
    
    if (minSpace == left) {
        newTargetPoint = CGPointMake(touchWidth / 2 + self.leanEdgeInsets.left, targetY);
    }
    if (minSpace == right) {
        newTargetPoint = CGPointMake(screenWidth - touchWidth / 2 - self.leanEdgeInsets.right, targetY);
    }
    if (minSpace == top) {
        newTargetPoint = CGPointMake(panPoint.x, touchHeight / 2 + self.leanEdgeInsets.top);
    }
    if (minSpace == bottom) {
        newTargetPoint = CGPointMake(panPoint.x, screenHeight - touchHeight / 2 - self.leanEdgeInsets.bottom);
    }
    // 记录当前的center
    self.previousCenter = newTargetPoint;
    
    return newTargetPoint;
}


- (void)moveToPreviousLeanPosition {
    
    [self autoLeanToTargetPosition:self.previousCenter];
}

/// 移动移动到屏幕中心位置
- (void)moveToScreentCenter {
    
    //    CGPoint screenCenter = CGPointMake((kSCREENT_WIDTH - [SuspensionControl windowForKey:self.key].bounds.size.width)*0.5, (kSCREENT_HEIGHT - [SuspensionControl windowForKey:self.key].bounds.size.height)*0.5);
    
    [self autoLeanToTargetPosition:[UIApplication sharedApplication].delegate.window.center];
}

/// 自动移动到边缘，此方法在手指松开后会自动移动到目标位置
- (void)autoLeanToTargetPosition:(CGPoint)point {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionView:willAutoLeanToTargetPosition:)]) {
        [self.delegate suspensionView:self willAutoLeanToTargetPosition:point];
    }
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:self.usingSpringWithDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
        UIWindow *w = [SuspensionControl windowForKey:self.key];
        if (w) {
            w.center = point;
        } else {
            self.center = point;
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            
            [self autoLeanToTargetPositionCompletion:point];
            _isMoving = NO;
        }
    }];
}

- (void)autoLeanToTargetPositionCompletion:(CGPoint)currentPosition {
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionView:didAutoLeanToTargetPosition:)]) {
        [self.delegate suspensionView:self didAutoLeanToTargetPosition:currentPosition];
        return;
    }
    if (self.leanFinishCallBack) {
        self.leanFinishCallBack(currentPosition);
    }
}

- (void)orientationDidChange:(NSNotification *)note {
    if (self.isAutoLeanEdge) {
        /// 屏幕旋转时检测下最终依靠的位置，防止出现屏幕旋转记录的previousCenter未更新坐标时，导致按钮不见了
        CGPoint currentPoint = [self convertPoint:self.center toView:[UIApplication sharedApplication].delegate.window];
        
        [self performSelector:@selector(_checkTargetPosition:) withObject:[NSValue valueWithCGPoint:currentPoint] afterDelay:0.0];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)btnClick:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionViewClickedButton:)]) {
        [self.delegate suspensionViewClickedButton:self];
        return;
    }
    
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - setter  getter
////////////////////////////////////////////////////////////////////////

- (SuspensionViewLeanEdgeType)leanEdgeType {
    return _leanEdgeType ?: SuspensionViewLeanEdgeTypeEachSide;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

- (NSString *)key {
    return _isOnce ? [[SuspensionControl shareInstance] keyWithIdentifier:NSStringFromClass([self class])] : [super key];
}

- (void)setPreviousCenter:(CGPoint)previousCenter {
    _previousCenter = previousCenter;
    [[NSUserDefaults standardUserDefaults] setDouble:previousCenter.x forKey:PreviousCenterXKey];
    [[NSUserDefaults standardUserDefaults] setDouble:previousCenter.y forKey:PreviousCenterYKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@interface UIResponder ()

@property (nonatomic) SuspensionView *suspensionView;

@end

@implementation UIResponder (SuspensionView)

- (SuspensionView *)showSuspensionViewWithFrame:(CGRect)frame {
    BOOL result = [self isKindOfClass:[UIViewController class]] || [self isKindOfClass:[UIView class]];
    if (!result) {
        NSAssert(result, @"当前类应为UIViewController或UIView或他们的子类");
        return nil;
    }
    if (!self.suspensionView && !self.suspensionView.superview) {
        SuspensionView *sv = [[SuspensionView alloc] initWithFrame:frame];
        sv.clipsToBounds = YES;
        if ([self isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)self;
            [vc.view addSubview:sv];
        }
        if ([self isKindOfClass:[UIView class]]) {
            UIView *v = (UIView *)self;
            [v addSubview:sv];
        }
        self.suspensionView = sv;
    }
    if ([self isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)self;
        [vc.view bringSubviewToFront:self.suspensionView];
    } else if ([self isKindOfClass:[UIView class]]) {
        UIView *v = (UIView *)self;
        [v bringSubviewToFront:self.suspensionView];
    }
    
    return self.suspensionView;
}


- (void)dismissSuspensionView:(void (^)())block {
    
    [self.suspensionView removeFromSuperview];
    self.suspensionView = nil;
    if (block) {
        block();
    }
}

- (void)setHiddenSuspension:(BOOL)flag {
    self.suspensionView.hidden = flag;
}
- (BOOL)isHiddenSuspension {
    return self.suspensionView.isHidden;
}
- (void)setSuspensionTitle:(NSString *)title forState:(UIControlState)state {
    [self.suspensionView setTitle:title forState:UIControlStateNormal];
}
- (void)setSuspensionImage:(UIImage *)image forState:(UIControlState)state {
    [self.suspensionView setImage:image forState:UIControlStateNormal];
}
- (void)setSuspensionImageWithImageNamed:(NSString *)name forState:(UIControlState)state {
    [self setSuspensionImage:[UIImage imageNamed:name] forState:state];
}

- (void)setSuspensionBackgroundColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    [self.suspensionView setBackgroundColor:color];
    if (cornerRadius) {
        self.suspensionView.layer.cornerRadius = cornerRadius;
        self.suspensionView.layer.masksToBounds = YES;
    }
}

- (SuspensionView *)suspensionView {
    return objc_getAssociatedObject(self, @selector(suspensionView));
}

- (void)setSuspensionView:(SuspensionView *)suspensionView {
    objc_setAssociatedObject(self, @selector(suspensionView), suspensionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface SuspensionMenuController : UIViewController

- (instancetype)initWithMenuView:(SuspensionMenuView *)menuView ;

@property (nonatomic, weak) SuspensionMenuWindow *menuView;

@end

@implementation SuspensionWindow

////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods
////////////////////////////////////////////////////////////////////////


+ (instancetype)showOnce:(BOOL)isOnce frame:(CGRect)frame {
    
    SuspensionWindow *s = [[self alloc] initWithFrame:frame];
    s.leanEdgeType = SuspensionViewLeanEdgeTypeEachSide;
    s.isOnce = isOnce;
    [s _moveToSuperview];
    
    return s;
}

- (void)removeFromSuperview {
    self.clickCallBack = nil;
    self.leanFinishCallBack = nil;
    [SuspensionControl removeWindowForKey:self.key];
    [super removeFromSuperview];
}

+ (void)releaseAll {
    
    NSDictionary *temp = [[SuspensionControl windows] mutableCopy];
    [temp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIWindow * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.suspensionView && !obj.suspensionMenuView) {
            [SuspensionControl removeWindow:obj];
        }
    }];
    temp = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods
////////////////////////////////////////////////////////////////////////


- (void)_moveToSuperview {
    
    UIWindow *suspensionWindow = [[UIWindow alloc] initWithFrame:self.frame];
    
#ifdef DEBUG
    suspensionWindow.windowLevel = CGFLOAT_MAX+10;
#else
    suspensionWindow.windowLevel = UIWindowLevelAlert * 3;
#endif
    //    [suspensionWindow makeKeyAndVisible];
    // 给window设置rootViewController是为了当屏幕旋转时，winwow跟随旋转并更新坐标
    UIViewController *vc = [UIViewController new];
    suspensionWindow.rootViewController = vc;
    // 不设置此属性，window在选择时，会出现四周黑屏现象
    [suspensionWindow.layer setMasksToBounds:YES];
    
    [SuspensionControl setWindow:suspensionWindow forKey:self.key];
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.clipsToBounds = YES;
    
    [vc.view addSubview:self];
    
    suspensionWindow.suspensionView = self;
    
    suspensionWindow.hidden = NO;
}

@end

static const CGFloat menuBarBaseTag = 100;

@interface SuspensionMenuView () <SuspensionViewDelegate> {
@protected
    CGFloat _defaultTriangleHypotenuse;     // 默认关闭时的三角斜边
    CGFloat _minBounceOfTriangleHypotenuse; // 当第一次显示完成后的三角斜边
    CGFloat _maxBounceOfTriangleHypotenuse; // 当显示时要展开的三角斜边
    CGFloat _maxTriangleHypotenuse;         // 最大三角斜边，当第一次刚出现时三角斜边
    CGRect _memuBarButtonOriginFrame;       // 每一个菜单上按钮的原始frame 除中心的按钮 关闭时也可使用,重叠
    
    BOOL _isInProcessing;    // 是否正在执行显示或消失
    BOOL _isShow;            // 是否已经显示
    BOOL _isDismiss;         // 是否已经消失
    BOOL _isFiristShow;      // 是否第一次显示
    BOOL _isFiristDismiss;   // 是否第一次消失
    CGSize _itemSize;
    CGSize _menuWindowSize;
    CGSize _centerWindowSize;
}

@property (nonatomic, weak) SuspensionView *centerButton;
@property (nonatomic, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) UIVisualEffectView *visualEffectView;
@property (nonatomic, assign) CGSize itemSize;

@end

@implementation SuspensionMenuView

@synthesize centerButton = _centerButton;

////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods
////////////////////////////////////////////////////////////////////////


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _suspensionMenuViewSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _suspensionMenuViewSetup];
    }
    return self;
}

- (void)setMenuBarItems:(NSArray<MenuBarHypotenuseItem *> *)menuBarItems itemSize:(CGSize)itemSize {
    self.menuBarItems = menuBarItems;
    [self setItemSize:itemSize];
}

- (void)setItemSize:(CGSize)itemSize {
    CGSize menuSize = self.frame.size;
    if (self.frame.size.width == 0 || self.frame.size.height == 0) {
        menuSize = CGSizeMake(280.0, 280.0);
    }
    if (itemSize.width == 0 || itemSize.height == 0) {
        itemSize = CGSizeMake(64.0, 64.0);
    }
    _menuWindowSize = menuSize;
    _itemSize = itemSize;
    _centerWindowSize = itemSize;
    
    [self setupLayout];
}


- (void)setMenuBarItems:(NSArray<MenuBarHypotenuseItem *> *)menuBarItems {
    
    _menuBarItems = menuBarItems;
    
    NSInteger idx = 0;
    for (MenuBarHypotenuseItem *item in menuBarItems) {
        [item.hypotenuseButton setOpaque:NO];
        [item.hypotenuseButton setTag:menuBarBaseTag+idx+1];
        [item.hypotenuseButton addTarget:self action:@selector(menuBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [item.hypotenuseButton setAlpha:0.0];
        [self addSubview:item.hypotenuseButton];
        [item.hypotenuseButton setFrame:_memuBarButtonOriginFrame];
        idx++;
    }
}

//// Push View Controller
- (void)pushViewController:(UIViewController *)viewController {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         // 在中心视图中滑动按钮并隐藏
                         [self updateMenuBarButtonLayoutWithTriangleHypotenuse:_maxTriangleHypotenuse];
                         [self setAlpha:0.0];
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"MenuBarHypotenuseButton")]) {
                                 [btn setAlpha:0.0];
                             }
                         }
                         [self.centerButton moveToPreviousLeanPosition];
                         
                     } completion:^(BOOL finished) {
                         [[self topViewController].navigationController pushViewController:viewController animated:YES];
                         UIWindow *menuWindow = [SuspensionControl windowForKey:self.key];
                         CGRect menuFrame =  menuWindow.frame;
                         menuFrame.size = CGSizeZero;
                         menuWindow.frame = menuFrame;
                         _isDismiss = YES;
                         _isShow = NO;
                     }];
}


- (void)show {
    if (_isShow) return;
    
    if (_isFiristShow) {
        [self updateMenuBarButtonLayoutWithTriangleHypotenuse:_maxTriangleHypotenuse];
    }
    
    if (_shouldLeanToScreenCenterWhenShow) {
        [self.centerButton moveToScreentCenter];
    }
    
    UIWindow *menuWindow = [SuspensionControl windowForKey:self.key];
    
    [self centerButton];
    [self _updateMenuViewCenterWithIsShow:YES];
    
    _isInProcessing = YES;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         [menuWindow setAlpha:1.0];
                         [self setAlpha:1.0];
                         
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"MenuBarHypotenuseButton")]) {
                                 [btn setAlpha:1.0];
                             }
                         }
                         
                         // 更新menu bar 的 布局
                         CGFloat triangleHypotenuse = 0.0;
                         if (_isFiristShow) {
                             triangleHypotenuse = _minBounceOfTriangleHypotenuse;
                         } else {
                             triangleHypotenuse = _maxBounceOfTriangleHypotenuse;
                         }
                         [self updateMenuBarButtonLayoutWithTriangleHypotenuse:triangleHypotenuse];
                     }
                     completion:^(BOOL finished) {
                         // 此处动画结束时,menuWindow的bounds为CGRectZero了,原因是动画时间相错
                         //                         NSLog(@"%@", NSStringFromCGRect(menuWindow.frame));
                         //                         if (menuWindow.frame.size.width == 0 || menuWindow.frame.size.height == 0) {
                         //                             NSLog(@"为0了");
                         //                             [self _updateMenuViewCenterWithIsShow:YES];
                         //                         }
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              [self updateMenuBarButtonLayoutWithTriangleHypotenuse:_defaultTriangleHypotenuse];
                                          }
                                          completion:^(BOOL finished) {
                                              _isShow = YES;
                                              _isDismiss = NO;
                                              _isInProcessing = NO;
                                              _isFiristShow = NO;
                                              [self _showCompetion];
                                              
                                          }];
                     }];
}

- (void)dismiss {
    [self _dismissWithTriggerPanGesture:NO];
}

- (void)_showCompetion {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionMenuViewDidShow:)]) {
        [self.delegate suspensionMenuViewDidShow:self];
        return;
    }
    
    if (self.showCompletion) {
        self.showCompletion();
    }
}

/// 执行dismiss，并根据当前是否触发了拖动手势，确定是否在让SuapensionWindow执行移动边缘的操作，防止移除时乱窜
- (void)_dismissWithTriggerPanGesture:(BOOL)isTriggerPanGesture {
    
    if (_isDismiss)
        return;
    
    //    if (_isFiristDismiss) {
    //        // 检测边缘
    //        [self.centerButton checkTargetPosition];
    //    }
    //
    _isInProcessing = YES;
    
    // 隐藏menu bar button
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         for (UIButton * button in [self subviews])
                             [button setFrame:_memuBarButtonOriginFrame];
                         [self setAlpha:0.0];
                         for (UIButton *btn in self.subviews) {
                             if ([btn isKindOfClass:NSClassFromString(@"MenuBarHypotenuseButton")]) {
                                 [btn setAlpha:0.0];
                             }
                         }
                         
                         if (!isTriggerPanGesture) {
                             [self.centerButton moveToPreviousLeanPosition];
                         }
                         
                     } completion:^(BOOL finished) {
                         UIWindow *menuWindow = [SuspensionControl windowForKey:self.key];
                         
                         [UIView animateWithDuration:0.1 animations:^{
                             [menuWindow setAlpha:0.0];
                             // 让其frame为zero，为了防止其隐藏后所在的位置无法响应事件
                         } completion:^(BOOL finished) {
                             CGRect menuFrame =  menuWindow.frame;
                             menuFrame.size = CGSizeZero;
                             menuWindow.frame = menuFrame;
                             _isDismiss = YES;
                             _isShow  = NO;
                             _isInProcessing = NO;
                             _isFiristDismiss = NO;
                             [self _dismissCompetion];
                         } ];
                         
                     }];
}

- (void)_dismissCompetion {
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionMenuViewDidDismiss:)]) {
        [self.delegate suspensionMenuViewDidDismiss:self];
        return;
    }
    if (self.dismissCompletion) {
        self.dismissCompletion();
    }
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy
////////////////////////////////////////////////////////////////////////


- (SuspensionView *)centerButton {
    if (_centerButton == nil) {
        // 创建中心按钮
        CGRect centerButtonFrame = CGRectMake((CGRectGetWidth(self.frame) - _centerWindowSize.width) * 0.5, (CGRectGetHeight(self.frame) - _centerWindowSize.height) * 0.5, _centerWindowSize.width, _centerWindowSize.height);
        
        CGRect centerRec = [self convertRect:centerButtonFrame toView:[UIApplication sharedApplication].delegate.window];
        
        SuspensionView *centerButton = (SuspensionWindow *)[NSClassFromString(@"_MenuBarCenterButton") showOnce:YES frame:centerRec];
        centerButton.autoLeanEdge = YES;
        centerButton.delegate = self;
        
        _centerButton = centerButton;
        
    }
    return _centerButton;
}



- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        UIImageView *imageView = [NSClassFromString(@"_MenuViewBackgroundImageView") new];
        _backgroundImageView = imageView;
        imageView.userInteractionEnabled = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        [self insertSubview:imageView atIndex:0];
        imageView.frame = self.bounds;
        [self visualEffectView];
    }
    return _backgroundImageView;
}

- (UIVisualEffectView *)visualEffectView {
    if (_visualEffectView == nil) {
        UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct];
        visualEffectView.frame = self.bounds;
        visualEffectView.alpha = 1.0;
        [self addSubview:visualEffectView];
        _visualEffectView = visualEffectView;
    }
    if (_backgroundImageView) {
        [self insertSubview:_visualEffectView aboveSubview:_backgroundImageView];
    } else {
        [self insertSubview:_visualEffectView atIndex:0];
    }
    return _visualEffectView;
}

- (void)_suspensionMenuViewSetup {
    
    _isInProcessing = NO;
    _isShow  = NO;
    _isDismiss = YES;
    _isFiristShow = YES;
    _isFiristDismiss = YES;
    _shouldLeanToScreenCenterWhenShow = YES;
    
    self.autoresizingMask = UIViewAutoresizingNone;
    self.layer.cornerRadius = 12.8;
    [self.layer setMasksToBounds:YES];
    [self setClipsToBounds:YES];
    [self visualEffectView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
}

- (void)setupLayout {
    
    // 设置三角斜边
    _defaultTriangleHypotenuse = (_menuWindowSize.width - _itemSize.width) * 0.5;
    _minBounceOfTriangleHypotenuse = _defaultTriangleHypotenuse - 12.0;
    _maxBounceOfTriangleHypotenuse = _defaultTriangleHypotenuse + 12.0;
    _maxTriangleHypotenuse = kSCREENT_HEIGHT * 0.5;
    
    // 计算menu 上 按钮的 原始 frame 当dismiss 时 回到原始位置
    CGFloat originX = (_menuWindowSize.width - _centerWindowSize.width) * 0.5;
    _memuBarButtonOriginFrame = CGRectMake(originX,
                                           originX,
                                           _centerWindowSize.width,
                                           _centerWindowSize.height);
    [self setNeedsLayout];
}



////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////


// 中心 button 点击事件
- (void)centerBarButtonClick:(id)senter {
    _isDismiss ? [self show] : [self dismiss];
}

// 斜边的 button 点击事件 button tag 如下图:
//
// TAG:        1       1   2      1   2     1   2     1 2 3     1 2 3
//            \|/       \|/        \|/       \|/       \|/       \|/
// COUNT: 1) --|--  2) --|--   3) --|--  4) --|--  5) --|--  6) --|--
//            /|\       /|\        /|\       /|\       /|\       /|\
// TAG:                             3       3   4     4   5     4 5 6
//
- (void)menuBarButtonClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionMenuView:clickedHypotenuseButtonAtIndex:)]) {
        [self.delegate suspensionMenuView:self clickedHypotenuseButtonAtIndex:[(UIButton *)sender tag] - menuBarBaseTag - 1];
        return;
    }
    if (_menuBarClickBlock) {
        _menuBarClickBlock([(UIButton *)sender tag] - menuBarBaseTag - 1);
    }
}

- (void)orientationDidChange:(NSNotification *)note {
    
    [self _updateMenuViewCenterWithIsShow:_isShow];
}
////////////////////////////////////////////////////////////////////////
#pragma mark - SuspensionViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)suspensionViewClickedButton:(SuspensionView *)suspensionView {
    [self centerBarButtonClick:suspensionView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionMenuView:clickedCenterButton:)]) {
        [self.delegate suspensionMenuView:self clickedCenterButton:suspensionView];
    }
}

- (void)suspensionView:(SuspensionView *)suspensionView locationChange:(UIPanGestureRecognizer *)pan {
    CGPoint panPoint = [pan locationInView:[UIApplication sharedApplication].delegate.window];
    self.center = panPoint;
    if (pan.state == UIGestureRecognizerStateEnded ||
        pan.state == UIGestureRecognizerStateCancelled) {
        [suspensionView moveToPreviousLeanPosition];
    }
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self _dismissWithTriggerPanGesture:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(suspensionMenuView:centerButtonLocationChange:)]) {
        [self.delegate suspensionMenuView:self centerButtonLocationChange:pan];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods
////////////////////////////////////////////////////////////////////////


- (void)_updateMenuViewCenterWithIsShow:(BOOL)isShow {
    if (isShow) {
        UIWindow *menuWindow = [SuspensionControl windowForKey:self.key];
        menuWindow.frame = [UIScreen mainScreen].bounds;
        NSLog(@"%@", NSStringFromCGRect(menuWindow.frame));
        menuWindow.rootViewController.view.frame =  menuWindow.bounds;
        UIWindow *centerWindow = [SuspensionControl windowForKey:self.centerButton.key];
        CGRect centerFrame =  centerWindow.frame;
        centerFrame.size = CGSizeMake(_centerWindowSize.width, _centerWindowSize.height);
        centerWindow.frame = centerFrame;
        
        CGPoint newCenter = [centerWindow convertPoint:self.centerButton.center toView:[UIApplication sharedApplication].delegate.window];
        self.center = newCenter;
        
        if (_backgroundImageView) {
            self.backgroundImageView.frame = self.bounds;
            if (_visualEffectView) {
                [self insertSubview:_visualEffectView aboveSubview:_backgroundImageView];
            }
        }
        if (_visualEffectView) {
            self.visualEffectView.frame = self.bounds;
            if (!_backgroundImageView) {
                [self insertSubview:_visualEffectView atIndex:0];
            }
        }
    }
}

/// 设置按钮的 位置
- (void)_setButtonWithTag:(NSInteger)buttonTag origin:(CGPoint)origin {
    
    if (buttonTag < menuBarBaseTag) {
        buttonTag = menuBarBaseTag + buttonTag;
    }
    
    UIButton * button = (UIButton *)[self viewWithTag:buttonTag];
    if (button) {
        [button setFrame:CGRectMake(origin.x,
                                    origin.y,
                                    self.centerButton.frame.size.width,
                                    self.centerButton.frame.size.height)];
        button = nil;
    }
}


- (void)updateMenuBarButtonLayoutWithTriangleHypotenuse:(CGFloat)triangleHypotenuse {
    //
    //  Triangle Values for Buttons' Position
    //
    //      /|      a: triangleA = c * cos(x)
    //   c / | b    b: triangleB = c * sin(x)
    //    /)x|      c: triangleHypotenuse  三角斜边
    //   -----      x: degree    度数
    //     a
    //
    // menuView的半径
    CGFloat menuWindowRadius = _menuWindowSize.width * 0.5;
    // centerButton的半径
    CGFloat centerWindowRadius = _centerWindowSize.width * 0.5;
    if (! triangleHypotenuse) {
        // 距离中心
        triangleHypotenuse = _defaultTriangleHypotenuse;
    }
    //
    //      o       o   o      o   o     o   o     o o o     o o o
    //     \|/       \|/        \|/       \|/       \|/       \|/
    //  1 --|--   2 --|--    3 --|--   4 --|--   5 --|--   6 --|--
    //     /|\       /|\        /|\       /|\       /|\       /|\
    //                           o       o   o     o   o     o o o
    //
    if (_menuBarItems.count == 1) {
        
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius - triangleHypotenuse - centerWindowRadius)];
    }
    
    if (_menuBarItems.count == 2) {
        
        CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180 角度
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        CGFloat negativeValue = menuWindowRadius - triangleB - centerWindowRadius;
        CGFloat positiveValue = menuWindowRadius + triangleB - centerWindowRadius;
        [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
        [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
        
    }
    
    if (_menuBarItems.count == 3) {
        // = 360.0f / self.buttonCount * M_PI / 180.0f;
        // E.g: if |buttonCount_ = 6|, then |degree = 60.0f * M_PI / 180.0f|;
        // CGFloat degree = 2 * M_PI / self.buttonCount;
        //
        CGFloat degree    = M_PI / 3.0f; // = 60 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree);
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius + triangleHypotenuse - centerWindowRadius)];
    }
    if (_menuBarItems.count == 4) {
        CGFloat degree    = M_PI / 4.0f; // = 45 * M_PI / 180
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        CGFloat negativeValue = menuWindowRadius - triangleB - centerWindowRadius;
        CGFloat positiveValue = menuWindowRadius + triangleB - centerWindowRadius;
        [self _setButtonWithTag:1 origin:CGPointMake(negativeValue, negativeValue)];
        [self _setButtonWithTag:2 origin:CGPointMake(positiveValue, negativeValue)];
        [self _setButtonWithTag:3 origin:CGPointMake(negativeValue, positiveValue)];
        [self _setButtonWithTag:4 origin:CGPointMake(positiveValue, positiveValue)];
    }
    
    if (_menuBarItems.count == 5) {
        CGFloat degree      = 2 * M_PI / _menuBarItems.count ; //= M_PI / 3.0;// = M_PI / 20.5; // = 72 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree);
        CGFloat triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius - triangleHypotenuse - centerWindowRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        
        degree    = M_PI / 5.0f;  // = 36 * M_PI / 180
        triangleA = triangleHypotenuse * cosf(degree);
        triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:4 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
        [self _setButtonWithTag:5 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
    }
    
    if (_menuBarItems.count == 6) {
        CGFloat degree    = M_PI / 3.0f; // = 60 * M_PI / 180
        CGFloat triangleA = triangleHypotenuse * cosf(degree); // 斜边的余弦值
        CGFloat triangleB = triangleHypotenuse * sinf(degree); // 斜边正弦值
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius - triangleHypotenuse - centerWindowRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:4 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
        [self _setButtonWithTag:5 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius + triangleHypotenuse - centerWindowRadius)];
        [self _setButtonWithTag:6 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
    }
    
    if (_menuBarItems.count == 8) {
        CGFloat degree      = 2 * M_PI / (_menuBarItems.count * 1.0f);   // 计算度数
        CGFloat triangleA = triangleHypotenuse * cosf(degree);         // 斜边的余弦值
        CGFloat triangleB = triangleHypotenuse * sinf(degree);         // 斜边正弦值
        [self _setButtonWithTag:1 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:2 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius - triangleHypotenuse - centerWindowRadius)];
        [self _setButtonWithTag:3 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius - triangleA - centerWindowRadius)];
        [self _setButtonWithTag:4 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
        [self _setButtonWithTag:5 origin:CGPointMake(menuWindowRadius - centerWindowRadius,
                                                     menuWindowRadius + triangleHypotenuse - centerWindowRadius)];
        [self _setButtonWithTag:6 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
        
        degree    = M_PI / 2.0f;  // = 36 * M_PI / 180
        triangleA = triangleHypotenuse * cosf(degree);
        triangleB = triangleHypotenuse * sinf(degree);
        [self _setButtonWithTag:7 origin:CGPointMake(menuWindowRadius + triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
        [self _setButtonWithTag:8 origin:CGPointMake(menuWindowRadius - triangleB - centerWindowRadius,
                                                     menuWindowRadius + triangleA - centerWindowRadius)];
    }

    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Other
////////////////////////////////////////////////////////////////////////


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_menuBarItems.count) {
        [_menuBarItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _menuBarItems = nil;
    }
    _showCompletion = nil;
    _dismissCompletion = nil;
}

- (UIViewController *)topViewController {
    
    UINavigationController * navigationController = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if ([navigationController isKindOfClass:[UINavigationController class]]) {
        UIViewController * currentViewController = [navigationController topViewController];
        return currentViewController;
    }
    return nil;
}


- (NSString *)key {
    return _isOnce ? [[SuspensionControl shareInstance] keyWithIdentifier:NSStringFromClass([self class])] : [super key];
}

@end


@implementation SuspensionMenuWindow

////////////////////////////////////////////////////////////////////////
#pragma mark - initialize
////////////////////////////////////////////////////////////////////////


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setAlpha:1.0];
        self.isOnce = YES;
        self.shouldShowWhenViewWillAppear = YES;
    }
    return self;
}

- (void)setItemSize:(CGSize)itemSize {
    [super setItemSize:itemSize];
    [self _moveToSuperview];
    
    if (!self.shouldShowWhenViewWillAppear) {
        [self.centerButton checkTargetPosition];
    }
}


- (void)removeFromSuperview {
    self.menuBarClickBlock = nil;
    [SuspensionControl removeWindowForKey:self.key];
    [super removeFromSuperview];
}

+ (void)releaseAll {
    
    NSDictionary *temp = [[SuspensionControl windows] mutableCopy];
    [temp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIWindow * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.suspensionMenuView && obj.suspensionView) {
            [SuspensionControl removeWindow:obj];
            [SuspensionControl removeWindowForKey:obj.suspensionView.key];
        }
    }];
    temp = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods
////////////////////////////////////////////////////////////////////////


- (void)_moveToSuperview {
    
    CGRect menuWindowBounds = [UIScreen mainScreen].bounds;
    if (!_shouldShowWhenViewWillAppear) {
        menuWindowBounds = CGRectZero;
    }
    
    UIWindow *suspensionWindow = [[UIWindow alloc] initWithFrame:menuWindowBounds];
#ifdef DEBUG
    suspensionWindow.windowLevel = CGFLOAT_MAX;
    //    suspensionWindow.windowLevel = CGFLOAT_MAX+10;
    // iOS9前自定义的window设置下面，不会被键盘遮罩，iOS10不行了
    //    NSArray<UIWindow *> *widnows = [UIApplication sharedApplication].windows;
#else
    suspensionWindow.windowLevel = UIWindowLevelAlert * 2;
#endif
    
    // 给window设置rootViewController是为了当屏幕旋转时，winwow跟随旋转并更新坐标
    
    UIViewController *vc = [[SuspensionMenuController alloc] initWithMenuView:self];
    
    suspensionWindow.rootViewController = vc;
    // 不设置此属性，window在选择时，会出现四周黑屏现象
    [suspensionWindow.layer setMasksToBounds:YES];
    
    [SuspensionControl setWindow:suspensionWindow forKey:self.key];
    self.frame = CGRectMake((kSCREENT_WIDTH - self.frame.size.width) * 0.5, (kSCREENT_HEIGHT - self.frame.size.height) * 0.5, self.frame.size.width, self.frame.size.height);
    self.clipsToBounds = YES;
    
    [vc.view addSubview:self];
    
    suspensionWindow.suspensionMenuView = self;
    
    suspensionWindow.hidden = NO;
    
}

@end

@interface MenuBarHypotenuseButton : OSCustomButton

@end

@interface MenuBarHypotenuseItem ()
@property (nonatomic, strong) MenuBarHypotenuseButton *hypotenuseButton;
@end
@implementation MenuBarHypotenuseItem
- (instancetype)initWithButtonType:(OSButtonType)buttonType {
    if (self = [super init]) {
        self.hypotenuseButton = [MenuBarHypotenuseButton buttonWithType:buttonType];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hypotenuseButton = [MenuBarHypotenuseButton buttonWithType:OSButtonType3];
        
    }
    return self;
}

- (void)removeFromSuperview {
    [self.hypotenuseButton removeFromSuperview];
    self.hypotenuseButton = nil;
}

- (void)dealloc {
    [self removeFromSuperview];
}

@end

@implementation MenuBarHypotenuseButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _setup];
    }
    return self;
}
- (void)_setup {
    //    [self.titleLabel setFont:[UIFont systemFontOfSize:12 weight:1.0]];
    //    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}
@end

@interface _MenuBarCenterButton : SuspensionWindow
@end
@implementation _MenuBarCenterButton
@end

@interface _MenuViewBackgroundImageView : UIImageView
@end
@implementation _MenuViewBackgroundImageView
@end

@implementation UIWindow (SuspensionWindow)

- (void)setSuspensionView:(SuspensionView *)suspensionView {
    objc_setAssociatedObject(self, @selector(suspensionView), suspensionView, OBJC_ASSOCIATION_ASSIGN);
}

- (SuspensionView *)suspensionView {
    return objc_getAssociatedObject(self, @selector(suspensionView));
}

- (void)setSuspensionMenuView:(SuspensionMenuView * _Nullable)suspensionMenuView {
    objc_setAssociatedObject(self, @selector(suspensionMenuView), suspensionMenuView, OBJC_ASSOCIATION_ASSIGN);
}

- (SuspensionMenuView *)suspensionMenuView {
    return objc_getAssociatedObject(self, @selector(suspensionMenuView));
}
@end


@implementation SuspensionMenuController

- (instancetype)initWithMenuView:(SuspensionMenuWindow *)menuView {
    if (self = [super init]) {
        _menuView = menuView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_menuView.shouldShowWhenViewWillAppear) {
        [self.menuView performSelector:@selector(show)
                            withObject:nil
                            afterDelay:0.3];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.menuView dismiss];
    [self.nextResponder touchesEnded:touches withEvent:event];
}


@end

@interface SuspensionControl ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIWindow *> *windows;

@end

@implementation SuspensionControl

@dynamic shareInstance;

+ (UIWindow *)windowForKey:(NSString *)key {
    return [[SuspensionControl shareInstance].windows objectForKey:key];
}

+ (void)setWindow:(UIWindow *)window forKey:(NSString *)key {
    [[SuspensionControl shareInstance].windows setObject:window forKey:key];
}


+ (void)removeWindowForKey:(NSString *)key {
    UIWindow *window = [[SuspensionControl shareInstance].windows objectForKey:key];
    window.hidden = YES;
    if (window.rootViewController.presentedViewController) {
        [window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    window.hidden = YES;
    window.rootViewController = nil;
    [[SuspensionControl shareInstance].windows removeObjectForKey:key];
}


+ (void)removeAllWindows {
    for (UIWindow *window in [SuspensionControl shareInstance].windows.allValues) {
        window.hidden = YES;
        window.rootViewController = nil;
    }
    [[SuspensionControl shareInstance].windows removeAllObjects];
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
}

+ (void)removeWindow:(UIWindow *)aWindow {
    
    if (!aWindow) {
        return;
    }
    NSDictionary *temp = [[SuspensionControl shareInstance].windows mutableCopy];
    [temp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIWindow * _Nonnull obj, BOOL * _Nonnull stop) {
        if (aWindow == obj) {
            [SuspensionControl removeWindowForKey:key];
        }
        *stop = YES;
    }];
    temp = nil;
    
}

+ (NSDictionary *)windows {
    return [SuspensionControl shareInstance].windows;
}



////////////////////////////////////////////////////////////////////////
#pragma mark - setter \ getter
////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary<NSString *, UIWindow *> *)windows {
    if (!_windows) {
        _windows = [NSMutableDictionary dictionary];
    }
    return _windows;
}


+ (instancetype)shareInstance {
    
    static SuspensionControl *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


@end

@implementation NSObject (SuspensionKey)

- (void)setKey:(NSString *)key {
    objc_setAssociatedObject(self, @selector(key), key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)key {
    NSString *key = objc_getAssociatedObject(self, @selector(key));
    if (!key.length) {
        self.key = (key = [self md5:self.description]);
    }
    return key;
}

- (NSString *)keyWithIdentifier:(NSString *)identifier {
    return [self.key stringByAppendingString:identifier];
}

- (NSString *)md5:(NSString *)str {
    const char * cStr = [str UTF8String];
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7], result[8], result[9],
            result[10], result[11], result[12], result[13],
            result[14], result[15]];
}

@end