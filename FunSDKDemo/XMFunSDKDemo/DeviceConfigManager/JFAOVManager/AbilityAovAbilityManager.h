//
//  AbilityAovAbilityManager.h
//  iCSee
//
//  Created by Megatron on 2024/04/24
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetAbilityAovAbilityCallBack)(int result);
typedef void(^SetAbilityAovAbilityCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
  【AbilityAovAbility】配置管理器
   AOV摄像机单帧模式支持的编码帧率
   人形联动报警录像支持设置的范围，人离开后还需要再录多长时间的录像，单位秒
   低电量模式配置Dev.LowElectrMode能取的最小值，单位百分比
   低电量模式配置Dev.LowElectrMode能取的最大值，单位百分比
  */
@interface AbilityAovAbilityManager : NSObject

@property (nonatomic,copy) GetAbilityAovAbilityCallBack getAbilityAovAbilityCallBack;
@property (nonatomic,copy) SetAbilityAovAbilityCallBack setAbilityAovAbilityCallBack;

/**
 * @brief 获取【AbilityAovAbility】配置
 * @param devID 设备ID
 * @param completion GetAbilityAovAbilityCallBack
 * @return void
 */
- (void)requestAbilityAovAbilityWithDevice:(NSString *)devID completed:(GetAbilityAovAbilityCallBack)completion;

/**
 * @brief 保存【AbilityAovAbility】配置
 * @param completion SetAbilityAovAbilityCallBack
 * @return void
 */
- (void)requestSaveAbilityAovAbilityCompleted:(SetAbilityAovAbilityCallBack)completion;

/*
  获取和设置【AOV摄像机单帧模式支持的编码帧率】配置项
  */
- (NSArray *)videoFps;
- (void)setVideoFps:(NSArray *)videoFps;

/*
  获取和设置【人形联动报警录像支持设置的范围，人离开后还需要再录多长时间的录像，单位秒】配置项
  */
- (NSArray *)recordLatch;
- (void)setRecordLatch:(NSArray *)recordLatch;

/*
  获取和设置【低电量模式配置Dev.LowElectrMode能取的最小值，单位百分比】配置项
  */
- (int)lowElectrMin;
- (void)setLowElectrMin:(int)lowElectrMin;

/*
  获取和设置【低电量模式配置Dev.LowElectrMode能取的最大值，单位百分比】配置项
  */
- (int)lowElectrMax;
- (void)setLowElectrMax:(int)lowElectrMax;

/*
 获取【AlarmHoldTime】配置项
  */
- (NSArray *)AlarmHoldTime;
 
/*
 获取【RecordLengthList】配置项 最大录像时长
  */
- (NSArray *)RecordLengthList;
@end

NS_ASSUME_NONNULL_END






