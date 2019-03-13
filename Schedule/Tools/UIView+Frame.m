//
//  UIView+Frame.m
//  彩票
//
//  Created by yuqiang on 15/11/23.
//  Copyright © 2015年 itcast. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

-(void)setX:(CGFloat)x{
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

-(void)setXCenter:(CGFloat)xCenter{
    self.x = xCenter - self.w * 0.5;
}

-(void)setY:(CGFloat)y{
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

-(void)setYCenter:(CGFloat)yCenter{
    self.y = yCenter - self.h * 0.5;
}

-(void)setW:(CGFloat)w{
    CGRect rect = self.frame;
    rect.size.width = w;
    self.frame = rect;
}

-(void)setH:(CGFloat)h{
    CGRect rect = self.frame;
    rect.size.height = h;
    self.frame = rect;
}

-(CGFloat)x{
    return self.frame.origin.x;
}
- (CGFloat)xCenter{
    return self.x + self.w * 0.5;
}

-(CGFloat)y{
    return self.frame.origin.y;
}
- (CGFloat)yCenter{
    return self.y + self.h * 0.5;
}

-(CGFloat)w{
    return self.frame.size.width;
}

-(CGFloat)h{
    return self.frame.size.height;
}

@end
