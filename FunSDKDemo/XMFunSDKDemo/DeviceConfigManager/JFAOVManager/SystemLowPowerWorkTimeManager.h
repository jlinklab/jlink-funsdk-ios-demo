//
//  SystemLowPowerWorkTimeManager.h
//  iCSee
//
//  Created by Megatron on 2024/05/25
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetSystemLowPowerWorkTimeCallBack)(int result);
typedef void(^SetSystemLowPowerWorkTimeCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
  【SystemLowPowerWorkTime】配置管理器
  */
@interface SystemLowPowerWorkTimeManager : NSObject

@property (nonatomic,copy) GetSystemLowPowerWorkTimeCallBack getSystemLowPowerWorkTimeCallBack;
@property (nonatomic,copy) SetSystemLowPowerWorkTimeCallBack setSystemLowPowerWorkTimeCallBack;

/**
 * @brief 获取【SystemLowPowerWorkTime】配置
 * @param devID 设备ID
 * @param completion GetSystemLowPowerWorkTimeCallBack
 * @return void
 */
- (void)requestSystemLowPowerWorkTimeWithDevice:(NSString *)devID completed:(GetSystemLowPowerWorkTimeCallBack)completion;

/**
 * @brief 保存【SystemLowPowerWorkTime】配置
 * @param completion SetSystemLowPowerWorkTimeCallBack
 * @return void
 */
- (void)requestSaveSystemLowPowerWorkTimeCompleted:(SetSystemLowPowerWorkTimeCallBack)completion;

/*
  获取和设置【RealViewTime】配置项
  */
- (NSArray *)realViewTime;
- (void)setRealViewTime:(NSArray *)realViewTime;

/*
  获取和设置【WakeupTime】配置项
  */
- (NSArray *)wakeupTime;
- (void)setWakeupTime:(NSArray *)wakeupTime;

@end

NS_ASSUME_NONNULL_END






