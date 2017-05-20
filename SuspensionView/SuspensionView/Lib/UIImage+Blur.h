//
//  UIImage+Blur.h
//  模糊工具
//
//  Created by Ossey on 16/12/20.
//  Copyright © 2015年 Ossey. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (Blur)

/*!
 *  高斯模糊修改颜色　半径 饱和度 添加遮罩
 *  @param blur                     模糊程度(0 - 1)超过的均默认为 0.5
 *  @param blurRadius               模糊半径 推荐 30 - 40
 *  @param tintColor                模糊颜色 (null)推荐制空
 *  @param saturationDeltaFactor    饱和度 0是黑白灰, 9是浓彩色, 1是原色  默认1.8
 *  @param maskImage                遮罩
 */
- (UIImage *)imageBluredwithBlurNumber:(CGFloat)blur
                            WithRadius:(CGFloat)blurRadius
                             tintColor:(UIColor *)tintColor
                 saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                             maskImage:(UIImage *)maskImage;

/**
 *  CoreImage图片高斯模糊
 *
 *  @param image 图片
 *  @param blur  模糊数值(默认是10)
 *
 *  @return 重新绘制的新图片
 */
- (UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;
- (UIImage *)blurryImage:(UIImage *)image withMaskImage:(UIImage *)maskImage blurLevel:(CGFloat)blur;

+ (UIImage *)imageFromColor:(UIColor *)color;
@end
