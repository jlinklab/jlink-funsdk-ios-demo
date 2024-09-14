//
//  JFAOVModeOfWorkAffairManager.h
//   iCSee
//
//  Created by Megatron on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DevAovWorkModeManager.h"
#import "AbilityAovAbilityManager.h"
#import "DevLowElectrModeManager.h"
NS_ASSUME_NONNULL_BEGIN

///AOV工作模式事物管理器
@interface JFAOVModeOfWorkAffairManager : NSObject

///设备序列号
@property (nonatomic,copy) NSString *devID;
///工作模式管理器
@property (nonatomic,strong) DevAovWorkModeManager *workModeManager;
///工作模式自定义模式能力
@property (nonatomic,strong) AbilityAovAbilityManager *abilityManager;
///所有配置获取成功，通知UI刷新
@property (nonatomic,copy) void (^AllConfigRequestedCallBack)();
///获取配置失败回调
@property (nonatomic,copy) void (^ConfigRequestFailedCallBack)();
///获取电池电量回调 实时变化刷新 0-100
@property (nonatomic,copy) void (^BatteryLevelChanged)(int percentage);
///是否正在充电中回调
@property (nonatomic,copy) void (^BatteryChargingChanged)(BOOL ifCharging);
///低电量配置管理器
@property (nonatomic,strong) DevLowElectrModeManager *lowElectrModeManager;
///获取配置
- (void)requestCfgWithDeviceID:(NSString *)devID;
///停止电量上报
- (void)stopBatteryUpload;
///开启电量上报
- (void)startBatteryUpload;
@end

NS_ASSUME_NONNULL_END
