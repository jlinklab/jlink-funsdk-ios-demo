//
// JFPointsLineView.m
//  iCSee
//
// Created by Megatron on 2024/4/30.
// Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFPointsLineView.h"

@implementation JFPointsLineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.axisColor = JFColor(@"#C5C5C7");
        self.lineColor = NormalFontColor;
        self.lineWidth = 1;
    
        self.maxValueX = 24;
        self.maxValueY = 100;
        self.yAxisLineNumbers = 6;
    }
    
    return self;
}

- (void)updateLine{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // 获取当前的绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 清除指定的矩形区域
    CGContextClearRect(context, rect);
    // 设置线条颜色
    CGContextSetStrokeColorWithColor(context, self.axisColor.CGColor);
    // 设置线条宽度
    CGContextSetLineWidth(context, self.lineWidth);
    // 绘制坐标轴
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
    
    // 设置虚线样式
    CGFloat dash[] = {3, 3}; // 设置虚线样式：虚线宽度，间隔宽度
    CGContextSetLineDash(context, 0, dash, 2); // 第二个参数是phase，用来指定起始位置的偏移量，通常设为0
    // 绘制Y轴上的虚线
    CGFloat segmentHeight = rect.size.height / (self.yAxisLineNumbers * 1.0); // 计算每段的高度
    for (int i = 0; i < self.yAxisLineNumbers; i++) {
        CGFloat y = i * segmentHeight;
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, rect.size.width, y);
    }
    // 绘制路径
    CGContextStrokePath(context);
    
    // 设置线条样式为默认实线样式
    CGContextSetLineDash(context, 0, NULL, 0);
    // 设置线条颜色
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    // 设置线条宽度
    CGContextSetLineWidth(context, self.lineWidth);
    // 开始绘制折线路径
    if (self.points.count > 0) {
        CGContextMoveToPoint(context, [self.points[0] CGPointValue].x * rect.size.width, [self.points[0] CGPointValue].y * rect.size.height);
        for (int i = 1; i < self.points.count; i++) {
            CGContextAddLineToPoint(context, [self.points[i] CGPointValue].x * rect.size.width, [self.points[i] CGPointValue].y * rect.size.height);
        }
    }
    // 绘制路径
    CGContextStrokePath(context);
    
    // 创建渐变的路径
    if (self.points.count > 1) {
        UIBezierPath *gradientPath = [UIBezierPath bezierPath];
        [gradientPath moveToPoint:CGPointMake([self.points[0] CGPointValue].x * rect.size.width, [self.points[0] CGPointValue].y * rect.size.height)];
        for (int i = 1; i < self.points.count; i++) {
            [gradientPath addLineToPoint:CGPointMake([self.points[i] CGPointValue].x * rect.size.width, [self.points[i] CGPointValue].y * rect.size.height)];
        }
        [gradientPath addLineToPoint:CGPointMake([self.points.lastObject CGPointValue].x * rect.size.width,rect.size.height)];
        [gradientPath addLineToPoint:CGPointMake([self.points.firstObject CGPointValue].x * rect.size.width,rect.size.height)];
        [gradientPath closePath];
        
        // 创建渐变对象
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSArray *colors = @[(__bridge id)self.gradientEndColor.CGColor, (__bridge id)self.gradientStartColor.CGColor];
        CGFloat locations[] = {0.0, 1.0};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
        
        // 在路径上填充渐变色
        CGContextAddPath(context, gradientPath.CGPath);
        CGContextClip(context);
        CGPoint startPoint = CGPointMake(0, rect.size.height);
        CGPoint endPoint = CGPointMake(0, 0);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        
        // 释放资源
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    }
}

@end
