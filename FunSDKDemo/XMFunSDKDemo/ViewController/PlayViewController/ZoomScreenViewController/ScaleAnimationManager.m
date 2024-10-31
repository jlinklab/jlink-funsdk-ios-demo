//
//  ScaleAnimationManager.m
//   
//
//  Created by Tony Stark on 2021/11/15.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "ScaleAnimationManager.h"

@interface ScaleAnimationManager ()

@property (nonatomic,strong) NSTimer *timer;

@end
@implementation ScaleAnimationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minScale = 1;
        self.maxScale = 8;
        self.maxAnimationTime = 1;
        self.minAnimationTime = 0.5;
        self.animationFrequency = 0.05;
    }
    
    return self;
}

- (float)criticalMultiple {
    return ((self.maxScale - self.minScale) * 0.5 + self.minScale);
}

/// @brief 单个镜头设备主动滑动变倍工具栏放大缩小动画
/// @param multiple 需要缩放的实际倍数
/// @param maxMultiple 最大可以放大的倍数
/// @param view 需要被缩放的view
- (void)zoomControlViewChangeMultiple:(float)multiple maxMultiple:(float)maxMultiple animationView:(UIView *)view ignoreAnimation:(BOOL)ignore{
    self.animationView = view;
    
    // 计算动画需要的时间
    float percent = fabs(view.transform.a - multiple) / maxMultiple;
    float animationTime = MAX(MIN(percent * self.maxAnimationTime, self.maxAnimationTime), self.minAnimationTime);
    
    self.manualDuration = ignore ? -100 : animationTime;
    self.manualBeginTimes = [[NSDate date] timeIntervalSince1970];
    self.animationStartScale = view.transform.a;
    self.animationFinalScale = multiple;
    self.animationTimeOffset = 0;
    
    [self startScaleAnimation];
}


- (void)startScaleAnimation {
    self.animationTimeOffset += self.animationFrequency;
    if (!self.animationView) {
        return;
    }

    // 当前动画目标倍数
    float curMultiple = (self.animationFinalScale - self.animationStartScale) * (self.animationTimeOffset / self.manualDuration) + self.animationStartScale;
    curMultiple = MAX(curMultiple, 1);  // 设置最小缩放倍数，避免缩小时内容消失
    //不需要动画时 直接设置目标倍数
    if (self.manualDuration == -100) {
        curMultiple = self.animationFinalScale;
    }

    // 计算当前的缩放比例
    CGFloat currentScale = fabs(self.animationView.transform.a);
    CGFloat newScale = curMultiple / currentScale;

    // 获取当前视图的可见中心点（相对于其superview）
    CGPoint currentCenterInSuperview = [self.animationView.superview convertPoint:self.animationView.center fromView:self.animationView.superview];
    
    // 获取视图当前内容的中心点（在动画视图自身坐标系中）
    CGPoint contentCenterInView = CGPointMake(CGRectGetMidX(self.animationView.bounds), CGRectGetMidY(self.animationView.bounds));
    CGPoint contentCenterInSuperview = [self.animationView convertPoint:contentCenterInView toView:self.animationView.superview];

    // 计算新的锚点使得缩放基于当前显示内容的中心
    CGPoint anchorPoint = CGPointMake((contentCenterInSuperview.x - CGRectGetMinX(self.animationView.frame)) / CGRectGetWidth(self.animationView.frame),
                                      (contentCenterInSuperview.y - CGRectGetMinY(self.animationView.frame)) / CGRectGetHeight(self.animationView.frame));

    if (isnan(anchorPoint.x) && isnan(anchorPoint.y)) {
        return;
    }
    
    // 设置新的锚点并调整center位置以保持视觉不变
    self.animationView.layer.anchorPoint = anchorPoint;
    self.animationView.center = currentCenterInSuperview;

    // 应用缩放变换
    CGAffineTransform scaledTransform = CGAffineTransformScale(self.animationView.transform, newScale, newScale);

    // 获取transform的缩放因子
    CGFloat scaleX = scaledTransform.a;

    // 计算变换后的宽高
    CGFloat transformedWidth = self.animationView.bounds.size.width * scaleX;
    CGFloat transformedHeight = self.animationView.bounds.size.height * scaleX;

    // 计算平移后的坐标
    CGFloat transformedX = self.animationView.frame.origin.x;
    CGFloat transformedY = self.animationView.frame.origin.y;

    CGRect superviewBounds = self.animationView.superview.bounds;

    // 偏移量初始化
    CGFloat offsetX = 0, offsetY = 0;

    // 检查左边界和上边界
    if (transformedX > 0) {
        offsetX = -transformedX;
    }
    if (transformedY > 0) {
        offsetY = -transformedY;
    }

    // 检查右边界和下边界
    if (transformedX + transformedWidth < superviewBounds.size.width) {
        offsetX = superviewBounds.size.width - (transformedX + transformedWidth);
    }
    if (transformedY + transformedHeight < superviewBounds.size.height) {
        offsetY = superviewBounds.size.height - (transformedY + transformedHeight);
    }

    // 如果有偏移，应用平移变换
    if (offsetX != 0 || offsetY != 0) {
        scaledTransform = CGAffineTransformTranslate(scaledTransform, offsetX, offsetY);
    }
    if (scaledTransform.a <= 1) {
        scaledTransform = CGAffineTransformIdentity;
    }

    NSLog(@"transform = %@, playview = %f",NSStringFromCGAffineTransform(scaledTransform),self.animationView.frame.size.width);
    
    if (self.animationTimeOffset < self.manualDuration) {
        [UIView animateWithDuration:self.animationFrequency delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.animationView.transform = scaledTransform;
        } completion:^(BOOL finished) {
            if (finished) {
                [self startScaleAnimation];
            }
        }];
    } else {
        if (self.manualDuration == -100) {
            [UIView performWithoutAnimation:^{
                self.animationView.transform = scaledTransform;
            }];
        } else {
            [UIView animateWithDuration:self.animationFrequency delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.animationView.transform = scaledTransform;
            } completion:nil];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"transform d %@, playview d %f",NSStringFromCGAffineTransform(scaledTransform),self.animationView.frame.size.width);
    });
    
}

@end
