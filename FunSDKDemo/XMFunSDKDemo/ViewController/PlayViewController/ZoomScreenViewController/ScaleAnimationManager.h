//
//  ScaleAnimationManager.h
//   
//
//  Created by Tony Stark on 2021/11/15.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 缩放动画管理器
 */
@interface ScaleAnimationManager : NSObject

//放大控件最大缩放倍数
@property (nonatomic,assign) float maxScale;
//放大控件最小缩放倍数
@property (nonatomic,assign) float minScale;
//临界倍数
@property (nonatomic,assign) float criticalMultiple;
//最大动画时长
@property (nonatomic,assign) float maxAnimationTime;
//最小动画时常
@property (nonatomic,assign) float minAnimationTime;
//动画频率
@property (nonatomic,assign) float animationFrequency;
//手动开始的动画时间
@property (nonatomic,assign) NSTimeInterval manualBeginTimes;
//手动的动画时长
@property (nonatomic,assign) float manualDuration;
//当前动画的时间
@property (nonatomic,assign) float animationTimeOffset;
//动画初始倍数
@property (nonatomic,assign) float animationStartScale;
//动画最终目标倍数
@property (nonatomic,assign) float animationFinalScale;
//动画的视图
@property (nonatomic,weak) UIView *animationView;

/// @brief 单个镜头设备主动滑动变倍工具栏放大缩小动画
/// @param multiple 需要缩放的实际倍数
/// @param maxMultiple 最大可以放大的倍数
/// @param view 需要被缩放的view
- (void)zoomControlViewChangeMultiple:(float)multiple maxMultiple:(float)maxMultiple animationView:(UIView *)view ignoreAnimation:(BOOL)ignore;
////MARK: 主动滑动动画
//- (void)zoomControlViewChangeMultiple:(float)multiple animationView:(UIView *)view sensor:(int)sensor criticalPointZoom:(float)zoom;
////MARK: sensor变化动画
//- (void)changeToSensor:(int)sensor multiple:(float)multiple criticalPointZoom:(float)zoom animationView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
