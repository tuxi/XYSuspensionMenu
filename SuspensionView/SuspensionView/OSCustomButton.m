//
//  OSCustomButton.h
//  OSButtonDemo
//
//  Created by Ossey on 2017/6/17.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "OSCustomButton.h"

typedef NS_ENUM(NSInteger, OSButtonStyle) {
    OSButtonStyleDefault,
    OSButtonStyleSubTitle,
    OSButtonStyleCentralImage,
    OSButtonStyleImageWithSubtitle
};


typedef void(^OSButtonAnimateBlock)();

#define OS_MAX_CORNER_RADIUS    MIN(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5)
#define OS_MAX_BORDER_WIDTH     OS_MAX_CORNER_RADIUS
#define OS_PADDING_VALUE        0.29

static CGRect CGRectEdgeInset(CGRect rect, UIEdgeInsets insets)
{
    return CGRectMake(CGRectGetMinX(rect) + insets.left,
                      CGRectGetMinY(rect) + insets.top,
                      CGRectGetWidth(rect) - insets.left - insets.right,
                      CGRectGetHeight(rect) - insets.top - insets.bottom);
}

@interface OSLabelContentView : UIView

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation OSLabelContentView

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.minimumScaleFactor = 0.1;
        _textLabel.numberOfLines = 1;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
            self.maskView = _textLabel;
        } else {
            self.layer.mask = _textLabel.layer;
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

@end

@implementation OSImageConentView

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor clearColor];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
            self.maskView = _imageView;
        } else {
            self.layer.mask = _imageView.layer;
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

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ initialize ~~~~~~~~~~~~~~~~~~~~~~~

+ (instancetype)buttonWithType:(OSButtonType)buttonType  {
    return [[self alloc] initWithFrame:CGRectZero buttonType:buttonType];
}

- (instancetype)initWithFrame:(CGRect)frame buttonType:(OSButtonType)type {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        _buttonType = type;
        _contentColor = self.tintColor;
        _restoreSelectedState = YES;
        _trackingInside = NO;
        _cornerRadius = 0.0;
        _borderWidth = 0.0;
        _contentEdgeInsets = UIEdgeInsetsZero;
        _fadeInOutOnDisplay = YES;
        self.buttonType = type;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame buttonType:OSButtonTypeDefault];
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Public ~~~~~~~~~~~~~~~~~~~~~~~

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


#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ layout ~~~~~~~~~~~~~~~~~~~~~~~

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
            _imageContentView.frame = CGRectNull;
            _detailContentView.frame = CGRectNull;
            [_imageContentView removeFromSuperview];
            [_detailContentView removeFromSuperview];
            self.titleContentView.frame = [self boxingRect];
        }
            break;
            
        case OSButtonStyleSubTitle:
        {
            _imageContentView.frame = CGRectNull;
            [_imageContentView removeFromSuperview];
            CGRect boxRect = [self boxingRect];
            self.titleContentView.frame = CGRectMake(boxRect.origin.x,
                                                     boxRect.origin.y,
                                                     CGRectGetWidth(boxRect),
                                                     CGRectGetHeight(boxRect) * 0.8);
            self.detailContentView.frame = CGRectMake(boxRect.origin.x,
                                                      CGRectGetMaxY(self.titleContentView.frame),
                                                      CGRectGetWidth(boxRect),
                                                      CGRectGetHeight(boxRect) * 0.2);
        }
            break;
            
        case OSButtonStyleCentralImage:
        {
            _titleContentView.frame = CGRectNull;
            _detailContentView.frame = CGRectNull;
            [_titleContentView removeFromSuperview];
            [_detailContentView removeFromSuperview];
            self.imageContentView.frame = [self boxingRect];
        }
            break;
            
        case OSButtonStyleImageWithSubtitle:
        default:
        {
            CGRect boxRect = [self boxingRect];
            _titleContentView.frame = CGRectNull;
            [_titleContentView removeFromSuperview];
            self.imageContentView.frame = CGRectMake(boxRect.origin.x,
                                                     boxRect.origin.y,
                                                     CGRectGetWidth(boxRect),
                                                     CGRectGetHeight(boxRect) * 0.8);
            self.detailContentView.frame = CGRectMake(boxRect.origin.x,
                                                      CGRectGetMaxY(self.imageContentView.frame),
                                                      CGRectGetWidth(boxRect),
                                                      CGRectGetHeight(boxRect) * 0.2);
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

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ set \ get ~~~~~~~~~~~~~~~~~~~~~~~

- (UIColor *)contentColor {
    return _contentColor ?: self.tintColor;
}

- (UIColor *)foregroundColor {
    return _foregroundColor ?: [UIColor whiteColor];
}

- (UIView *)foregroundView {
    if (!_foregroundView) {
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
        [self insertSubview:_titleContentView aboveSubview:self.foregroundView];
    }
    return _titleContentView;
}

- (OSLabelContentView *)detailContentView {
    if (!_detailContentView) {
        _detailContentView = [[OSLabelContentView alloc] initWithFrame:CGRectNull];
        _detailContentView.backgroundColor = self.contentColor;
        [self insertSubview:_detailContentView aboveSubview:self.foregroundView];
    }
    return _detailContentView;
}

- (OSImageConentView *)imageContentView {
    if (!_imageContentView) {
        _imageContentView = [[OSImageConentView alloc] initWithFrame:CGRectNull];
        _imageContentView.backgroundColor = self.contentColor;
        [self insertSubview:_imageContentView aboveSubview:self.foregroundView];
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
    } else {
        self.contentAnimateColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.foregroundColor = [UIColor clearColor];
        self.foregroundAnimateColor = [UIColor clearColor];
    }
    
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Touchs ~~~~~~~~~~~~~~~~~~~~~~~

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

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Animate ~~~~~~~~~~~~~~~~~~~~~~~

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



