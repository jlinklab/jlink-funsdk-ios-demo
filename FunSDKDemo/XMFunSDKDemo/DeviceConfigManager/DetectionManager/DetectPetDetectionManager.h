//
//  DetectPetDetectionManager.h
//  iCSee
//
//  Created by Megatron on 2023/09/25
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetDetectPetDetectionCallBack)(int result);
typedef void(^SetDetectPetDetectionCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
  宠物检测配置管理器
  */
@interface DetectPetDetectionManager : FunSDKBaseObject

@property (nonatomic,copy) GetDetectPetDetectionCallBack getDetectPetDetectionCallBack;
@property (nonatomic,copy) SetDetectPetDetectionCallBack setDetectPetDetectionCallBack;

/**
 * @brief 获取宠物检测配置
 * @param devID 设备ID
 * @param completion GetDetectPetDetectionCallBack
 * @return void
 */
- (void)requestDetectPetDetectionWithDevice:(NSString *)devID completed:(GetDetectPetDetectionCallBack)completion;

/**
 * @brief 保存宠物检测配置
 * @param completion SetDetectPetDetectionCallBack
 * @return void
 */
- (void)requestSaveDetectPetDetectionCompleted:(SetDetectPetDetectionCallBack)completion;

/*
  获取和设置【Enable】配置项
  */
- (BOOL)enable;
- (void)setEnable:(BOOL)enable;

/*
  获取和设置【SnapEnable】配置项
  */
- (BOOL)snapEnable;
- (void)setSnapEnable:(BOOL)snapEnable;

/*
  获取和设置【SnapShotMask】配置项
  */
- (NSString *)snapShotMask;
- (void)setSnapShotMask:(NSString *)snapShotMask;

/*
  获取和设置【RecordEnable】配置项
  */
- (BOOL)recordEnable;
- (void)setRecordEnable:(BOOL)recordEnable;

/*
  获取和设置【RecordMask】配置项
  */
- (NSString *)recordMask;
- (void)setRecordMask:(NSString *)recordMask;

/*
  获取和设置【TimeSection】配置项
  */
- (NSArray *)timeSection;
- (void)setTimeSection:(NSArray *)timeSection;

/*
  获取和设置【MessageEnable】配置项
  */
- (BOOL)messageEnable;
- (void)setMessageEnable:(BOOL)enable;

/*
 判断报警方式
 报警时间段 -1:未知 0:全天报警 1:自定义报警
 */
- (int)getAlarmTimePeriod;

@end

NS_ASSUME_NONNULL_END






