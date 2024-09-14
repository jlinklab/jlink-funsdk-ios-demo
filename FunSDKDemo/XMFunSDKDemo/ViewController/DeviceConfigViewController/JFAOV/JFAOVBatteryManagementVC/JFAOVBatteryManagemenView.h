//
//  JFAOVBatteryManagemenView.h
//   iCSee
//
//  Created by Megatron on 2024/4/25.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JFAOVBatteryManagemenViewDelegate <NSObject>

///用户手动切换低电量阈值
- (void)userChangeLowBatteryLevel:(int)level;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JFAOVBatteryManagemenView : UIView

@property (nonatomic,weak) id<JFAOVBatteryManagemenViewDelegate>delegate;

///是否是非AOV设备 非AOV设备只有供电方式和电量
@property (nonatomic,assign) BOOL notAOVDevice;
///当前电池电量
@property (nonatomic,assign) int batteryLevel;
///是否正在充电中
@property (nonatomic,assign) BOOL ifCharging;
///低电量模式的电量
@property (nonatomic,assign) int lowBatteryLevel;
///电池电量设置的最小值
@property (nonatomic,assign) int lowElectrMin;
///电池电量设置的最大值
@property (nonatomic,assign) int lowElectrMax;
///电量信息的数据
@property (nonatomic,strong) NSMutableArray *arrayPowerOneDay;
///信号量信息的数据
@property (nonatomic,strong) NSMutableArray *arraySignalOneDay;
///电量信息的数据
@property (nonatomic,strong) NSMutableArray *arrayPowerSevenDay;
///信号量信息的数据
@property (nonatomic,strong) NSMutableArray *arraySignalSevenDay;
///是否支持低功耗设备唤醒和预览时长
@property (nonatomic,assign) BOOL supportLowPowerWorkTime;
///报警数量
@property (nonatomic,assign) int alarmNumberOneDay;
@property (nonatomic,assign) int alarmNumberSevenDay;
///预览时间
@property (nonatomic,assign) int previewSecondsOneDay;
@property (nonatomic,assign) int previewSecondsSevenDay;
///唤醒时间
@property (nonatomic,assign) int wakeUpSecondsOneDay;
@property (nonatomic,assign) int wakeUpSecondsSevenDay;

///更新配置项是否需要显示或隐藏
- (void)updateConfigListVisiable:(BOOL)visiable cfgNames:(NSArray *)cfgNames;
///更新列表
- (void)updateTableList;

@end

NS_ASSUME_NONNULL_END
