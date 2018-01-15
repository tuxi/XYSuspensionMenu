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
    NSLayoutConstraint *bottomButtonBotton = [NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bottomButtonLeft = [NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:bottomButton.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [NSLayoutConstraint activateConstraints:@[bottomButtonTop, bottomButtonLeft, bottomButtonBotton]];
    
    self.button = bottomButton;
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    clearButton.backgroundColor = [UIColor grayColor];
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    [self addSubview:clearButton];
    NSLayoutConstraint *clearButtonTop = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bottomButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *clearButtonRight = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    NSLayoutConstraint *clearButtonBottom = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.button attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *clearButtonLeft = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:bottomButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *clearButtonWidth = [NSLayoutConstraint constraintWithItem:clearButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80.0];
    [NSLayoutConstraint activateConstraints:@[clearButtonTop, clearButtonRight, clearButtonBottom, clearButtonLeft, clearButtonWidth]];
    self.clearButton = clearButton;
}

- (NSLayoutConstraint *)getButtonTopConstraint {
    NSArray *cons = self.constraints;
    if (!cons.count) {
        return nil;
    }
    NSUInteger foudIdx = [cons indexOfObjectPassingTest:^BOOL(NSLayoutConstraint *  _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [c.firstItem isEqual:self.button] && c.firstAttribute == NSLayoutAttributeTop;
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    if (foudIdx != NSNotFound) {
        return [cons objectAtIndex:foudIdx];
    }
    return nil;
}

- (void)hideCleanButton {
    self.clearButton.hidden = YES;
    NSArray *cons = self.constraints;
    if (!cons.count) {
        return;
    }
    NSUInteger foudIdx = [cons indexOfObjectPassingTest:^BOOL(NSLayoutConstraint *  _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [c.firstItem isEqual:self.clearButton] && c.firstAttribute == NSLayoutAttributeLeading;
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    if (foudIdx != NSNotFound) {
        NSLayoutConstraint *lef = [cons objectAtIndex:foudIdx];
        if (lef.isActive == NO) {
            return;
        }
        lef.active = NO;
        [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    }
    
}

@end
