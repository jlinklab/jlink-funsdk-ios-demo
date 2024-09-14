//
//  DevLowElectrModeManager.h
//  iCSee
//
//  Created by Megatron on 2024/04/28
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetDevLowElectrModeCallBack)(int result);
typedef void(^SetDevLowElectrModeCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
  【DevLowElectrMode】配置管理器
  */
@interface DevLowElectrModeManager : NSObject

@property (nonatomic,copy) GetDevLowElectrModeCallBack getDevLowElectrModeCallBack;
@property (nonatomic,copy) SetDevLowElectrModeCallBack setDevLowElectrModeCallBack;

/**
 * @brief 获取【DevLowElectrMode】配置
 * @param devID 设备ID
 * @param completion GetDevLowElectrModeCallBack
 * @return void
 */
- (void)requestDevLowElectrModeWithDevice:(NSString *)devID completed:(GetDevLowElectrModeCallBack)completion;

/**
 * @brief 保存【DevLowElectrMode】配置
 * @param completion SetDevLowElectrModeCallBack
 * @return void
 */
- (void)requestSaveDevLowElectrModeCompleted:(SetDevLowElectrModeCallBack)completion;

/*
  获取和设置【PowerThreshold】配置项
  */
- (int)powerThreshold;
- (void)setPowerThreshold:(int)powerThreshold;

@end

NS_ASSUME_NONNULL_END






