//
//  XYDummyView.h
//  XYSuspensionMenuDemo
//
//  Created by swae on 2018/1/14.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYDummyView : UIView

#if ! __has_feature(objc_arc)
@property (nonatomic, assign) UIButton *button;
@property (nonatomic, assign) UIButton *clearButton;
#else
@property (nonatomic, weak) UIButton *button;
@property (nonatomic, weak) UIButton *clearButton;

#endif

- (NSLayoutConstraint *)getButtonTopConstraint;
- (void)hideCleanButton;
@end
