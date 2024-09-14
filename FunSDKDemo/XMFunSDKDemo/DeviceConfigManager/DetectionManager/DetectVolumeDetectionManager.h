//
//  DetectVolumeDetectionManager.h
//  iCSee
//
//  Created by Megatron on 2023/09/25
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetDetectVolumeDetectionCallBack)(int result);
typedef void(^SetDetectVolumeDetectionCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
  异响检测配置管理器
  */
@interface DetectVolumeDetectionManager : FunSDKBaseObject

@property (nonatomic,copy) GetDetectVolumeDetectionCallBack getDetectVolumeDetectionCallBack;
@property (nonatomic,copy) SetDetectVolumeDetectionCallBack setDetectVolumeDetectionCallBack;

/**
 * @brief 获取异响检测配置
 * @param devID 设备ID
 * @param completion GetDetectVolumeDetectionCallBack
 * @return void
 */
- (void)requestDetectVolumeDetectionWithDevice:(NSString *)devID completed:(GetDetectVolumeDetectionCallBack)completion;

/**
 * @brief 保存异响检测配置
 * @param completion SetDetectVolumeDetectionCallBack
 * @return void
 */
- (void)requestSaveDetectVolumeDetectionCompleted:(SetDetectVolumeDetectionCallBack)completion;

/*
  获取和设置【Enable】配置项
  */
- (BOOL)enable;
- (void)setEnable:(BOOL)enable;

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

- (BOOL)isCustomPeriod;
/*
  获取和设置【Sensitivity】配置项
  */
- (int)sensitivity;
- (void)setSensitivity:(int)sensitivity;

@end

NS_ASSUME_NONNULL_END






