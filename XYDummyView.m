//
//  XYDummyView.m
//  XYSuspensionMenuDemo
//
//  Created by swae on 2018/1/14.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "XYDummyView.h"

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
