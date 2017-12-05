//
//  XYConsoleTextView.m
//  XYSuspensionMenuDemo
//
//  Created by xiaoyuan on 05/12/2017.
//  Copyright © 2017 xiaoyuan. All rights reserved.
//

#import "XYConsoleTextView.h"

@interface XYConsoleTextView ()

// 是否全屏显示
@property (nonatomic, assign, getter=isDisplayFullScreen) BOOL displayFullScreen;
// 添加的向外的手势，为了避免和查看log日志的手势冲突  isShow之后把手势移除
@property (nonatomic, strong) UIPanGestureRecognizer *panOutGesture;

@end

@implementation XYConsoleTextView

/// 右滑隐藏
- (void)swipeOnSelf:(UISwipeGestureRecognizer *)swipeGesture{
    
    if (self.isDisplayFullScreen) {//如果是显示情况并且往右边滑动就隐藏
        if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"往右边滑动了");
            [UIView animateWithDuration:0.5 animations:^{
                self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 30, 120, [UIScreen mainScreen].bounds.size.width, 90);
            } completion:^(BOOL finished) {
                self.displayFullScreen = NO;
                [self.textField addGestureRecognizer:self.panOutGesture];
            }];
        }
    }else{//如果是隐藏情况往左边滑就是显示
        
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(60, 120, [UIScreen mainScreen].bounds.size.width - 60, 90);
        } completion:^(BOOL finished) {
            self.displayFullScreen = NO;
        }];
    }
}
//左拉显示
- (void)panOutTextView:(UIPanGestureRecognizer *)panGesture{
    
    if (self.isDisplayFullScreen == YES) {//如果是显示情况什么都不管。
        return;
    }
    else {//如果是隐藏情况上下移动就
        CGPoint point = [panGesture locationInView:[UIApplication sharedApplication].keyWindow];
        CGRect rect = self.frame;
        rect.origin.y = point.y - 30;
        self.frame = rect;
    }
}
//双击操作
- (void)doubleTapTextView:(UITapGestureRecognizer *)tapGesture{
    
    if (self.isDisplayFullScreen == NO) {//变成全屏
        self.scrollEnabled = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
            self.displayFullScreen = YES;
            [self.textField removeGestureRecognizer:self.panOutGesture];
        }];
    }else{//退出全屏
        self.scrollEnabled = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 30, 120, [UIScreen mainScreen].bounds.size.width, 90);
        } completion:^(BOOL finished) {
            self.displayFullScreen = NO;
            [self.textField addGestureRecognizer:self.panOutGesture];
        }];
    }
}


//- (GHConsoleTextField *)textField {
//    if (!_textField) {
//        _textField = [[GHConsoleTextField alloc]initWithFrame:CGRectMake(k_WIDTH - 30, 120, k_WIDTH - 60, 90)];
//        _textField.backgroundColor = [UIColor blackColor];
//        _textField.text = @"\n\n";
//        _textField.editable = NO;
//        self.textField.textColor = [UIColor whiteColor];
//        //        self.textField.font = [UIFont systemFontOfSize:15 weight:10];
//        self.textField.selectable = NO;
//        //添加右滑隐藏手势
//        UISwipeGestureRecognizer *swipeGest = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLogView:)];
//        //添加双击全屏或者隐藏的手势
//        UITapGestureRecognizer *tappGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapTextView:)];
//        tappGest.numberOfTapsRequired = 2;
//        
//        [_textField addGestureRecognizer:swipeGest];
//        [_textField addGestureRecognizer:tappGest];
//        [_textField addGestureRecognizer:self.panOutGesture];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            if (_isShowConsole) {
//                [[UIApplication sharedApplication].keyWindow addSubview:_textField];
//            }
//        });
//    }
//    return _textField;
//}

- (UIPanGestureRecognizer *)panOutGesture{
    if (!_panOutGesture) {
        _panOutGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panOutTextView:)];
    }
    return _panOutGesture;
}

@end
