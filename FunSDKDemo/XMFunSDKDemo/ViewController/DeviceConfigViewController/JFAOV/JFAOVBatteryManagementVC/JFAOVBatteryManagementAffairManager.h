//
//  JFAOVBatteryManagementAffairManager.h
//   iCSee
//
//  Created by Megatron on 2024/4/25.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DevLowElectrModeManager.h"
#import "AbilityAovAbilityManager.h"
#import "JFDeviceLogInfoManager.h"
#import "JFAlarmNumberStatisticsManager.h"
#import "SystemLowPowerWorkTimeManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFAOVBatteryManagementAffairManager : NSObject

///设备序列号
@property (nonatomic,copy) NSString *devID;
///所有配置获取成功，通知UI刷新
@property (nonatomic,copy) void (^AllConfigRequestedCallBack)();
///单个配置获取成功回调
@property (nonatomic,copy) void (^SingleConfigResuestedCallBack)(NSString *cfgName);
///获取配置失败回调
@property (nonatomic,copy) void (^ConfigRequestFailedCallBack)();
///获取电池电量回调 实时变化刷新 0-100
@property (nonatomic,copy) void (^BatteryLevelChanged)(int percentage);
///是否正在充电中回调
@property (nonatomic,copy) void (^BatteryChargingChanged)(BOOL ifCharging);
///是否支持低功耗设备唤醒和预览时长
@property (nonatomic,assign) BOOL supportLowPowerWorkTime;
///低电量配置管理器
@property (nonatomic,strong) DevLowElectrModeManager *lowElectrModeManager;
///工作模式自定义模式能力配置管理器
@property (nonatomic,strong) AbilityAovAbilityManager *abilityManager;
///设备日志信息配置管理器1天
@property (nonatomic,strong) JFDeviceLogInfoManager *deviceLogInfoOneDayManager;
///设备日志信息配置管理器7天
@property (nonatomic,strong) JFDeviceLogInfoManager *deviceLogInfoSevenDayManager;
///设备报警消息数量配置管理器1天
@property (nonatomic,strong) JFAlarmNumberStatisticsManager *alarmNumberStatisticsOneDayManager;
///设备报警消息数量配置管理器7天
@property (nonatomic,strong) JFAlarmNumberStatisticsManager *alarmNumberStatisticsSevenDayManager;
///设备预览和唤醒时间配置管理器
@property (nonatomic,strong) SystemLowPowerWorkTimeManager *systemLowPowerWorkTimeManager;

///获取配置
- (void)requestCfgWithDeviceID:(NSString *)devID ifAOVDevice:(BOOL)ifAOV;
///停止电量上报
- (void)stopBatteryUpload;
///开启电量上报
- (void)startBatteryUpload;
///通过配置名称检测配置是否获取成功
- (BOOL)configRequestedWithName:(NSString *)cfgName;

@end

NS_ASSUME_NONNULL_END
