//
//  DevAovWorkModeManager.h
//  iCSee
//
//  Created by Megatron on 2024/04/24
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetDevAovWorkModeCallBack)(int result);
typedef void(^SetDevAovWorkModeCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
  【AOV工作模式】配置管理器
  */
@interface DevAovWorkModeManager : NSObject

@property (nonatomic,copy) GetDevAovWorkModeCallBack getDevAovWorkModeCallBack;
@property (nonatomic,copy) SetDevAovWorkModeCallBack setDevAovWorkModeCallBack;

/**
 * @brief 获取【DevAovWorkMode】配置
 * @param devID 设备ID
 * @param completion GetDevAovWorkModeCallBack
 * @return void
 */
- (void)requestDevAovWorkModeWithDevice:(NSString *)devID completed:(GetDevAovWorkModeCallBack)completion;

/**
 * @brief 保存【DevAovWorkMode】配置
 * @param completion SetDevAovWorkModeCallBack
 * @return void
 */
- (void)requestSaveDevAovWorkModeCompleted:(SetDevAovWorkModeCallBack)completion;

/*
  获取和设置【Mode】配置项
  */
- (NSString *)mode;
- (void)setMode:(NSString *)mode;

/*
  获取和设置【Custom】配置项
  */
- (NSDictionary *)custom;
- (void)setCustom:(NSDictionary *)custom;

/*
  获取和设置【Performance】配置项
  */
- (NSDictionary *)performance;
- (void)setPerformance:(NSDictionary *)performance;

/*
  获取和设置【Balance】配置项
  */
- (NSDictionary *)balance;
- (void)setBalance:(NSDictionary *)balance;

/*
 获取和设置【AlarmHoldTime】报警抑制时间  报警间隔配置项
  */
- (int)AlarmHoldTime;
- (void)setAlarmHoldTime:(int)alarmHoldTime;
@end

NS_ASSUME_NONNULL_END






