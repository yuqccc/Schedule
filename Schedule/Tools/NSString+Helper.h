//
//  NSString+Helper.h
//  TeacherSystem
//
//  Created by yuqiang on 2017/5/26.
//  Copyright © 2017年 izhikang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <UIKit/UIKit.h>

@interface NSString (Helper)
//+ (BOOL) validateMobile:(NSString *)mobile;

//调整文字上下间距
+(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace;

//MD5加密
+(NSString *)md5:(NSString *) input;

//根据宽度 和 字号  计算高度
+(CGFloat)heightOfString:(id)string fontSize:(NSInteger)fontSize width:(CGFloat)width;

//根据宽度 和 字号 行间距  计算高度
+(CGFloat)heightOfString:(NSString *)string fontSize:(NSInteger)fontSize width:(CGFloat)width lineSpace:(CGFloat)lineSpace;

//根据高度计算宽度
+(CGFloat)widthtOfString:(NSString *)string fontSize:(NSInteger)fontSize height:(CGFloat)height;


@end
