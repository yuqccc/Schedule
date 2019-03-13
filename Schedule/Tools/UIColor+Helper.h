//
//  UIColor+Helper.h
//  TeacherSystem
//
//  Created by yuqiang on 2017/5/16.
//  Copyright © 2017年 izhikang. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIColor (Helper)

+(UIColor *) hexStringToColor: (NSString *) stringToConvert;

+ (UIColor *) colorWithHex:(unsigned long)col;

+ (UIImage *)imageWithColor:(UIColor *)color;

//生成渐变色的图片
+(UIImage*) captureView:(UIView *)theView rect:(CGRect)viewRect startColor:(UIColor *)startColor endColor:(UIColor *)endColor;

//根据字符串和透明度 生成颜色
+ (UIColor *)hexStringToColor: (NSString *) hexString alpha:(CGFloat)alpha;
@end
