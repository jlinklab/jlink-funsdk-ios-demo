//
//  DoorBellBatteryStateView.h
//  XWorld_General
//
//  Created by SaturdayNight on 26/10/2017.
//  Copyright © 2017 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DoorBellBatteryLoadingAnimationView;

@interface DoorBellBatteryStateView : UIView

@property (nonatomic,assign) BOOL supportDisplay; //是否支持显示
@property (nonatomic,strong) DoorBellBatteryLoadingAnimationView *loadingView;  // 电池加载视图
@property (nonatomic,strong) UIImageView *imgViewBatteryOutline;        // 电池轮廓图片
@property (nonatomic,strong) UIView *electricQuantityView;              // 当前电量视图
@property (nonatomic,strong) UIImageView *imgViewLightingIcon;          // 闪电图标 充电图标
@property (nonatomic,strong) UILabel *lbElectricQuantity;               // 电池电量描述

//MARK: 设置电量百分比（float：0-1）
- (void)setBateryPercentage:(float)percentage;
//MARK: 报警消息界面低电量
- (void)setAlarmMessageLowBateryPercentage:(float)percentage;
//MARK: 是否显示电量数值
- (void)showLabel:(BOOL)show;
//MARK: 正在充电
- (void)beginChargeAnimation;
//MARK: 停止充电
- (void)endChargeAnimation;

@end
